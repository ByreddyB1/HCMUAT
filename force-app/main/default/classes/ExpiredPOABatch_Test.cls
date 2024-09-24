@isTest
public with sharing class ExpiredPOABatch_Test {
    public static testmethod void batchTest() {
        Docket_Auto_Number__c dan= new Docket_Auto_Number__c(Current_Auto_Number__c=1);

        insert dan;

        Account acc=new Account(Name='TestAccount', Type='Representing Agency');

        insert acc;

        Contact con =new Contact(LastName='TestContact', AccountId=acc.Id);

        insert con;

        Docket__c docket=new Docket__c(
                Name='TestDocket',
                Taxpayer_Account__c=acc.Id,
                Taxpayer_Contact__c=con.Id,
                Received_Date__c=Date.today(),
                Type__c='Intent to Assess',
                Tax_Division__c='Audit',
                Audit_Period_Start_Date__c=System.today(),
                Audit_Period_End_Date__c=System.today()+12);

        insert docket;

        List<Docket_Participant__c> lisToInsert=new List<Docket_Participant__c>();

        Docket_Participant__c test1= new Docket_Participant__c(
                Docket__c=docket.Id,
                Account__c=acc.Id,
                Role__c='Authorized Representative',
                Receive_Physical_Correspondence__c='No',
                Status__c='Active',
                Authorization_End_Date__c=Date.today());

        lisToInsert.add(test1);

        Docket_Participant__c test2= new Docket_Participant__c(
                Docket__c=docket.Id,
                Account__c=acc.Id,Role__c='Authorized Representative',
                Receive_Physical_Correspondence__c='No',
                Status__c='Active',
                Authorization_End_Date__c=Date.today().addDays(-1));

        lisToInsert.add(test2);

        Docket_Participant__c test3= new Docket_Participant__c(
                Docket__c=docket.Id,
                Account__c=acc.Id,
                Role__c='Authorized Representative',
                Receive_Physical_Correspondence__c='No',
                Status__c='Active',
                Authorization_End_Date__c=Date.today().addDays(-1));

        lisToInsert.add(test3);

        Docket_Participant__c test4= new Docket_Participant__c(
                Docket__c=docket.Id,
                Account__c=acc.Id,
                Role__c='Authorized Representative',
                Receive_Physical_Correspondence__c='No',
                Status__c='Active',
                Authorization_End_Date__c=Date.today().addDays(-1));

        lisToInsert.add(test4);

        insert lisToInsert;

        List<Docket_Participant__c> docketParticipantsList = [SELECT Name, Authorization_End_Date__c, Status__c FROM Docket_Participant__c WHERE Status__c='Active'];

        System.assertEquals(false, docketParticipantsList.isEmpty());

        Test.startTest();

        SchedulableContext sc = null;

        ExpiredPOABatchSchedulable exPOABatchSched = new ExpiredPOABatchSchedulable();

        exPOABatchSched.execute(sc);

        Test.stopTest();

        List<Docket_Participant__c> result=[SELECT Id, Name, Authorization_End_Date__c, Status__c FROM Docket_Participant__c WHERE Status__c='Expired'];
    }
}