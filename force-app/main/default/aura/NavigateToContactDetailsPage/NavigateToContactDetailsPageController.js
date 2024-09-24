({
    invoke : function(component, event, helper) {
        const url1 = window.location.href;
//const url2 = document.URL;
        var recordId=component.get( "v.contactId" );
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            
        
            workspaceAPI.closeTab({tabId: focusedTabId,});
        })
        .catch(function(error) {
            console.log(error);
        });
        window.open('/'+recordId,'_self');
        
        /*var redirectToNewRecord = $A.get( "e.force:navigateToSObject" );
    
        redirectToNewRecord.setParams({
        "recordId": component.get( "v.contactId" ),
        "slideDevName": "detail"
        });
        redirectToNewRecord.fire();*/
        
    
    }
    })