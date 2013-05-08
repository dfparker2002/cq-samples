<%@ page import="com.day.cq.commons.jcr.JcrConstants,
                com.day.cq.reporting.SnapshotType,
                com.day.cq.reporting.helpers.Const,
                org.apache.sling.api.resource.NonExistingResource,
                org.apache.sling.api.resource.Resource,
                org.apache.sling.api.resource.ResourceResolver,
                org.apache.sling.api.resource.ResourceUtil,
                org.apache.sling.api.resource.ValueMap,
                com.day.cq.reporting.helpers.Util,
                org.apache.commons.lang3.StringEscapeUtils"
%><%@page session="false"%><%@include file="/libs/foundation/global.jsp"%><%

    Resource pageRsc = (Resource) resource;         // required for IntelliJ code completion

    // resolve correct component type
    ResourceResolver resolver = pageRsc.getResourceResolver();
    Resource report = resolver.getResource(pageRsc, "report");
    String actualResourceType = ((report == null) || (report instanceof NonExistingResource)
            ? "cq/reporting/components/reportbase" : report.getResourceType());
    String description = currentPage.getProperties().get("jcr:description", String.class);
    ValueMap reportProps = ResourceUtil.getValueMap(report);
    String snapshotMode = reportProps.get(Const.PN_SNAPSHOTS, String.class);
    String actualTitle = currentPage.getTitle();
    actualTitle = (actualTitle != null ? actualTitle : currentPage.getName());
    actualTitle = reportProps.get(JcrConstants.JCR_TITLE, actualTitle);
    description = reportProps.get(JcrConstants.JCR_DESCRIPTION, description);
    boolean hasSnapshots = ((snapshotMode != null)
            && !snapshotMode.equals(SnapshotType.NEVER.getStringRep()));
    String switchCss = (hasSnapshots ? "cq-reports-snapshots-on"
            : "cq-reports-snapshots-off");
    boolean isSingleViewRendering = Util.isSingleViewRendering(slingRequest);
%><body<%= isSingleViewRendering ? " class=\"cq-reports-singleviewrender\"" : "" %>>

    <%
        // prevent header in single view rendering
        if (isSingleViewRendering) {
    %><div id="header" style="display: none;"></div><%
        }
    %>
    <script src="/libs/cq/ui/resources/cq-ui.js" type="text/javascript"></script>

    <%
        if (!isSingleViewRendering) {
    %><h2 class="<%= switchCss %>"><%= StringEscapeUtils.escapeHtml4(actualTitle) %> 
    	(<a href="javascript:exportCSV()">Export</a>)
    </h2><%
        }
    %>
<%
    if (description != null) {
%><p><%= StringEscapeUtils.escapeHtml4(description) %></p><%
    }
%>

    <cq:include path="report" resourceType="<%= StringEscapeUtils.escapeHtml4(actualResourceType) %>"/>

    <div id="CQ">
        <div id="reportView">
        </div>
    </div>

</body>
