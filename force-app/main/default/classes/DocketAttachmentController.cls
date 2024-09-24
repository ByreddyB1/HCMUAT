public without sharing class DocketAttachmentController {
    @AuraEnabled
    public Static string uploadAttachment(string docAttchId,string contentVersionId){
        try{
            String returnString='Fail';

            if(contentVersionId == null || docAttchId == null) { return null; }

            ContentDocumentLink cdl = new ContentDocumentLink();

            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
            cdl.LinkedEntityId = docAttchId;
			cdl.Visibility = 'AllUsers';
            
            insert cdl;

            returnString='Success';

            return returnString;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public Static List<Docket_Attachment_Type__mdt> fetchInitialDetails(){
        Map<String, Docket_Attachment_Type__mdt> mapEd = Docket_Attachment_Type__mdt.getAll();

        return mapEd.values();
    }
}