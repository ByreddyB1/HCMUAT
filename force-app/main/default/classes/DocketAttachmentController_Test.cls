@isTest
public with sharing class DocketAttachmentController_Test {
    public static testmethod void testOne() { 
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );

        insert contentVersion;

        Docket_Attachment__c docketAttachment=new Docket_Attachment__c(Attachment_Type__c='Department Fact Sheet',Visible_to_Community__c='No');

        insert docketAttachment;

        Test.startTest();
        DocketAttachmentController.uploadAttachment(docketAttachment.Id,contentVersion.Id);
        DocketAttachmentController.fetchInitialDetails();
        Test.stopTest();

        List<Docket_Attachment__c> checkDocketAttachmentList = [SELECT Id FROM Docket_Attachment__c];

        System.assert(checkDocketAttachmentList.size() > 0);
    }
}