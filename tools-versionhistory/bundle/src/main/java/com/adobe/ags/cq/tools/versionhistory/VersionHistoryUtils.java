package com.adobe.ags.cq.tools.versionhistory;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Collection;

import javax.jcr.RepositoryException;
import javax.jcr.Session;
import javax.jcr.Workspace;
import javax.jcr.version.VersionManager;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.request.RequestPathInfo;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.commons.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.day.cq.commons.TidyJSONWriter;

public class VersionHistoryUtils {
	private static final Logger logger = LoggerFactory.getLogger(VersionHistoryUtils.class);
	
	public static VersionManager getVersionManager(Resource resource) throws RepositoryException {
		   VersionManager versionManager = null;
		   final String contentPath = resource.getPath();
		   
	       final Session session = resource.getResourceResolver().adaptTo(Session.class);
	       logger.trace("getVersionManager - session is null={}; path={}", session == null, contentPath);
	       
	       final Workspace workspace = session == null ? null : session.getWorkspace();
	       if (workspace == null) {
	    	   logger.trace("getVersionManager - workspace is null={}; path={}", workspace == null, contentPath);
	    	   return versionManager;
	       }
	       
	       versionManager = workspace.getVersionManager();
	       
	       return versionManager;
	}
	
   public static int getFirstNumericSelector(SlingHttpServletRequest request) {
	   Integer versionToGet = -1;
	   final RequestPathInfo rpi = request.getRequestPathInfo();
	   
	   for (String selector : rpi.getSelectors()) {			   
		   if (isNumeric(selector)) {
			   versionToGet = new Integer(Integer.parseInt(selector));
			   break;
		   }
	   }
	   
	   return versionToGet;
   }
   
   public static void renderJSON(SlingHttpServletRequest request, SlingHttpServletResponse response) throws RepositoryException, IOException, JSONException {
	    @SuppressWarnings("unchecked")
		Collection<HistoryItem> historyItems = (Collection<HistoryItem>) request.getAttribute(VersionHistoryServlet.PN_SELECTED_ITEMS);
	    
	    SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
	    TidyJSONWriter out = new TidyJSONWriter(response.getWriter());
	    //out.setTidy("true".equals(request.getParameter(TIDY)));
	    
		out.object();
		out.key("versions").array();
		
		if (historyItems.size() > 0) {
			for (HistoryItem item : historyItems) {
				out.object();
				out.key("version").value(item.getVersion());
				out.key("id").value(item.getId());
				out.key("label").value(item.getLabel());
				out.key("comment").value(item.getComment());
				out.key("name").value(item.getName());
				out.key("title").value(item.getTitle());
				out.key("created").value(item.getCreated() != null ? item.getCreated().getTime() : null);
				out.key("deleted").value(item.getDeleted() != null ? dateFormatter.format(item.getDeleted().getTime()) : null);
				out.key("renditionsPath").value(item.getRenditionsPath());
				out.key("versionPath").value(item.getPath());
				out.endObject();
			}
		}
		
		out.endArray();
		out.endObject();
   }
	
   static boolean isNumeric(String str) {  
     try {  
        @SuppressWarnings("unused")
	    double d = Double.parseDouble(str);  
     } catch(NumberFormatException nfe) {  
       return false;  
     }  
     
     return true;  
   }
   
   public static HistoryItem createHistoryItem() {
	  return new HistoryItem();
  }
}
