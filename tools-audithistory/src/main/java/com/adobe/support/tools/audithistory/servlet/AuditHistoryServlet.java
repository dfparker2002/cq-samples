package com.adobe.support.tools.audithistory.servlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.jcr.RepositoryException;
import javax.jcr.Session;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletResponse;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ValueMap;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;
import org.apache.sling.commons.json.JSONException;
import org.apache.sling.commons.json.io.JSONWriter;
import org.apache.sling.jcr.api.SlingRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.day.cq.audit.AuditLog;
import com.day.cq.audit.AuditLogEntry;
import com.day.cq.commons.SlingRepositoryException;
import com.day.cq.replication.ReplicationAction;
import com.day.cq.search.PredicateGroup;
import com.day.cq.search.Query;
import com.day.cq.search.QueryBuilder;
import com.day.cq.search.result.Hit;
import com.day.cq.search.result.SearchResult;
import com.day.cq.wcm.api.PageEvent;
import com.day.cq.wcm.api.PageModification.ModificationType;

/**
 * @scr.component immediate="true" metatype="no" 
 * @scr.service interface="javax.servlet.Servlet" 
 * @scr.property name="service.description" value="Provides a recursive audit history for the resource being called" 
 * @scr.property name="service.vendor" value="Adobe Support" 
 * @scr.property name="sling.servlet.resourceTypes" value="sling/servlet/default"
 * @scr.property name="sling.servlet.selectors" value="changeaudithistory"
 * @scr.property name="sling.servlet.extensions" value="json"
 */
public class AuditHistoryServlet extends SlingSafeMethodsServlet {
	/**
	 * Generated serialVersionUID
	 */
	private static final long serialVersionUID = -2454551163118822579L;
	
    /**
     * default log
     */
    private static final Logger log = LoggerFactory.getLogger(AuditHistoryServlet.class);
    
    /**
     * Used to query the repository.
     *  
     * @scr.reference 
     */
    private QueryBuilder builder;
    
    /** 
     * Used to access the audit data of a resource path
     * 
     * @scr.reference 
     */
    protected AuditLog auditLog;
    
    /** 
     * Access to the repository
     * 
     * @scr.reference 
     */
    protected SlingRepository repo;
	
	/**
	 * The max results that should be returned in the query.  
	 * TODO Ideally this would be configurable via OSGi or via a selector.
	 */
	public static final int MAX_QUERY_RESULTS = 25;
	
	/**
	 * The max results that should be returned in the audit log.  
	 * TODO Ideally this would be configurable via OSGi or via a selector.
	 */
	public static final int MAX_AUDIT_RESULTS = 15;

	@Override  
    protected void doGet(SlingHttpServletRequest request, SlingHttpServletResponse response) throws ServletException, IOException {
		//Get the resource for the path
		Resource resource = request.getResource();
		
		//Check we found a resource
		if (resource == null) {
			response.sendError(HttpServletResponse.SC_NOT_FOUND);
			return;
		}
		
		try {
			response.setContentType("application/json");
			response.setCharacterEncoding("utf-8");
			final JSONWriter writer = new JSONWriter(response.getWriter());
			writeOutput(resource, writer);
			
		} catch (RepositoryException e) {
			log.error("an unhandled repository exception occured: {}", e);
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			return;
		} catch (JSONException e) {
			log.error("an error occurred writing the JSON response: {}", e);
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			return;
		}
    }  
	
	private void writeOutput(Resource resource, JSONWriter writer) throws RepositoryException, JSONException {
		LinkedHashMap<String, ValueMap> items = executeQuery(resource);
		Iterator<Entry<String, ValueMap>> iterator = items.entrySet().iterator();
		
		writer.object();
		writer.key("results");
		writer.value(items == null ? 0 : items.size());
		
        writer.key("entries");
        writer.array();
		
        //Loop over each piece of content that is marked as being changed
		while (iterator.hasNext()) {
			Map.Entry<String, ValueMap> entry = iterator.next();
			
			//TODO Check that it hasn't already been added to our list
			
			LinkedHashMap<String,AuditLogEntry> auditEntries = getAuditHistory(entry.getKey());
			
			//Write out the content resource properties that are relevant
            writer.object();
            writer.key("path");
            writer.value(entry.getKey());
			
            //Write out the audit logs of this piece of content
	        writer.key("auditLogs");
	        writer.array();
			
	        Iterator<Entry<String, AuditLogEntry>> auditIterator = auditEntries.entrySet().iterator();
	        
	        //loop over each audit log entry for the piece of content
	        while (auditIterator.hasNext()) {
	        	Map.Entry<String, AuditLogEntry> auditEntry = auditIterator.next();
	        
                writer.object();
                writer.key("type");
                writer.value(auditEntry.getKey());
                writer.key("date");
                writer.value(auditEntry.getValue().getTime().toString());
                writer.key("user");
                writer.value(auditEntry.getValue().getUserId());
                writer.endObject();
	        }
	        
	        writer.endArray();
	        writer.endObject();
		}
		
        writer.endArray();
        writer.endObject();
	}
	
	private Map<String, String> buildQueryDescription(Resource resource) {
		String searchPath = "/var/audit/com.day.cq.wcm.core.page" + resource.getPath();
		
		if (log.isDebugEnabled())
			log.debug("searching under path {}", searchPath);
		
		Map<String, String> map = new HashMap<String, String>();
		
		map.put("type", "cq:AuditEvent");
		map.put("path", searchPath);
		map.put("property", "type");
		map.put("property.1_value", "PageModified");
		map.put("property.2_value", "PageCreated");
		map.put("property.3_value", "PageDeleted");
		map.put("property.4_value", "VersionCreated");
		map.put("orderby", "@cq:time");
		map.put("orderby.sort", "desc");
		map.put("p.limit", Integer.toString(MAX_QUERY_RESULTS));
		
		return map;
	}
	
	private LinkedHashMap<String, ValueMap> executeQuery(Resource resource) throws RepositoryException {
		Map<String, String> queryDescription = buildQueryDescription(resource);
		LinkedHashMap<String, ValueMap> hits = new LinkedHashMap<String, ValueMap>();
		Session adminSession = null;
		
		
		try {
			adminSession = repo.loginAdministrative(null);
			
			//TODO need admin session here?
			Query query = builder.createQuery(PredicateGroup.create(queryDescription), adminSession);
			
			SearchResult result = query.getResult();
			
	        for (Hit hit : result.getHits()) {
	        	ValueMap properties = hit.getProperties();
	        	String hitPath = properties.get("path", String.class);
	            hits.put(hitPath, properties);
	        }
		}
		finally {
			if (adminSession != null && adminSession.isLive())
				adminSession.logout();
		}
		
		return hits;
	}
	
	/**
	 * Ripped from {link com.day.cq.wcm.core.impl.servlets.AuditLogTableExportServlet AuditLogTableExportServlet}
	 * 
	 * @param path
	 * @return
	 */
	private LinkedHashMap<String,AuditLogEntry> getAuditHistory(String path) {
		AuditLogEntry[] events = null;
		LinkedHashMap<String,AuditLogEntry> entries = new LinkedHashMap<String,AuditLogEntry>();
		
		if (auditLog == null) {
			log.error("could not get audit details of resource path as auditlog is null: {}", path);
		}
		
		events = auditLog.getLatestEvents(new String[] {PageEvent.EVENT_TOPIC, ReplicationAction.EVENT_TOPIC}, path, MAX_AUDIT_RESULTS);
		
		if ( events != null ) {
            for(int i=0; i<events.length; i++ ) {            	
                final String text;
                
                if ( events[i].getCategory().equals(ReplicationAction.EVENT_TOPIC) ) {
                	//There might be a replication event
                    text = events[i].getType();
                } else {
                	//Or a page level event
                    ModificationType actionType = ModificationType.fromName(events[i].getType());
                    switch (actionType) {
                        case CREATED : text = "Created";
                                       break;
                        case DELETED: text  = "Deleted";
                                      break;
                        case MODIFIED: text  = "Modified";
                                       break;
                        case VERSION_CREATED: text = "Version Created";
                                       break;
                        case MOVED: text = "Moved";
                                           break;
                        default: text = "Unknown";
                    }
                }
                
                entries.put(text, (AuditLogEntry) events[i]);
            }
		}
		
		return entries;
	}
}
