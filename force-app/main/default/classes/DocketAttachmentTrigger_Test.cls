@isTest
public class DocketAttachmentTrigger_Test {
    public static testmethod void testOne() { 
    ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );

        insert contentVersion;

        Docket_Attachment__c docketAttachment = new Docket_Attachment__c(Attachment_Type__c='Department Fact Sheet', Visible_to_Community__c='No');

        insert docketAttachment;

        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = docketAttachment.Id;

        insert cdl;

        List<Docket_Attachment__c> checkDocketAttachmentList = [SELECT Id FROM Docket_Attachment__c];

        System.assert(checkDocketAttachmentList.size() > 0);

        Test.startTest();

        delete  docketAttachment;

        Test.stopTest();
    }
}