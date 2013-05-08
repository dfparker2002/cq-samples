package com.adobe.ags.cq.tools.versionhistory;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import javax.jcr.RepositoryException;
import javax.jcr.version.Version;
import javax.jcr.version.VersionHistory;
import javax.jcr.version.VersionIterator;
import javax.jcr.version.VersionManager;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.resource.Resource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HistoryResource {
	   private static final Logger logger = LoggerFactory.getLogger(VersionHistoryAdapterFactory.class);
	
	   private Resource resource;
	   private List<HistoryItem> items = null;
	   
	   public HistoryResource(Resource resource) {
		   this.resource = resource;
	   }
	   
	   public Resource getResource() {
		   return resource;
	   }
	   
	   public Collection<HistoryItem> getAll() throws RepositoryException {
		   initItems();
		   Collection<HistoryItem> collection = new ArrayList<HistoryItem>(items);
		   return Collections.unmodifiableCollection(collection);
	   }
	   
	   public HistoryItem getIndex(int index) throws RepositoryException {		   
		   initItems();
		   return null;
	   }
	   
	   public boolean hasIndex(int index) throws RepositoryException {
		   initItems();		   
		   return items.size() > index && index >= 0;
	   }
	   
	   public HistoryItem get(SlingHttpServletRequest request) throws RepositoryException {
		   Integer indexToGet = VersionHistoryUtils.getFirstNumericSelector(request);
		   
		   if (hasIndex(indexToGet)) {
			   return items.get(indexToGet);
		   } else {
			   logger.warn("get - index from selector string was missing ({}), or was beyond the items size ({})", indexToGet, items.size());
		   }
		   
		   return null;
	   }
	   
	   private void initItems() throws RepositoryException {
		   if (items != null)
			   return;
		   
		   VersionManager versionManager = VersionHistoryUtils.getVersionManager(resource);	    
	       final VersionHistory versionHistory = versionManager.getVersionHistory(resource.getPath());
	 
	 	   if (versionHistory == null) {
		    	 logger.warn("doGet - No version history was found for the node with a path of: {}", resource.getPath());
		   } else {
			 items = new ArrayList<HistoryItem>();
	         final VersionIterator versionIterator = versionHistory.getAllVersions();
	         logger.debug("doGet - Successfully found VersionHistory for path: {}, count of version", resource.getPath(), versionIterator.getSize());
	         
	         while (versionIterator.hasNext()) {
	        	 final Version version = (Version) versionIterator.next();
	        	 logger.trace("doGet - For path '{}', Found version with path: {}", resource.getPath(), version.getPath());
	        	 
	        	 HistoryItem newHistoryItem = VersionHistoryUtils.createHistoryItem();
	        	 newHistoryItem.init(resource, version);
	        	 newHistoryItem.setIndex((int) versionIterator.getPosition());
	        	 
        		 items.add(newHistoryItem);
	         } 
		  } 
	   }
}