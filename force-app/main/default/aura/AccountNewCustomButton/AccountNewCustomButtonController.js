({
    init : function (component) {
        // Find the component whose aura:id is "flowId"
        var flow = component.find("flowId");       // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("Account_New");
    },

    closeModel : function(component, event, helper){
        var action = component.get("c.getListViews");

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
               var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Account"
                });
                navEvent.fire();
            }
        });
    $A.enqueueAction(action);
    },

    redirectToSobject: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": event.getParam('srId'),
                    "actionName":"view"
                }
            },
            focus: true
        }).then(function(newTabId){
            workspaceAPI.getEnclosingTabId()
            .then(function(enclosingTabId) {
                workspaceAPI.closeTab({tabId : enclosingTabId});
            });
            workspaceAPI.focusTab(newTabId);
        });
     }
})