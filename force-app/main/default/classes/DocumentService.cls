@RestResource(urlMapping='/docket/*')
global without sharing class DocumentService {
    private static Integer HTTP_SUCCESS = 200;

    public virtual class DocumentServiceException extends Exception {}

    @HttpGet
    global static void getFile() {
        List<Docket_Attachment__c> daList = new List<Docket_Attachment__c>();
        Docket_Attachment__c daWithFile = new Docket_Attachment__c();
        RestResponse response = RestContext.response;
        Integer numberOfFiles = 0;

        RestRequest request = RestContext.request;

        response.addHeader('Content-Type', 'application/json');

        daList = [SELECT Docket__c, Attachment_Type__c, Attachment_Backup_Status__c, (SELECT ContentDocumentId, ContentDocument.FileExtension FROM ContentDocumentLinks) FROM Docket_Attachment__c WHERE Attachment_Backup_Status__c != 'Complete' ORDER BY Name];

        System.debug('daList value: ' + daList);
        System.debug('daList size: ' + daList.size());

        for(Docket_Attachment__c d: daList){
            numberOfFiles = d.ContentDocumentLinks.size();

            if(d.ContentDocumentLinks.size() > 0){
                daWithFile = d;

                break;
            }
        }

        System.debug('daWithFile value: ' + daWithFile);

        if(numberOfFiles > 0){
            // Set the Docket Attachment as In Progress in case an uncaught error occurs.
            if(daWithFile.Attachment_Backup_Status__c != 'In Progress') {
                daWithFile.Attachment_Backup_Status__c = 'In Progress';

                update daWithFile;
            } else{
                // Update this Docket Attachment that failed so it is not processed again.
                updateFailedDocketAttachment(daWithFile, response);
            }

            List<ContentVersion> cvList = [SELECT VersionData, Title, ContentSize FROM ContentVersion WHERE ContentDocumentId = :daWithFile.ContentDocumentLinks[0].ContentDocumentId AND IsLatest = TRUE];

            System.debug('cvList.ContentSize value: ' + cvList[0].ContentSize);
            System.debug('Limits.getHeapSize() value: ' + Limits.getHeapSize());
            System.debug('Limits.getLimitHeapSize() value: ' + Limits.getLimitHeapSize());

            Integer heapSizeLimit = Integer.valueOf(Label.Heap_Size_Limit);
            system.debug( 'Heap size is ' + limits.getHeapSize() + ' Salesforce enforced Heap size Limit is ' + limits.getLimitHeapSize());
            if(Limits.getHeapSize() < heapSizeLimit) {

                DocumentWrapper responseRec = new DocumentWrapper();

                responseRec.file = cvList[0].VersionData;
                responseRec.docketAttachmentId = daWithFile.Id;
                responseRec.docketId = daWithFile.Docket__c;
                responseRec.contentDocumentId = daWithFile.ContentDocumentLinks[0].contentDocumentId;
                responseRec.contentVersionId = cvList[0].Id;
                responseRec.attachmentType = daWithFile.Attachment_Type__c;
                responseRec.attachmentFileExtension = daWithFile.ContentDocumentLinks[0].ContentDocument.FileExtension;
                responseRec.attachmentTitle = cvList[0].Title;
                responseRec.attachmentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + daWithFile.Id;
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serializePretty(responseRec));

                System.debug('Inside Limits.getHeapSize() value: ' + Limits.getHeapSize());

            } else{
                // Update this Docket Attachment that failed so it is not processed again.
                updateFailedDocketAttachment(daWithFile, response);
            }
        } else{
            response.statusCode = 200;
            response.responseBody = Blob.valueOf('{"message": "No more files need to be backed up today."}');
        }
    }

    // Update this Docket Attachment that failed so it is not processed again.
    public static void updateFailedDocketAttachment (Docket_Attachment__c daWithFile, RestResponse response){
        daWithFile.Attachment_Backup_Status__c = 'Failed';
        daWithFile.Attachment_Backup_Message__c = 'This file could not be backed up.';

        update daWithFile;
        System.debug('Failed daWithFile ' + daWithFile);
        response.statusCode = 500;
        response.responseBody = Blob.valueOf('{"message": This file could not be backed up.}');
    }

    public class DocumentWrapper{
        public Blob file;
        public String docketAttachmentId;
        public String docketId;
        public String contentDocumentId;
        public String contentVersionId;
        public String attachmentType;
        public String attachmentTitle;
        public String attachmentFileExtension;
        public String attachmentURL;
    }

    @HttpPut
    global static void updateDocketAttachment(String docketAttachmentId, Boolean isSuccess, String backupMessage){
        RestResponse response = RestContext.response;

        System.debug('docketAttachmentId value: ' + docketAttachmentId);
        System.debug('isSuccess value: ' + isSuccess);
        System.debug('backupMessage value: ' + backupMessage);

        try{
            Docket_Attachment__c da = [SELECT Id FROM Docket_Attachment__c WHERE Id = :docketAttachmentId];

            da.Attachment_Backup_Message__c = backupMessage;
            da.Attachment_Backup_Status__c = isSuccess ? 'Complete' : 'Failed';

            update da;

            response.statusCode = 200;
            response.responseBody = Blob.valueOf('{"message": "Success"}');
        } catch(Exception e){
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('{"message": "' + e.getMessage() + ' ' + e.getStackTraceString() + e.getLineNumber() + '"}');
        }
    }
}