public with sharing class DocketAttachmentTriggerHandler {
    public DocketAttachmentTriggerHandler() {

    }
    public static void deleteFiles (List<Docket_Attachment__c> docketsList){
        try{
            Set<String> allLinkedIds = new Set<String>();
            List<ContentDocument > allContentDocumentList = new List<ContentDocument >();
            for(Docket_Attachment__c da  :docketsList){
                allLinkedIds.add(da.Id);
            }
            for(ContentDocumentLink adl: [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: allLinkedIds]){
                ContentDocument conDoc = new ContentDocument(Id=adl.ContentDocumentId);
                allContentDocumentList.add(conDoc);
            }
            if(allContentDocumentList.size()>0){
                delete allContentDocumentList;
            }
        }catch(Exception e){
            System.debug('Exception in Docket Attachment after delete trigger error is : '+ e.getMessage());
        }
    }
}