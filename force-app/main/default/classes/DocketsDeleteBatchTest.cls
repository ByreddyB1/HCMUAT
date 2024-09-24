@IsTest
public class DocketsDeleteBatchTest {
    @TestSetup
    static void setupTestRecords(){
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

        Docket_Participant__c docParticipant = new Docket_Participant__c(Account__c=acc.Id,Docket__c=docket.Id,Role__c='Taxpayer',Receive_Physical_Correspondence__c='No');

        insert docParticipant;
    }

    @IsTest
    static void testBatch(){
        list<Docket__c> testDockets = [SELECT Id FROM Docket__c];

        System.assertEquals(1, testDockets.size(), 'We did not find the number of Dockets created in the set up method.');
       
        
        DocketsDeleteBatch  batch = new DocketsDeleteBatch ();

        Test.startTest();

        Database.executeBatch(batch);

        Test.stopTest();

        List<Docket__c> testDockets1 = [SELECT Id FROM Docket__c ];
        List<Docket_Attachment__c> testDocketAtt = [SELECT Id FROM Docket_Attachment__c];
        List<Docket_Participant__c> testDocketParti= [SELECT Id FROM Docket_Participant__c];

        System.assertEquals(0, testDockets1.size());
        System.assertEquals(0, testDocketAtt.size());
        System.assertEquals(0, testDocketParti.size());
    }

    @IsTest 
    static void testBatchShedule(){
        DocketsDeleteBatch  batch = new DocketsDeleteBatch ();

        Test.startTest();

        String chron = '0 0 23 * * ?';
        String jobId = system.schedule('Test Schedulable', chron, batch);
        System.Assert(jobId != null, 'There was an issue with the schedulable and we did not get an Id as expected.');

        Test.stopTest();
    }
}