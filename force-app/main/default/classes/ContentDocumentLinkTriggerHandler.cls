public without sharing class ContentDocumentLinkTriggerHandler {
    public static void beforeInsert(List<ContentDocumentLink> conDocLinkList) {
        for(ContentDocumentLink cdl: conDocLinkList){
            String linkedEntityIdString = cdl.LinkedEntityId;

            System.debug('linkedEntityIdString value: ' + linkedEntityIdString);
            System.debug('cdl.Visibility value: ' + cdl.Visibility);

            // Check to see if the ContentDocumentLink is related to a Docket Attachment and is only shared to InternalUsers. If so, Nintex generated it and we need to set it to AllUsers.
            if(linkedEntityIdString.startsWith('a0K') && cdl.Visibility != 'AllUsers'){
                cdl.Visibility = 'AllUsers';
            }
        }
    }
}