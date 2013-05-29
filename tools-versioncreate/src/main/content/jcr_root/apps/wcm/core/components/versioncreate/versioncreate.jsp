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

  ==============================================================================

  Version Creation

  Implements the version creation component.

--%><%@page import="com.day.cq.widget.HtmlLibraryManager"%>
<%@ page contentType="text/html" pageEncoding="utf-8"%><%
%><%@include file="/libs/foundation/global.jsp"%><%
%><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html>
<head>
    <title>CQ5 WCM | Version Creation </title>
    <meta http-equiv="Content-Type" content="text/html; utf-8" />
    <script src="/libs/cq/ui/resources/cq-ui.js" type="text/javascript"></script>
    <%
    HtmlLibraryManager htmlMgr = sling.getService(HtmlLibraryManager.class);
    if (htmlMgr != null) {
        htmlMgr.writeIncludes(slingRequest, out, "cq.widgets");
    }
    %>
    <style type="text/css">
        #treeProgress {
            display: block;
            background-color: white;
            width:100%;
            min-height:400px;
            height:100%;
            border: 1px solid #888888;
            overflow: scroll;
            overflow-x: auto;  
        }
    </style>
</head>
<body>
<h1>Create Versions</h1>
<form target="treeProgress" action="<%= resource.getPath() %>.html" method="POST" id="treeProgress_form">
    <input type="hidden" id="path" name="path" value="/content">
    <table class="form">
        <tr>
            <td><label for="fakePathField">Start Path:</label></td>
            <td><div id="fakePath">&nbsp;</div><br>
                <small>Select location start version creation</small>
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <input id="recursive" name="recursive" type="checkbox" checked value="true">
                <label for="recursive">Recursive</label>
            </td>
        </tr>
        <tr>
            <td><label for="label">Revision Label:</label></td>
            <td><input id="label" name="label" type="text"><br/><small>Leave empty for default</small></td>
        </tr>
        <tr>
            <td><label for="comment">Revision Comment:</label></td>
            <td><textarea id="comment" name="comment"></textarea></td>
        </tr>
        <tr>
            <td></td>
            <td>
                <input type="hidden" name="cmd" value="dryrun" id="cmd">
                <input type="button" value="Dry Run" onclick="document.getElementById('cmd').value='dryrun'; document.getElementById('treeProgress_form').submit();">
                <input type="button" value="Create" onclick="document.getElementById('cmd').value='create'; document.getElementById('treeProgress_form').submit();">
            </td>
        </tr>
    </table>
</form><br>
    <iframe name="treeProgress" id="treeProgress">
    </iframe>
        <script>
            // provide a path selector field with a repository browse dialog
            CQ.Ext.onReady(function() {
                var w = new CQ.form.PathField({
                    //"applyTo": "path",
                    renderTo: "CQ",
//                    "content": "/content",
                    rootPath: "/",
                    predicate: "hierarchy",
                    hideTrigger: false,
                    showTitlesInTree: false,
                    name: "fakePathField",
                    value: "/content",
                    width: 400,
                    listeners: {
                        render: function() {
                            this.wrap.anchorTo("fakePath", "tl");
                        },
                        change: function (fld, newValue, oldValue) {
                            document.getElementById("path").value = newValue;
                        },
                        dialogselect: function(fld, newValue) {
                            document.getElementById("path").value = newValue;
                        }
                    }
                });
            });
        </script>
</body>
</html>
