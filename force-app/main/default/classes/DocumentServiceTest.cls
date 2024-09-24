@IsTest
public class DocumentServiceTest {
    static testMethod void testGetMethod() {
        List<Docket_Attachment__c> docketAttachmentsList = new List<Docket_Attachment__c>();
        List<ContentVersion> contentVersionsList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocsList = new List<ContentDocumentLink>();

        ContentVersion contentVersion = new ContentVersion(
                Title = 'File Test',
                PathOnClient = 'FileTest.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );

        contentVersionsList.add(contentVersion);

        ContentVersion contentVersion2 = new ContentVersion(
                Title = 'File Test 2',
                PathOnClient = 'FileTest2.jpg',
                VersionData = Blob.valueOf('Test Content 2'),
                IsMajorVersion = true
        );

        contentVersionsList.add(contentVersion2);

        insert contentVersionsList;

        Docket_Attachment__c docketAttachment = new Docket_Attachment__c(Attachment_Type__c = 'Department Fact Sheet', Visible_to_Community__c='No', Attachment_Backup_Status__c = 'In Progress');

        docketAttachmentsList.add(docketAttachment);

        insert docketAttachmentsList;

        List<Docket_Attachment__c> checkDocketAttachmentList = [SELECT Id FROM Docket_Attachment__c];

        System.assert(checkDocketAttachmentList.size() > 0);

        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = docketAttachment.Id;
        cdl.ShareType = 'V';

        contentDocsList.add(cdl);

        insert contentDocsList;

        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();

        request.requestUri ='/services/apexrest/mitrapi/v1/docinfo/*';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = res;

        // Get the Not Started Docket Attachment.
        DocumentService.getFile();
    }

    static testMethod void testPostMethod() {
        Docket_Attachment__c docketAttachment = new Docket_Attachment__c(Attachment_Type__c='Department Fact Sheet',Visible_to_Community__c='No',Attachment_Backup_Status__c = 'Not Started');

        insert docketAttachment;

        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();

        request.requestUri ='/services/apexrest/mitrapi/v1/docinfo/*';
        request.httpMethod = 'POST';

        RestContext.request = request;
        RestContext.response = res;

        String docketAttachId = docketAttachment.Id;

        DocumentService.updateDocketAttachment(docketAttachId,true,'Success');
    }
}