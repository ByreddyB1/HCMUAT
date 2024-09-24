@IsTest
private class DocketSharingTest {
    @IsTest
    static void testTriggerBehavior() {
        Docket_Auto_Number__c dan= new Docket_Auto_Number__c(Current_Auto_Number__c=1);

        insert dan;

        Account acc=new Account(Name='TestAccount',Type='Representing Agency');

        insert acc;
        
        Contact con =new Contact(LastName='TestContact' ,AccountId=acc.Id);

        insert con;

        Contact con1 =new Contact(LastName='TestContact1' ,AccountId=acc.Id);

        insert con1;

        Docket__c docket=new Docket__c(Name='TestDocket' ,Taxpayer_Account__c=acc.Id, Taxpayer_Contact__c=con.Id,Received_Date__c=Date.today()
                                       ,Type__c='Intent to Assess' ,Tax_Division__c='Collections',Litigation_Hold__c=false,Closed_Date__c=(date.today().addYears(-6)).addDays(-1));

        insert docket;

        Docket_Attachment__c docketAttachment=new Docket_Attachment__c(Attachment_Type__c='Department Fact Sheet',Visible_to_Community__c='No',Docket__c=docket.Id);

        insert docketAttachment;

        Profile p = [SELECT Id FROM Profile WHERE Name='Treasury Community Plus User' LIMIT 1];

        User tempUser = new User();

        tempUser.FirstName = 'ownerMgr';
        tempUser.LastName = 'Tester';
        tempUser.Email = 'tcareddy@ptc.com';
        tempUser.Alias = 'tmgr';
        tempUser.ProfileId = p.Id;
        tempUser.Username = 'mgr@abc.com.itdev';
        tempUser.TimeZoneSidKey = 'America/New_York';
        tempUser.LocaleSidKey = 'en_US';
        tempUser.EmailEncodingKey = 'UTF-8';
        tempUser.LanguageLocaleKey = 'en_US';
        tempUser.IsActive = true;
        tempUser.ContactId = con.Id;

        insert tempUser;

        User tempUser1 = new User();

        tempUser1.FirstName = 'ownerMgr';
        tempUser1.LastName = 'Tester';
        tempUser1.Email = 'tcaresdsy@ptc.com';
        tempUser1.Alias = 'tmgr';
        tempUser1.ProfileId = p.Id;
        tempUser1.Username = 'mgr@sdg.com.itdev';
        tempUser1.TimeZoneSidKey = 'America/Los_Angeles';
        tempUser1.LocaleSidKey = 'en_US';
        tempUser1.EmailEncodingKey = 'UTF-8';
        tempUser1.LanguageLocaleKey = 'en_US';
        tempUser1.IsActive = true;
        tempUser1.ContactId = con1.Id;

        insert tempUser1;
        
		Test.startTest();

        Docket_Participant__c docParticipant = new Docket_Participant__c(Account__c=acc.Id,Docket__c=docket.Id,Role__c='Taxpayer',Receive_Physical_Correspondence__c='No');

        insert docParticipant;

        Docket_Participant__c docParticipant1 = new Docket_Participant__c(Account__c=acc.Id,Contact__c=con.Id,Docket__c=docket.Id,Role__c='Authorized Representative',
                                                                         Status__c='Active',All_of_the_above__c=true,Authorization_Start_Date__c=Date.today(),
                                                                         Authorization_End_Date__c=Date.today().addDays(1),Receive_Physical_Correspondence__c='No');
        insert docParticipant1;

        List<Docket__share> listOfDocketShares = [SELECT Id FROM Docket__share WHERE ParentId =: docket.Id AND UserOrGroupId =: tempUser.Id];

        System.assertEquals(1, listOfDocketShares.size(), 'Docket Paeticipant\'s docket is not shared by Docket Particepant\'s contact user.');

        docParticipant1.Contact__c = con1.Id;

        Update docParticipant1;

        List<Docket__share> listOfDocketShares1 = [SELECT Id FROM Docket__share WHERE ParentId =: docket.Id AND UserOrGroupId =: tempUser.Id];

        System.assertEquals(0, listOfDocketShares1.size(), 'Docket Share record is not deleted for Docket Particepant\'s contact user.');

        List<Docket__share> listOfDocketShares2 = [SELECT Id FROM Docket__share WHERE ParentId =: docket.Id AND UserOrGroupId =: tempUser1.Id];

        System.assertEquals(1, listOfDocketShares2.size(), 'Docket Paeticipant\'s docket is not shared by Docket Particepant\'s contact user.');

        Delete docParticipant1;

        List<Docket__share> listOfDocketShares3 = [SELECT Id FROM Docket__share WHERE ParentId =: docket.Id AND UserOrGroupId =: tempUser1.Id];

        System.assertEquals(0, listOfDocketShares3.size(), 'Docket Share record is not deleted for Docket Particepant\'s contact user.');

        Test.stopTest();
    }
    @IsTest
    static void testBatchBehavior() {
        Docket_Auto_Number__c dan= new Docket_Auto_Number__c(Current_Auto_Number__c=1);

        insert dan;

        Account acc=new Account(Name='TestAccount',Type='Representing Agency');

        insert acc;
        
        Contact con =new Contact(LastName='TestContact' ,AccountId=acc.Id);

        insert con;

        Docket__c docket=new Docket__c(Name='TestDocket' ,Taxpayer_Account__c=acc.Id, Taxpayer_Contact__c=con.Id,Received_Date__c=Date.today()
                                       ,Type__c='Intent to Assess' ,Tax_Division__c='Collections',Litigation_Hold__c=false,Closed_Date__c=(date.today().addYears(-6)).addDays(-1));

        insert docket;

        Docket_Attachment__c docketAttachment=new Docket_Attachment__c(Attachment_Type__c='Department Fact Sheet',Visible_to_Community__c='No',Docket__c=docket.Id);

        insert docketAttachment;

        Profile p = [SELECT Id FROM Profile WHERE Name='Treasury Community Plus User' LIMIT 1];

        User tempUser = new User();
        tempUser.FirstName = 'ownerMgr';
        tempUser.LastName = 'Tester';
        tempUser.Email = 'tcareddy@ptc.com';
        tempUser.Alias = 'tmgr';
        tempUser.ProfileId = p.Id;
        tempUser.Username = 'mgr@abc.com.itdev';
        tempUser.TimeZoneSidKey = 'America/Los_Angeles';
        tempUser.LocaleSidKey = 'en_US';
        tempUser.EmailEncodingKey = 'UTF-8';
        tempUser.LanguageLocaleKey = 'en_US';
        tempUser.IsActive = true;
        tempUser.ContactId = con.Id;

        insert tempUser;
        
         Docket_Participant__c docParticipant1 = new Docket_Participant__c(Account__c=acc.Id,Contact__c=con.Id,Docket__c=docket.Id,Role__c='Authorized Representative',
                                                                         Status__c='Active',All_of_the_above__c=true,Authorization_Start_Date__c=Date.today(),
                                                                         Authorization_End_Date__c=Date.today().addDays(1),Receive_Physical_Correspondence__c='No');
        insert docParticipant1;

        Docket__share docShare = new Docket__Share();
                docShare.ParentId = docket.Id;
                docShare.AccessLevel = 'Edit';
                docShare.UserOrGroupId = tempUser.Id;
                docShare.RowCause = Schema.Docket__share.RowCause.Manual;

		Test.startTest();

        DocketSharingBatch  batch = new DocketSharingBatch ();
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @IsTest
    static void testBatchShedule(){
        Test.startTest();

		DocketSharingBatchSchedulable  batch = new DocketSharingBatchSchedulable ();
        String chron = '0 0 23 * * ?';
        Id jobId = System.schedule('Test Schedulable', chron, batch);
        System.Assert(jobId != null, 'There was an issue with the schedulable and we did not get an Id as expected.');

        Test.stopTest();
    }
}