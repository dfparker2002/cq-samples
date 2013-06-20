package com.adobe.support.wcm.commands;

import javax.jcr.Node;
import javax.jcr.RepositoryException;
import javax.jcr.Session;
import javax.jcr.SimpleCredentials;

import org.apache.felix.scr.annotations.Activate;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Deactivate;
import org.apache.felix.scr.annotations.Modified;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.servlets.HtmlResponse;
import org.apache.sling.jcr.api.SlingRepository;
import org.osgi.service.component.ComponentContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.day.cq.commons.servlets.HtmlStatusResponseHelper;
import com.day.cq.wcm.api.Page;
import com.day.cq.wcm.api.PageManager;
import com.day.cq.wcm.api.commands.WCMCommand;
import com.day.cq.wcm.api.commands.WCMCommandContext;

@Service
@Component
public class CreatePageWithCustomPropertiesCommand implements WCMCommand {
	/**
	 * The string that this command will answer to in the WCMCommandServlet 
	 */
	public static final String COMMAND_NAME = "createPageWithCustomProperties";
	
	/**
	 * Name of the node property to indicate that this is a 'starred' page. 
	 */
	public static final String STARRED_PAGE_PARAM = "starred"; 
	
	/**
	 * Default value for the IMPERSONATION_USER_PROPERTY property.
	 */
	public static final String IMPERSONATION_USER_DEFAULT = "author";
	
	/**
	 * Property for setting the impersonate user to use when saving the node change for cusom properties.
	 * 
	 * , label="%createpagewithcustompropertiescommand.impersonateuser.label", description="%createpagewithcustompropertiescommand.impersonateuser.description"
	 */
	@Property(value=IMPERSONATION_USER_DEFAULT)
	public static final String IMPERSONATION_USER_PROPERTY = "createpagewithcustompropertiescommand.impersonateuser";
	
	/**
	 * Instance variable to hold the IMPERSONATION_USER_PROPERTY property value;
	 */
	public String impersonateUserProperty = null;
	
	/**
	 * The repository.
	 */
	@Reference
	SlingRepository repo;
	
	/**
	 * Internal logger
	 */
	private static final Logger log = LoggerFactory.getLogger(CreatePageWithCustomPropertiesCommand.class);

	/**
	 * {@inheritDoc}
	 */
	public String getCommandName() {
		return COMMAND_NAME;
	}

	/**
	 * Creates the page, and then adds the custom properties to the jcr:content node as 
	 * defined in the addContentNodeProperties() method.
	 * 
	 * {@inheritDoc}
	 */
	public HtmlResponse performCommand(WCMCommandContext commandContext,
			SlingHttpServletRequest request, SlingHttpServletResponse response,
			PageManager pageManager) {
        try {
        	final Page page = createPage(request, pageManager);
        	createCustomProperties(request, page);

            return HtmlStatusResponseHelper.createStatusResponse(true, "Page created", page
                    .getPath());
        } catch (Exception e) {
            log.error("Error during page creation.", e);
            return HtmlStatusResponseHelper.createStatusResponse(false, e.getMessage());
        }
	}
	
	/**
	 * Creates the CQ page using the PageManager object.
	 * 
	 * @param request
	 * @param pageManager
	 * @return
	 * @throws Exception
	 */
	private Page createPage(SlingHttpServletRequest request, PageManager pageManager) throws Exception {
        final String parentPath = request.getParameter(PARENT_PATH_PARAM);
        final String pageLabel = request.getParameter(PAGE_LABEL_PARAM);
        final String template = request.getParameter(TEMPLATE_PARAM);
        final String pageTitle = request.getParameter(PAGE_TITLE_PARAM);

        final Page page = pageManager.create(parentPath, pageLabel, template,
                pageTitle);
        
        return page;
	}
	
	/**
	 * Opens up a session to retrieve the jcr:content node of the page, then calls 
	 * addContentNodeProperties() to add any custom properties before closing and 
	 * saving the changes.
	 * 
	 * @param request
	 * @param page
	 * @throws IllegalArgumentException 
	 * @throws RepositoryException
	 */
	private void createCustomProperties(SlingHttpServletRequest request, Page page) throws IllegalArgumentException, RepositoryException {
		Session adminSession = null;
		Session session = null;
		
		try {
			//get the content node of the page
	        adminSession = repo.loginAdministrative(null);
	        session = adminSession.impersonate(new SimpleCredentials(impersonateUserProperty,new char[0]));
	        adminSession.logout();
	        
	        //get the content node
	        final Node pageNode = session.getNode(page.getPath());
	        
	        if (pageNode == null) {
	        	log.error("error creating custom properties for page at '{}'", page.getPath());
	        	throw new IllegalArgumentException("The page requested to be operated on could not be found.");
	        } 
	        
	        final Node contentNode = pageNode.getNode("./" + Node.JCR_CONTENT);
	        
	        if (contentNode == null) {
	        	log.error("error accessing the {} node of the page '{}'", Node.JCR_CONTENT, page.getPath());
	        	throw new IllegalArgumentException("The page requested did not have a " + Node.JCR_CONTENT + "node.");
	        } 

	        //call the method to create the custom properties
	        addCustomProperties(request, contentNode);

	        //save the changes and logout
	        session.save();
		}
		finally {
			if (adminSession != null && adminSession.isLive())
				adminSession.logout();
			
			if (session != null && session.isLive())
				session.logout();
		}
	}
	
	/**
	 * Method to allow for the addition of custom properties to save to the Page's jcr:content 
	 * node after creating the Page.
	 * 
	 * @param request
	 * @param contentNode
	 * @throws RepositoryException
	 */
	protected void addCustomProperties(SlingHttpServletRequest request, Node contentNode) throws RepositoryException {
        //create our custom properties on the content node
		final String pageStarred = request.getParameter(STARRED_PAGE_PARAM);
        contentNode.setProperty(STARRED_PAGE_PARAM, pageStarred);
	}
	
	@Activate
    protected void activate(ComponentContext context)
    {
		modified(context);
		
		if (log.isDebugEnabled())
			log.debug("Activated");
    }

	@Modified
    protected void modified(ComponentContext context)
    {
		impersonateUserProperty = (String) context.getProperties().get(IMPERSONATION_USER_PROPERTY);
        
        if (log.isDebugEnabled())
        	log.debug("Modifed");
    }
	
	@Deactivate
    protected void deactivate(ComponentContext context)
    {
		repo = null;
		
		if (log.isDebugEnabled())
			log.debug("Deactivated");
    }
}
