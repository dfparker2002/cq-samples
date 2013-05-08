package com.adobe.ags.cq.tools.versionhistory;


import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;

import javax.jcr.RepositoryException;
import javax.servlet.ServletException;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;
import org.apache.sling.commons.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @scr.component immediate="true" metatype="false"
 * @scr.service interface="javax.servlet.Servlet"
 * @scr.property name="sling.servlet.methods" values.0="GET"
 * @scr.property name="sling.servlet.resourceTypes" values.0="sling/servlet/default"
 * @scr.property name="sling.servlet.selectors" values.0="versionhistory"
 * @scr.property name="sling.servlet.extensions" values.0="json" values.1="html"
 */
public class VersionHistoryServlet extends SlingSafeMethodsServlet {
   private static final long serialVersionUID = -1920460619265757059L;
   private static final Logger logger = LoggerFactory.getLogger(VersionHistoryServlet.class);

   public static final String EXTENSION_JSON = "json";
   
   public static final String SELECTOR_LIST = "list";
   public static final String SELECTOR_GET = "get";
   
   public static final String DEFAULT_SELECTOR = SELECTOR_LIST;
   
   public static final String PN_IS_LIST = "versionHistoryIsList";
   public static final String PN_HISTORY_RESOURCE = "versionHistoryResource";
   public static final String PN_SELECTED_ITEMS = "versionHistorySelectedItems";

   @Override
   protected void doGet(SlingHttpServletRequest request, SlingHttpServletResponse response) throws ServletException, IOException {
      logger.debug("doGet - Starting");
      
      String[] selectors = request.getRequestPathInfo().getSelectors();
      boolean hasProcessedSelector = false;
      try {
	      for (String selector : selectors) {
    		  logger.debug("doGet - Dispatching request: selector={}", selector);
    		  hasProcessedSelector = dispatchRequest(request, response, selector);
    		  
    		  if (hasProcessedSelector)
    			  break;
	      }
	      
	      //we didn't find a selector that we recognised in the requestpathinfo, fall back to default
		  if (!hasProcessedSelector) {
			  logger.warn("doGet - No selector matched, reverting to default: selectors={}; default={}", request.getRequestPathInfo().getSelectorString(), DEFAULT_SELECTOR);
			  hasProcessedSelector = dispatchRequest(request, response, DEFAULT_SELECTOR);
			  
			  if (!hasProcessedSelector) {
				  logger.error("doGet - Default selector not dispatched: selectors={}; default={}", request.getRequestPathInfo().getSelectorString(), DEFAULT_SELECTOR);
			  }
		  }
		  
		  //if we found and processed a selector we recognised, the render it
		  if (hasProcessedSelector) {
				renderRequest(request, response);
		  } else {
			  //TODO Introduce HTTP Error Handling
		  }
		  
		} catch (RepositoryException e) {
			logger.error("doGet - RepositoryException when rendering request, exception: {}", e);
			//TODO Introduce HTTP Error Handling
		}
   }
   
   private boolean dispatchRequest(SlingHttpServletRequest request, SlingHttpServletResponse response, String selector) throws RepositoryException {
	  boolean hasProcessedSelector = false;
	  Collection<HistoryItem> historyItems = null;
	  HistoryResource historyResource = request.getResource().adaptTo(HistoryResource.class);
	  
	  //set the history resource into the request
	  if (historyResource == null) {
		  logger.warn("dispatchRequest - The resource could not be adapted to a HistoryResourcce.");
	  } else {
		  request.setAttribute(PN_HISTORY_RESOURCE, historyResource);
	  }

	  //process the set a flag on whether the request is a list request
 	  if (selector.equals(SELECTOR_LIST)) {
		  historyItems = historyResource.getAll();
		  request.setAttribute(PN_SELECTED_ITEMS, historyItems);
		  request.setAttribute(PN_IS_LIST, true);
		  
		  hasProcessedSelector = true;
	  }
	  
	  if (selector.equals(SELECTOR_GET)) {
		  historyItems = new ArrayList<HistoryItem>();
		  HistoryItem historyItem = historyResource.get(request);
		  
		  if (historyItem != null) {
			  historyItems.add(historyItem);
		  } else {
			  //TODO requested history item does not exist, error handling, HTTP Status?
		  }
		  
		  request.setAttribute(PN_SELECTED_ITEMS, historyItems);
		  
		  hasProcessedSelector = true;
	  }
	  
	  return hasProcessedSelector;
   }
   
   private boolean renderRequest(SlingHttpServletRequest request, SlingHttpServletResponse response) throws IOException, RepositoryException {
	   boolean hasProcessedExtension = false;
	   String extension = request.getRequestPathInfo().getExtension();
	  
	   if (extension.equals(EXTENSION_JSON)) {
		  hasProcessedExtension = true;
		  response.setContentType("application/json");
		  try {
			  VersionHistoryUtils.renderJSON(request, response);
		  } catch (JSONException e) {
			  logger.error("renderJSON - Could not construct JSON response: {}", e);
			 //TODO problem building JSON, error handling, HTTP Status?
		  }
		  
	   }
	   
	   return hasProcessedExtension;
   }
}