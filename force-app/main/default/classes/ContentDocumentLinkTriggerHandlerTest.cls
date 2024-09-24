@IsTest
private class ContentDocumentLinkTriggerHandlerTest {
    @IsTest
    static void testBehavior() {
        Docket_Auto_Number__c dan = new Docket_Auto_Number__c(Current_Auto_Number__c = 1);

        insert dan;

        Account acc = new Account(Name = 'TestAccount', Type = 'Representing Agency');

        insert acc;

        Contact con = new Contact(LastName = 'TestContact', AccountId = acc.Id);

        insert con;

        Docket__c docket = new Docket__c(Name='TestDocket', Taxpayer_Account__c = acc.Id, Taxpayer_Contact__c = con.Id, Received_Date__c = Date.today()
                , Type__c='Intent to Assess', Tax_Division__c = 'Collections', Litigation_Hold__c = false, Closed_Date__c = (date.today().addYears(-6)).addDays(-1));

        insert docket;

        Docket_Attachment__c da = new Docket_Attachment__c(Docket__c = docket.Id, Attachment_Type__c = 'Authorized Representative Declaration (POA Form 151)', Visible_to_Community__c = 'Yes', Contains_FTI__c = 'No');

        insert da;

        ContentVersion content = new ContentVersion();

        content.Title = 'Test Document';
        content.PathOnClient = '/' + content.Title + '.docx';

        Blob bodyBlob=Blob.valueOf('Test Document');

        content.VersionData = bodyBlob;
        content.origin = 'H';

        insert content;

        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.LinkedEntityId = da.Id;
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id].ContentDocumentId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'InternalUsers';

        insert cdl;

        ContentDocumentLink checkCDL = [SELECT Visibility FROM ContentDocumentLink WHERE Id = :cdl.Id];

        System.assertEquals(checkCDL.Visibility, 'AllUsers');
    }
}