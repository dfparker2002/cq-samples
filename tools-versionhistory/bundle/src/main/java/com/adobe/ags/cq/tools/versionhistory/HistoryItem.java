package com.adobe.ags.cq.tools.versionhistory;

import java.util.Calendar;

import javax.jcr.Node;
import javax.jcr.RepositoryException;
import javax.jcr.version.Version;

import org.apache.sling.api.resource.Resource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HistoryItem {
	private static final Logger logger = LoggerFactory.getLogger(HistoryItem.class);
	
	public static final String RENDITONS_RELATIVE_PATH = "jcr:frozenNode/jcr:content/renditions";
	public static final String JCR_CONTENT_NODE_PROPERTY = "jcr:content";
	public static final String NAME_NODE_PROPERTY = "cq:name";
	public static final String TITLE_NODE_PROPERTY = "dc:title";
	public static final String METADATA_NODE_PROPERTY = "metadata";
	
	   private Resource resource;
	   private Version version;
	   private int index;
	   
	   private String versionString;
	   private String id;
	   private String label;
	   private String comment;
	   private String name;
	   private String title;
	   private Calendar created;
	   private Calendar deleted;
	   private String renditionsPath;
	   private String path;
	   
	   public HistoryItem() {
		   //No-op
	   }

	public HistoryItem init(Resource resource, Version version) {
		this.resource = resource;
		this.version = version;
		
		init();
		
		return this;
	}
	
	private void init () {
		Node resourceNode = resource.adaptTo(Node.class);

		try {			
			versionString = version.getName();
			id = version.getIdentifier();
			label = versionString; //from sample i have of json return, this looks to be same as id
			comment = "";  //TODO
			name = resourceNode.getName(); //this is the node name of the resource (as opposed to version)
			title = resourceNode.getNode(JCR_CONTENT_NODE_PROPERTY + "/" + METADATA_NODE_PROPERTY).getProperty(TITLE_NODE_PROPERTY).getString(); //this is the name of the resource (as opposed to version)
			created = version.getCreated();
			deleted = null; //TODO
			path = version.getPath();
			renditionsPath = path + "/" + RENDITONS_RELATIVE_PATH;
		} catch (RepositoryException e) {
			logger.error("init - RepositoryException when trying to get property: Exception={}", e);
		}
	}
	
	public String getVersion() {
		return versionString;
	}
	
	public String getId() {
		return id;
	}
	
	public String getLabel() {
		return label;
	}
	
	public String getComment() {
		return comment;
	}
	
	public String getName() {
		return name;
	}
	
	public String getTitle() {
		return title;
	}
	
	public Calendar getCreated() {
		return created;
	}
	
	public Calendar getDeleted() {
		return deleted;
	}
	
	public String getRenditionsPath() {
		return renditionsPath;
	}
	
	public String getPath() {
		return path;
	}

	public int getIndex() {
		return index;
	}

	public void setIndex(int index) {
		this.index = index;
	}
}
