<%@ page import="com.day.cq.wcm.api.WCMMode,com.day.cq.reporting.helpers.Util" %>
<%--
  Copyright 1997-2008 Day Management AG
  Barfuesserplatz 6, 4001 Basel, Switzerland
  All Rights Reserved.

  This software is the confidential and proprietary information of
  Day Management AG, ("Confidential Information"). You shall not
  disclose such Confidential Information and shall use it only in
  accordance with the terms of the license agreement you entered into
  with Day.

  ==============================================================================

  Default init script.

  Draws the WCM initialization code. This is usually called by the head.jsp
  of the page. If the WCM is disabled, no output is written.

  ==============================================================================

--%><%@include file="/libs/foundation/global.jsp" %><%
%><%@ page import="com.day.cq.wcm.api.WCMMode" %>
<%
%><cq:includeClientLib categories="cq.wcm.edit,cq.search,cq.wcm.reports" /><%
if ((WCMMode.fromRequest(request) != WCMMode.DISABLED)
        && !Util.isSingleViewRendering(slingRequest)) {
    String dlgPath = null;
    if (editContext != null && editContext.getComponent() != null) {
        dlgPath = editContext.getComponent().getDialogPath();
    }
    %>
    <script type="text/javascript" >
        var fct = function() {
            CQ.WCM.launchSidekick("<%= currentPage.getPath() %>", {
                propsDialog: "<%= dlgPath == null ? "" : dlgPath %>",
                locked: <%= currentPage.isLocked() %>,
                previewReload: true
            });
        };
        window.setTimeout(fct, 1);
    </script><%
}
%>