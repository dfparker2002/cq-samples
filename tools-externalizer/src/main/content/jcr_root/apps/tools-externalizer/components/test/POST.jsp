<%@page import="com.day.cq.commons.Externalizer,
  						org.apache.sling.api.resource.ResourceResolver,
  						java.util.Arrays"%>
<%
%><%@page session="false" contentType="text/html" pageEncoding="utf-8" %><%
%><%@include file="/libs/foundation/global.jsp"%><%

	Externalizer externalizer = resourceResolver.adaptTo(Externalizer.class);

    String path = slingRequest.getParameter("path");
    String scheme = slingRequest.getParameter("scheme");
    String domainsString = slingRequest.getParameter("domains");
    String[] domains = null;
    
    ResourceResolver resolver = slingRequest.getResourceResolver();
    
    if (domainsString != null) {
    	domainsString = domainsString.trim();
    	
    	if (domainsString.length() > 0) {
    		domains = domainsString.split(",");
    	}
    }   
    
%><html><head>
    <style type="text/css">
        div {
            font-family:arial,tahoma,helvetica,sans-serif;
            font-size:11px;
            white-space:nowrap;
        }
        
        dd {
        	padding-bottom: 20px;
        }
    </style>
</head>
<body bgcolor="white">
    <div>
    	<h2>Parameters</h2>
    	<ul>
    		<li>Path = <%= xssAPI.encodeForHTML(path) %></li>
    		<li>Scheme = <%= xssAPI.encodeForHTML(scheme) %></li>
    		<li>Domains = 
    			<% if (domains != null) { %>
    				<%= xssAPI.encodeForHTML(Arrays.toString(domains)) %>
    			<% } else { %>
    				[No domains given]
    			<% } %>
    		</li>
    	</ul>
    	
    	<h2>Results</h2>
    	<dl>
    		<dt><code>authorLink(ResourceResolver resolver, String path)</code></dt>
    		<dd><%= xssAPI.encodeForHTML(externalizer.authorLink(resolver, path)) %></dd>
    	
    		<dt><code>authorLink(ResourceResolver resolver, String scheme, String path)</code></dt>
    		<dd><%= xssAPI.encodeForHTML(externalizer.authorLink(resolver, scheme, path)) %></dd>
    	
    		<dt><code>publishLink(ResourceResolver resolver, String path)</code></dt>
    		<dd><%= xssAPI.encodeForHTML(externalizer.publishLink(resolver, path)) %></dd>
    	
    		<dt><code>publishLink(ResourceResolver resolver, String scheme, String path)</code></dt>
    		<dd><%= xssAPI.encodeForHTML(externalizer.publishLink(resolver, scheme, path)) %></dd>
    		
    		<%
    			if (domains != null && domains.length > 0) {
    				for (String domain : domains) {
    		%>
			    		<dt><code>externalLink(ResourceResolver resolver, String domain, String path)</code></dt>
			    		<dd>
			    			<strong>domain = <%= xssAPI.encodeForHTML(domain) %></strong> -  
			    			<%
			    			try {
			    			%>
			    				<%= xssAPI.encodeForHTML(externalizer.externalLink(resolver, domain.trim(), path))%>				    			
			    			<%	
			    			}
			    			catch(IllegalArgumentException e) {
		    				%>
		    					<span style="color: red">Invalid Domain given</strong> (not listed in Externalizer config)<br/>
		    					
		    				<%
			    			}
			    			%>	
			    		</dd>
			    				
			    	
			    		<dt><code>externalLink(ResourceResolver resolver, String domain, String scheme, String path)</code> : domain = <%= xssAPI.encodeForHTML(domain) %> </dt>
			    		<dd>
			    			<%
			    			try {
			    			%>
			    				<%= xssAPI.encodeForHTML(externalizer.externalLink(resolver, domain.trim(), scheme, path))%>				    			
			    			<%	
			    			}
			    			catch(IllegalArgumentException e) {
		    				%>
		    					<%= xssAPI.encodeForHTML(domain) %>: <strong>Invalid Domain given</strong> (not listed in Externalizer config)<br/>
		    				<%
			    			}
			    			%>	
			    		</dd>
    					<%			
    				}
    			}
    		%>
    	
    	</dl>
   </div>
</body>
</html>