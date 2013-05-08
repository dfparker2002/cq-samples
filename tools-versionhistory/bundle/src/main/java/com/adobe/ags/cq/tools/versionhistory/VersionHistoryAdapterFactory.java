package com.adobe.ags.cq.tools.versionhistory;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.adapter.AdapterFactory;
import org.apache.sling.api.resource.Resource;
import org.osgi.service.component.ComponentContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @scr.component immediate="true" metatype="false"
 * @scr.service 
 * @scr.property name="service.pid" value="%VersionHistoryAdapterFactory.pid" 
 * @scr.property name="service.description" value="%VersionHistoryAdapterFactory.description" 
 * @scr.property name="name="service.vendor" value="%VersionHistoryAdapterFactory.vendor"
 */
public class VersionHistoryAdapterFactory implements AdapterFactory {
	private static final Logger log = LoggerFactory.getLogger(VersionHistoryAdapterFactory.class);
	
	private static final Class<HistoryResource> VERSION_HISTORY = HistoryResource.class;

    /**
     * @scr.property name="adapters"
     */
    public static final String[] ADAPTER_CLASSES = {
    	VERSION_HISTORY.getName()
    };
    
    /**
     * @scr.property name="adaptables"
     */
    public static final String[] ADAPTABLE_CLASSES = {
        Resource.class.getName(),
        SlingHttpServletRequest.class.getName()
    };	

	public <AdapterType> AdapterType getAdapter(Object adaptable, Class<AdapterType> type) {
        if (adaptable instanceof Resource) {
            return getAdapter((Resource) adaptable, type);
        } else if (adaptable instanceof SlingHttpServletRequest) {
            return getAdapter((SlingHttpServletRequest) adaptable, type);
        } else {
            log.warn("Error handling adaptTo {}", adaptable.getClass().getName());
            return null;
        }
	}
	
	
    private <AdapterType> AdapterType getAdapter(SlingHttpServletRequest slingRequest, Class<AdapterType> type) {
        return getAdapter(slingRequest.getResource(), type);
    }
    
    @SuppressWarnings("unchecked")
    private <AdapterType> AdapterType getAdapter(Resource resource, Class<AdapterType> type) {
        try {
            if (type == VERSION_HISTORY) {
                return (AdapterType) new HistoryResource(resource);
            } else {
                log.warn("Unable to adapt resource to requested type {}", type.getName());
                return null;
            }
        } catch (Exception e) {
            log.error("Unable to adapt resource to requested type {}", type.getName());
            return null;
        }
    }
    
    protected void activate(ComponentContext context) {
        log.info("Activating...");
    }
    
    protected void deactivate(ComponentContext context) {
        log.debug("...Deactivating");
    }
    
    protected void modifed(ComponentContext context) {
        log.debug("...Modified...");
    }
}
