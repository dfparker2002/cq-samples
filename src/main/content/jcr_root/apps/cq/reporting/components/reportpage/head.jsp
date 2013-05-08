<%@include file="/libs/foundation/global.jsp" %><%
%><%@ page import="com.day.cq.commons.Doctype, org.apache.commons.lang3.StringEscapeUtils" %><%
    String xs = Doctype.isXHTML(request) ? "/" : "";
%><head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8"<%=xs%>>
    <meta http-equiv="keywords" content="<%= StringEscapeUtils.escapeHtml4(WCMUtils.getKeywords(currentPage)) %>"<%=xs%>>
    <cq:include script="init.jsp"/>
    <cq:include script="stats.jsp"/>
    <% currentDesign.writeCssIncludes(pageContext); %>
    <!-- Common report style (so we won't have to copy it for each report type) -->
    <link rel="stylesheet" href="/etc/designs/reports/report.css" type="text/css">
    <title><%= currentPage.getTitle() == null ? StringEscapeUtils.escapeHtml4(currentPage.getName()) : StringEscapeUtils.escapeHtml4(currentPage.getTitle()) %></title>
    
    <script>
    function convertJSON2CSV(colArray, objArray)
    {
        var dataArray = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
		var headingArray = typeof colArray != 'object' ? JSON.parse(colArray) : colArray;
		
        var str = '';
		var line = '';
		var orderedColums = [];
		
		//set out the column names
		for (var propertyName in headingArray) {
			
			if(line != ''){
			   line += ','
			}
			
			line += propertyName;
			orderedColums.push(propertyName);
		}
		
		str += line + '\r\n';

		//get data lines as per columns
        for (var i = 0; i < dataArray.length; i++) {
            line = '';
			var dataValues = dataArray[i]; 
			
			for (var j = 0; j < orderedColums.length; j++) {
				var colName = orderedColums[j];
				var dataValue = '';
				
                if(line != ''){
                   line += ','
                 }
				
				if (colName in dataValues) {
					dataValue = dataValues[colName];
					
					 if(typeof dataValue != 'object' ){  
						line += '"' + dataValue + '"';
					}else{
						line += '"' + dataValue.display + '"';
					}
				}
			}

            str += line + '\r\n';
        }

        return str;
    }
    
    function downloadcsv(str){
    
        if (navigator.appName != 'Microsoft Internet Explorer')
        {
            window.open('data:text/csv;charset=utf-8,' + escape(str));
        }
        else
        {
            var popup = window.open('','csv','');
            popup.document.body.innerHTML = '<pre>' + str + '</pre>';
        }
    
    
    }
    
    function exportCSV(){
          var rep = CQ.reports.Report.theInstance;
          var repurl= rep.reportPath + "." + rep.reportSelector + CQ.HTTP.EXTENSION_JSON;
          CQ.HTTP.get(repurl, function(options, success, response) {
              if (success) {
                  var repData = CQ.Util.formatData(CQ.Ext.util.JSON.decode(response.responseText));
                  var csv = convertJSON2CSV(JSON.parse(CQ.Ext.util.JSON.encode(repData.dataTypes)), JSON.parse(CQ.Ext.util.JSON.encode(repData.hits)));
                  downloadcsv(csv);
              }
          }, this);
    }
    </script>
</head>