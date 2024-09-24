trigger DocketAttachmentTrigger on Docket_Attachment__c (before delete) {
	if(trigger.isbefore && trigger.isdelete) // Using context variable.
    {
        DocketAttachmentTriggerHandler.deleteFiles(trigger.old);
        
    }
}