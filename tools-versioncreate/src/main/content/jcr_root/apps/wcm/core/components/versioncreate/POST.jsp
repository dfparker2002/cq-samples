<%--

  ADOBE CONFIDENTIAL
  __________________

   Copyright 2011 Adobe Systems Incorporated
   All Rights Reserved.

  NOTICE:  All information contained herein is, and remains
  the property of Adobe Systems Incorporated and its suppliers,
  if any.  The intellectual and technical concepts contained
  herein are proprietary to Adobe Systems Incorporated and its
  suppliers and are protected by trade secret or copyright law.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe Systems Incorporated.
  --%><%@page import="org.apache.sling.api.resource.ResourceResolver"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.slf4j.Logger"%>
<%@page import="org.slf4j.LoggerFactory"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="com.day.cq.wcm.api.PageManager"%>
<%@page import="com.day.cq.wcm.api.Page"%>
<%@page import="org.apache.sling.api.resource.Resource"%>
<%@page import="javax.jcr.RepositoryException"%>
<%@page import="org.apache.commons.lang3.StringEscapeUtils"%>
<%@page import="javax.jcr.nodetype.NodeType"%>
<%@page import="org.apache.jackrabbit.util.Text"%>
<%@page import="com.day.cq.commons.LabeledResource"%>
<%@page import="java.util.Iterator"%>
<%@page import="javax.jcr.nodetype.NodeType"%>
<%@page import="javax.jcr.Node"%>
<%
%><%@page session="false" contentType="text/html" pageEncoding="utf-8" %><%
%><%@taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0" %><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><cq:defineObjects /><%

    String path = slingRequest.getParameter("path");
    String label = slingRequest.getParameter("label");
    String comment = slingRequest.getParameter("comment");
    boolean recursive = "true".equals(slingRequest.getParameter("recursive"));
    boolean dryRun = "dryrun".equals(slingRequest.getParameter("cmd"));
%><html><head>
    <style type="text/css">
        div {
            font-family:arial,tahoma,helvetica,sans-serif;
            font-size:11px;
            white-space:nowrap;
        }
        .action {
            display: inline;
            /*width: 130px;*/
            float: left;
            overflow: hidden;
        }
        .error {
            color: red;
            font-weight: bold;
        }
        .title {
            display: inline;
            width: 150px;
            float: left;
            margin: 0 8px 0 0;
            overflow: hidden;
        }
        .activate {
            color: #222222;
        }
        .ignore {
            color: #888888;
        }
        .cf {
            color: #888888;
        }
        .path {
            display: inline;
            width: 100%;
        }

    </style>
    <script type="text/javascript">
        var started = false;

        function start() {
            started = true;
        }
        function stop() {
            started = false;
        }
        function isStarted() {
            return started;
        }
        function jump() {
            window.scrollTo(0, 100000);
        }
    </script>
</head>
<body bgcolor="white">
    <div>
    <%
        Processor p = new Processor(slingRequest.getResourceResolver(), new PrintWriter(out));
        p.setRecursive(recursive);
        p.setDryRun(dryRun);
        p.setLabel(label);
        p.setComment(comment);
        p.process(path);
    %></div>
</body>
</html><%!

    private static class Processor {

        /**
         * default logger
         */
        private static final Logger log = LoggerFactory.getLogger(Processor.class);

        private static final SimpleDateFormat DATE_FMT = new SimpleDateFormat("EEE MMM dd yyyy HH:mm:ss 'GMT'Z");

        private final ResourceResolver resolver;
        
        private final PageManager pageManager;

        private final PrintWriter out;

        private boolean recursive;
        
        private String label;
        
        private String comment;

        private boolean dryRun;

        private int tCount;

        private int aCount;

        private long lastUpdate;

        private Processor(ResourceResolver resolver, PrintWriter out) {
            this.resolver = resolver;
            this.pageManager = resolver.adaptTo(PageManager.class);
            this.out = out;
        }

        public void setRecursive(boolean recursive) {
            this.recursive = recursive;
        }

        public void setDryRun(boolean dryRun) {
            this.dryRun = dryRun;
        }
        
        public void setLabel(String label) {
            this.label = label;
        }
        
        public void setComment(String comment) {
            this.comment = comment;
        }

        public void process(String path) {
            if (path == null || path.length() == 0) {
                out.printf("<div class=\"error\">No start path specified.</div>");
                return;
            }
            // snip off all trailing slashes
            while (path.endsWith("/")) {
                path = path.substring(0, path.length() - 1);
            }
            // reject root
            if (path.length() == 0) {
                out.printf("<div class=\"error\">Cowardly refusing to process '/'</div>");
                return;

            }
            Resource res = resolver.getResource(path);
            if (res == null) {
                out.printf("<div class=\"error\">The resource at '%s' does not exist.</div>", path);
                return;
            }

            out.printf("%n<script>start()</script>%n");
            String cmd = dryRun ? "Simulating" : "Starting";
            out.printf("<strong>%s version creation of path \"%s\"</strong><br>", cmd, path);
            out.printf("<hr size=\"1\">%n");

            long startTime = System.currentTimeMillis();
            tCount = aCount = 0;
            try {
                process(res);
                long endTime = System.currentTimeMillis();
                out.printf("<hr size=\"1\"><br><strong>%sCreated %d versions, after processing %d nodes in %d seconds.</strong><br>",
                    (dryRun ? "Simulation: " : ""), aCount, tCount, (endTime-startTime)/1000);

            } catch (Exception e) {
                out.printf("<div class=\"error\">Error during processing: %s</div>", e.toString());
                log.error("Error during version creation of " + path, e);
            }

            out.printf("%n<script>jump();stop();</script>%n");
            out.flush();
        }

        private boolean process(Resource res)
                throws RepositoryException {

            // we only process hierarchy nodes
            Node node = res.adaptTo(Node.class);
            if (!node.isNodeType(NodeType.NT_HIERARCHY_NODE)) {
                return false;
            }
            
            // check if node has jcr:content
            Node versionable = node;
            if (node.hasNode(Node.JCR_CONTENT)) {
                versionable = node.getNode(Node.JCR_CONTENT);
            }
            
            String title = Text.getName(res.getPath());
            LabeledResource lr = res.adaptTo(LabeledResource.class);
            if (lr != null && lr.getTitle() != null) {
                title = lr.getTitle();
            }
            out.printf("<div><b>%s</b> %s</div>", StringEscapeUtils.escapeHtml4(title), res.getPath());
            
            if (versionable.isNodeType(NodeType.MIX_VERSIONABLE)) {
                Page page = res.adaptTo(Page.class);
                PageManager pMgr = resolver.adaptTo(PageManager.class);
                if (page != null) {
                	boolean createRevison = true;
                	
                	if (createRevison) {
	                    try {
	                    	if (!dryRun) {
	                    		if (label != null) {
	                    			pMgr.createRevision(page, label, comment);
	                    		} else {
	                        		pMgr.createRevision(page);
	                    		}
	                    	}
                            out.printf("<div class=\"action activate\">&nbsp;&nbsp;created&nbsp;&nbsp;</div>");
                            aCount++;
	                    } catch (com.day.cq.wcm.api.WCMException e) {
	                    	out.printf("<div class=\"action error\">&nbsp;&nbsp;error&nbsp;&nbsp;</div>");
	                    }
                	} else {
                		out.printf("<div class=\"action ignore\">&nbsp;&nbsp;ignore (has versions already)</div><br>");
                	}
                }
            } else {
                out.printf("<div class=\"action ignore\">&nbsp;&nbsp;ignore (not versionable)</div><br>");
            }

            tCount++;

            out.flush();
            long now  = System.currentTimeMillis();
            if (now - lastUpdate > 1000L) {
                lastUpdate = now;
                out.printf("<script>jump();</script>%n");
                out.flush();
            }
            if (recursive) {
                Iterator<Resource> iter = resolver.listChildren(res);
                while (iter.hasNext()) {
                    process(iter.next());
                }
            }
            return true;
        }
    }
%>