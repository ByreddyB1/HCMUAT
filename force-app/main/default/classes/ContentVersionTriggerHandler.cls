public class ContentVersionTriggerHandler {
    public static void afterInsert( List<ContentVersion > contentVersionList ) {
        Set<Id> contentDocumentIdSet = new Set<Id>();
        
        for(ContentVersion cv:contentVersionList)
        {
            if(cv.ContentDocumentId != null && cv.IsLatest==true)
            {
                contentDocumentIdSet.add(cv.ContentDocumentId);
            }
        }
        for(ContentDocumentLink abc: [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet ]){
            List<Docket_Attachment__c> docketAttList= new List<Docket_Attachment__c>();
            if(abc.LinkedEntityId.getSobjectType()==Docket_Attachment__c.SobjectType){
                docketAttList.add(new Docket_Attachment__c(Id=abc.LinkedEntityId,Attachment_Backup_Status__c='Not Started'));
            }
            if(docketAttList.size()>0){
                update docketAttList;
            }
        }
    }
}