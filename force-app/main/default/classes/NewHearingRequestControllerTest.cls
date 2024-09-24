@IsTest
public class NewHearingRequestControllerTest {
	 @IsTest
    static void testNewHearingReq(){
        Docket_Auto_Number__c dan= new Docket_Auto_Number__c(Current_Auto_Number__c=1);

        insert dan;

        Account acc=new Account(Name='TestAccount',Type='Representing Agency');

        insert acc;
        
        Contact con =new Contact(LastName='TestContact' ,AccountId=acc.Id);

        insert con;

        Docket__c docket=new Docket__c(Name='TestDocket' ,Taxpayer_Account__c=acc.Id, Taxpayer_Contact__c=con.Id,Received_Date__c=Date.today()
                                       ,Type__c='Intent to Assess' ,Tax_Division__c='Collections',Litigation_Hold__c=false,Closed_Date__c=(date.today().addYears(-6)).addDays(-1));

        insert docket;
        Docket__c docket1=new Docket__c(Name='TestDocket' ,Taxpayer_Account__c=acc.Id, Taxpayer_Contact__c=con.Id,Received_Date__c=Date.today()
                                       ,Type__c='License Denial' ,Tax_Division__c='Collections',Litigation_Hold__c=false,Closed_Date__c=(date.today().addYears(-6)).addDays(-1));

        insert docket1;
        Docket__c docket2=new Docket__c(Name='TestDocket' ,Taxpayer_Account__c=acc.Id, Taxpayer_Contact__c=con.Id,Received_Date__c=Date.today()
                                       ,Type__c='Seizure' ,Tax_Division__c='Collections',Litigation_Hold__c=false,Closed_Date__c=(date.today().addYears(-6)).addDays(-1));

        insert docket2;
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        NewHearingRequestController.MultipleDocketRequestDataWrapper mdr = new NewHearingRequestController.MultipleDocketRequestDataWrapper();
        mdr.dateOfNotice = Date.today();
        mdr.intentNumber = 'abcd';
        mdr.taxEndDate = Date.today().addDays(4);
        mdr.taxType = 'City Corporate Income Tax – Detroit';
        mdr.docketAttachmentType = 'Supporting Documentation';
        mdr.taxpayerNotes = 'test';
        mdr.contentVersionIdList = new List<String>{[select contentdocumentid from contentversion where id =: content.id].contentdocumentid};
        NewHearingRequestController.SingleDocketRequestDataWrapper sdr = new NewHearingRequestController.SingleDocketRequestDataWrapper();
        sdr.dateOfNotice = date.today();
        sdr.complaintNumber = 'test Comp';
        sdr.believedToBe = 'believedToBe';
        sdr.seizedLocation = 'usa';
        sdr.docketAttachmentType = 'Supporting Documentation';
        sdr.taxpayerNotes = 'notes';
        sdr.contentVersionIdList = new List<String>{[select contentdocumentid from contentversion where id =: content.id].contentdocumentid};
        Test.startTest();
        NewHearingRequestController.createDocketRequestAndAttachment(docket.id,'Intent to Assess',new List<NewHearingRequestController.MultipleDocketRequestDataWrapper>{mdr},new NewHearingRequestController.SingleDocketRequestDataWrapper());
        NewHearingRequestController.createDocketRequestAndAttachment(docket1.id,'License Denial',new List<NewHearingRequestController.MultipleDocketRequestDataWrapper>{mdr},sdr);
        NewHearingRequestController.createDocketRequestAndAttachment(docket2.id,'Seizure',new List<NewHearingRequestController.MultipleDocketRequestDataWrapper>{mdr},sdr);                                                                                                                                                                                                
        System.assertEquals(3, [SELECT id FROM Docket_Request__c].size());
        System.assertEquals(3, [SELECT Id FROM Docket_Attachment__c].size());
        Test.stopTest();
        
    }
}