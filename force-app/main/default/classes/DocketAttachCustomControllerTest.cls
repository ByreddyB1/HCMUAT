@isTest
public with sharing class DocketAttachCustomControllerTest {
    public static testmethod void testOne() { 
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );

        insert contentVersion;

        Docket_Auto_Number__c dan= new Docket_Auto_Number__c(Current_Auto_Number__c=1);

        insert dan;

        Account acc=new Account(Name='TestAccount',Type='Representing Agency');

        insert acc;
        
        Contact con =new Contact(LastName='TestContact' ,AccountId=acc.Id);

        insert con;

        Docket__c docket=new Docket__c(Name='TestDocket' ,Taxpayer_Account__c=acc.Id, Taxpayer_Contact__c=con.Id,Received_Date__c=Date.today()
                                       ,Type__c='Intent to Assess' ,Tax_Division__c='Collections',Litigation_Hold__c=false,Closed_Date__c=(date.today().addYears(-6)).addDays(-1));

        insert docket;

        Docket_Attachment__c docketAttachment=new Docket_Attachment__c(Attachment_Type__c='Department Fact Sheet',Visible_to_Community__c='Yes',Docket__c=docket.Id);

        insert docketAttachment;

        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;
        cdl.LinkedEntityId = docketAttachment.Id;

        insert cdl;
        Test.startTest();
        List<DocketAttachCustomController.DocumentWrapper> returnWrapper = DocketAttachCustomController.getAllDocs(docket.Id);
        System.assert(returnWrapper.size() > 0);
        Test.stopTest();
        
    }
}