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
	String defaultScheme = properties.get("scheme", "http");
%><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html>
<head>
    <title>CQ5 WCM | Externalizer Test</title>
    <meta http-equiv="Content-Type" content="text/html; utf-8" />
    <script src="/libs/cq/ui/resources/cq-ui.js" type="text/javascript"></script>
    <script>
    	function submitForm() {
    		document.getElementById('externalizerTest_form').submit();
    	}
    </script>
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
<h1>Externalizer Test</h1>
<p>
	Externalizer: 
	<a href="http://dev.day.com/docs/en/cq/current/developing/externalizer.html">Documentation</a> | 
	<a href="http://dev.day.com/docs/en/cq/current/javadoc/com/day/cq/commons/Externalizer.html">JavaDocs</a>
	(See <a href="http://localhost:4502/crx/de/index.jsp#/crx.default/jcr%3aroot/apps/tools-externalizer/config/SAMPLEcom.day.cq.commons.impl.ExternalizerImpl" x-cq-linkchecker="valid">CRX DE Lite</a> for a sample configuration))
</p>
<form target="externalizerTestResults" action="<%= resource.getPath() %>.html" method="POST" id="externalizerTest_form">
    <input type="hidden" id="path" name="path" value="/content">
    <table class="form">
        <tr>
            <td><label for="fakePathField">Start Path:</label></td>
            <td><div id="fakePath">&nbsp;</div><br>
                <small>Select location to generate URLs with the Externalizer methods</small>
            </td>
        </tr>
        <tr>
            <td><label for="scheme">Scheme:</label></td>
            <td><input id="scheme" name="scheme" type="text" value="<%= defaultScheme %>"></td>
        </tr>
        <tr>
            <td><label for="domains">Domains:</label></td>
            <td>
            	<textarea id="domains" name="domains"></textarea>
            	<br>
                <small>Enter CSV list for any "domains" you also wish to test with the externalizer here.  You must have pre-configured the externalizer with these domain values via Configuration.</small>            
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <input type="button" value="Test" onclick="submitForm();">
            </td>
        </tr>
    </table>
</form><br>
    <iframe name="externalizerTestResults" id="externalizerTestResults" width="100%" height="500">
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