
CQ.wcm.Page.getCreatePageDialog = function(parentPath) {
    var templatesStore = new CQ.Ext.data.Store({
        "proxy": new CQ.Ext.data.HttpProxy({ "url":"/bin/wcm/templates", "method":"GET" }),
        "reader": new CQ.Ext.data.JsonReader(
            { "totalProperty":"results", "root":"templates", "id":"path" },
            [ "path", "title", "description", "thumbnailPath", "iconPath", "ranking" ]
        ),
        "baseParams": { "_charset_":"utf-8", "path":parentPath },
        "listeners": {
            "load": function() {
                this.sort("ranking");
            }
        }

    });

    var dataView = new CQ.Ext.DataView({
        "multiSelect": false,
        "singleSelect": true,
        "emptyText": CQ.I18n.getMessage("No template available"),
        "store": templatesStore,
        "overClass": "x-view-over",
        "itemSelector" :"div.template-item",
        "tpl":new CQ.Ext.XTemplate(
            '<tpl for=".">',
            '<div class="template-item">',
            '<tpl if="thumbnailPath">',
                '<img class="template-thumbnail" src="{[CQ.shared.HTTP.getXhrHookedURL(CQ.shared.HTTP.externalize(CQ.shared.HTTP.encodePath(values.thumbnailPath)))]}">',
                '<div class="template-title">{title}</div>',
                '<div class="template-description">{description}</div>',
            '</tpl>',
            '<tpl if="thumbnailPath == \'\'">',
                '<div class="template-title template-no-thumbnail">{title}</div>',
                '<div class="template-description template-no-thumbnail">{description}</div>',
            '</tpl>',
            '<div style="clear:both"></div>',
            '</div>',
            '</tpl>',
            '<div style="height:5px;overflow:hidden"></div>'),
        "prepareData": function(data) {
            // 900000000: move to the end of the list
            data.ranking = data.ranking != null ? data.ranking : 900000000;
            data.thumbnailPath = data.thumbnailPath ? CQ.HTTP.externalize(data.thumbnailPath) : '';
            data.title = CQ.I18n.getVarMessage(data.title);
            data.description = data.description ? CQ.I18n.getVarMessage(data.description) : "";
            return data;
        }
    });

    var hiddenTemplate =  new CQ.Ext.form.Hidden({"name": "template"});

    //workaround to select a default value. select() must be called at the end of refresh method
    dataView.refresh = function(){
        this.clearSelections(false, true);
        this.el.update("");
        var html = [];
        var records = this.store.getRange();
        if(records.length < 1){
            if(!this.deferEmptyText || this.hasSkippedEmptyText){
                this.el.update(this.emptyText);
            }
            this.hasSkippedEmptyText = true;
            this.all.clear();
            return;
        }
        this.tpl.overwrite(this.el, this.collectData(records, 0));
        this.all.fill(CQ.Ext.query(this.itemSelector, this.el.dom));
        this.updateIndexes(0);

        //CQ: START
        //select first item by default
        this.select(0);
        //CQ: END
    };

   var createDialog = {
        "jcr:primaryType": "cq:Dialog",
        "id": CQ.Util.createId("cq-createdialog"),
        "title":CQ.I18n.getMessage("Create Page"),
        "formUrl": CQ.shared.HTTP.externalize("/bin/wcmcommand"),
        "params": {
            "cmd":"createPageWithCustomProperties",
            "_charset_":"utf-8"
        },
        "height": 520,
        "items": {
            "jcr:primaryType": "cq:Panel",
            "items": {
                "jcr:primaryType": "cq:WidgetCollection",
                "title": {
                    "fieldLabel":CQ.I18n.getMessage("Title"),
                    "allowBlank":false,
                    "name":"title"
                },
                "label": {
                    "fieldLabel":CQ.I18n.getMessage("Name"),
                    "vtype":"itemname",
                    "name":"label"
                },
                "starred": {
                    "fieldLabel":CQ.I18n.getMessage("Starred"),
                    "xtype":"checkbox",
                    "name":"starred"
                },
                /*"message": {
                    "xtype": "label",
                    "text": CQ.I18n.getMessage("Select a page template:")
                },*/
                "template": {
                    "xtype": "panel",
                    //                    "title":CQ.I18n.getMessage("Template"),
                    "border": false,
                    "cls": "cq-template-view",
                    "autoScroll":true,
                    "width": "100%",
                    "autoHeight":false,
                    "height": 350,
                    "items": [
                        hiddenTemplate,
                        dataView
                    ]
                    /*"bbar": new CQ.Ext.PagingToolbar({
                        "store": templatesStore,
                        "pageSize": 3,
                         "autoHeight": "false",
                    }),*/
                    ,"listeners": {
                        "render" : {
                            fn: function() {
                                templatesStore.load();
                            }
                        }
                    }
                }
            }
        },
        "okText":CQ.I18n.getMessage("Create")
    };

    var dialog = CQ.WCM.getDialog(createDialog);

    dialog.on("beforesubmit", function() {
        if(dataView.getSelectedRecords()[0] && dataView.getSelectedRecords()[0].data)
            hiddenTemplate.setRawValue(dataView.getSelectedRecords()[0].data.path);
    });

    dialog.addHidden({ "parentPath":parentPath });

    return dialog;
};

CQ.wcm.Page.getMovePageDialog = function(path, isPage) {
    var data = {
        id: CQ.Util.createId("cq-heavymovedialog"),
        path: path,
        vtype: isPage ? null : "name"
    };

    return new CQ.wcm.HeavyMoveDialog(data);
};

CQ.wcm.Page.getCopyPageDialog = function(path) {
    var dstParentPath = path.substring(0, path.lastIndexOf("/"));
    var dstName = path.substring(path.lastIndexOf("/") + 1);

    var shallow = new CQ.Ext.form.Hidden({
        "name": "shallow",
        "value": false
    });

    var copyDialog = {
        "jcr:primaryType": "cq:Dialog",
        "id": CQ.Util.createId("cq-copydialog"),
        "title":CQ.I18n.getMessage("Copy Page"),
        "formUrl": CQ.shared.HTTP.externalize("/bin/wcmcommand"),
        "params": {
            "cmd":"copyPage",
            "_charset_":"utf-8",
            "before": ""
        },
        "height": 220,
        "items": {
            "jcr:primaryType": "cq:Panel",
            "items": [{
                "xtype": "textfield",
                "fieldLabel":CQ.I18n.getMessage("Copy"),
                "allowBlank":false,
                "name":"srcPath",
                "readOnly": true,
                "value": path
            }, {
                "fieldLabel":CQ.I18n.getMessage("To"),
                "xtype": "pathfield",
                "name":"destParentPath",
                "value": dstParentPath,
                "listeners": {
                    "blur": function() {
                        while (/(.*)\/$/.test(this.getValue())) {
                            this.setValue(this.getValue().replace(/(.*)\/$/, "$1"));
                        }
                    }
                }
            }, shallow, {
                "fieldLabel":CQ.I18n.getMessage("Copy children"),
                "xtype": "checkbox",
                "name":"shallowCbx",
                "checked": true,
                "listeners": {
                    "check": function(box, checked) {
                        shallow.setValue(!checked);
                    }
                }
            }, {
                "xtype": "textfield",
                "fieldLabel":CQ.I18n.getMessage("Copy name"),
                "allowBlank":false,
                "vtype": "itemname",
                "name":"destName",
                "value": dstName
            }]
        },
        "okText":CQ.I18n.getMessage("Copy")
    };

    var dialog = CQ.WCM.getDialog(copyDialog);
    return dialog;
};

CQ.wcm.Page.getCreateAssetShareDialog = function(parentPath) {

    var hiddenAssetShareTemplate = new CQ.Ext.form.Hidden({
                                                              "name":"templateAssetShare",
                                                              "value":"/libs/dam/templates/assetshare"
                                                          });
    var hiddenAssetEditorTemplate = new CQ.Ext.form.Hidden({
                                                               "name":"templateAssetEditor",
                                                               "value":"/libs/dam/templates/asseteditor"
                                                           });
    var hiddenAssetViewerTemplate = new CQ.Ext.form.Hidden({
                                                               "name":"templateAssetViewer",
                                                               "value":"/libs/dam/templates/assetviewer"
                                                           });

    var createAssetShareDialog = {
        "jcr:primaryType": "cq:Dialog",
        "title":CQ.I18n.getMessage("Create Asset Share"),
        "id": CQ.Util.createId("cq-createassetsharedialog"),
        "height": 240,
        "formUrl": CQ.shared.HTTP.externalize("/bin/wcmcommand"),
        "params": {
            "cmd":"createAssetShare",
            "_charset_":"utf-8"
        },
        "items": {
            "jcr:primaryType": "cq:Panel",
            "items": [
                {
                    "fieldLabel":CQ.I18n.getMessage("Title"),
                    "fieldSubLabel":CQ.I18n.getMessage("Optional"),
                    "fieldDescription":CQ.I18n.getMessage('A separate title for the navigation, e.g. "My Asset Share"'),
                    "name":"title",
                    "allowBlank": false
                },
                {
                    "fieldLabel":CQ.I18n.getMessage("Name"),
                    "fieldDescription":CQ.I18n.getMessage('The name that will appear in the URL, e.g. "myassetshare"'),
                    "name":"label",
                    "vtype":"itemname"
                },
                hiddenAssetShareTemplate,
                hiddenAssetEditorTemplate,
                hiddenAssetViewerTemplate
            ]
        },
        "okText":CQ.I18n.getMessage("Create")
    };

    var dialog = CQ.WCM.getDialog(createAssetShareDialog);
    dialog.addHidden({"parentPath":parentPath });
    return dialog;
};