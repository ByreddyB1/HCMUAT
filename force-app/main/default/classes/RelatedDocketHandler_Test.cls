@isTest
public class RelatedDocketHandler_Test {
    public static testmethod void testOne() { 
        Docket_Auto_Number__c dan= new Docket_Auto_Number__c(Current_Auto_Number__c=1);
        Insert dan;
        Account acc=new Account(Name='TestAccount',Type='Representing Agency');
        insert acc;
        
        Contact con =new Contact(LastName='TestContact' ,AccountId=acc.Id);
        insert con;
        Docket__c docket=new Docket__c(Name='TestDocket' ,Taxpayer_Account__c=acc.Id, Taxpayer_Contact__c=con.Id,Received_Date__c=Date.today()
                                       ,Type__c='Intent to Assess' ,Tax_Division__c='Collections');
        insert docket;
        Docket__c docket1=new Docket__c(Name='TestDocket1' ,Taxpayer_Account__c=acc.Id, Taxpayer_Contact__c=con.Id,Received_Date__c=Date.today()
                                        ,Type__c='Intent to Assess' ,Tax_Division__c='Collections');
        insert docket1;
        Test.startTest();
        Related_Docket__c newRD=new Related_Docket__c(Docket__c =docket.Id ,Related_Docket__c =docket1.Id, Reason__c='Related tobacco seizure'  );
        Insert newRD;
        List<Related_Docket__c> newCreatedRelatedDocket=[SELECT ID FROM Related_Docket__c WHERE Related_Docket__c =:docket.Id AND Docket__c=:docket1.Id];
        System.assertEquals(1, newCreatedRelatedDocket.size());
        newRD.Reason__c='Related entities';
        RelatedDocketHandler.afterUpdate(new List<Related_Docket__c>{newRD});
        List<Related_Docket__c> newCreatedRelatedDocket1=[SELECT ID,Reason__c FROM Related_Docket__c WHERE Related_Docket__c =:docket.Id AND Docket__c=:docket1.Id];
        System.assertEquals('Related entities', newCreatedRelatedDocket1[0].Reason__c);
        RelatedDocketHandler.afterDelete(new List<Related_Docket__c>{newRD});
        
        
        Test.stopTest();
        
    }
}