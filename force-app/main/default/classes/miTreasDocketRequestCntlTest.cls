/******************************************************
 Author: Bhushan
 Description: Test class for miTreasDocketRequestController apex class.
 ******************************************************/
@isTest
public class miTreasDocketRequestCntlTest {

   

    @isTest
    static void testMiTreasDocketRequest() {
    
        Docket_Auto_Number__c dan = new Docket_Auto_Number__c(Current_Auto_Number__c = 1);
        insert dan;

        Account acc = new Account(Name = 'TestAccount', Type = 'Representing Agency');
        insert acc;
        
        Contact con = new Contact(LastName = 'TestContact', AccountId = acc.Id);
        insert con;

        Docket__c docket = new Docket__c(Name='TestDocket', Taxpayer_Account__c = acc.Id, Taxpayer_Contact__c = con.Id, Received_Date__c = Date.today(),
                                        Type__c='Intent to Assess', Tax_Division__c = 'Collections', Litigation_Hold__c = false, Closed_Date__c = (date.today().addYears(-6)).addDays(-1));
        insert docket;
        
        // Test valid callout
        Docket__c testDocket = [SELECT Id FROM Docket__c LIMIT 1];
        Test.startTest();
        
        // Mock the callout response
        String mockResponse = '{"d":{"results":[{"IdentificationType":"BP","IdentificationNumber":"123456789","SAPAccountNumber":"SAP123456","AccountName":"Test Account","AssessmentNumber":"Assess123","TaxPeriodStartDate":"20230101","TaxPeriodEndDate":"20231231","SystemDate":"20230710","IntentDate":"20230701","FinalAssmntDate":"20230711","OriginalTaxAmount":"1000.00","OriginalPenaltyAmount":"100.00","OriginalInterestAmount":"50.00","HearLck":"No"}]}}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockResponse);
        res.setStatusCode(200);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));
        
        List<miTreasDocketRequestController.outputResponse> result = miTreasDocketRequestController.miTreasDocketRequest(testDocket.Id);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('BP', result[0].IdentificationType);
        System.assertEquals('123456789', result[0].IdentificationNumber);
        System.assertEquals('Test Account', result[0].AccountName);
        System.assertEquals('7/1/2023', result[0].IntentDate);
    }

@isTest
    static void testCreateDocketRequest() {
        Docket_Auto_Number__c dan = new Docket_Auto_Number__c(Current_Auto_Number__c = 10);
        insert dan;

        Account acc = new Account(Name = 'TestAccount', Type = 'Representing Agency');
        insert acc;
        
        Contact con = new Contact(LastName = 'TestContact', AccountId = acc.Id);
        insert con;

        Docket__c docket = new Docket__c(Name='TestDocket', Taxpayer_Account__c = acc.Id, Taxpayer_Contact__c = con.Id, Received_Date__c = Date.today(),
                                        Type__c='Intent to Assess', Tax_Division__c = 'Collections', Litigation_Hold__c = false, Closed_Date__c = (date.today().addYears(-6)).addDays(-1));
        insert docket;
        
        // Test valid callout
        Docket__c testDocket = [SELECT Id FROM Docket__c LIMIT 1];

        // Prepare selection list
        List<miTreasDocketRequestController.outputResponse> selectionList = new List<miTreasDocketRequestController.outputResponse>();
        miTreasDocketRequestController.outputResponse selection = new miTreasDocketRequestController.outputResponse();
        selection.IdentificationType = 'BP';
        selection.IdentificationNumber = '123456789';
        selection.SAPAccountNumber = 'SAP123456';
        selection.AccountName = 'Test Account';
        selection.AssessmentNumber = 'Assess123';
        selection.SystemDate = '07/10/2023';
        selection.PrimarySecondaryAccount = 'P';
        selection.ProjectCode = 'Prj';
        selection.IntentDate = '07/01/2023';
        selection.FTIFlag = 'No';
        selection.TaxType = 'MST';
        selection.TaxPeriodStartDate = '01/01/2023';
        selection.TaxPeriodEndDate = '12/31/2023';
        selection.OriginalTaxAmount = '1000.00';
        selection.OriginalPenaltyAmount = '100.00';
        selection.OriginalInterestAmount = '50.00';
        selection.FinalAssessmentDate = '07/11/2023';
        selection.HearingHoldIndicator = 'No';
        selectionList.add(selection);

        String selectionListJson = JSON.serialize(selectionList);
       
        Test.startTest();
        //Test.setMock(MetadataMock.class, new MetadataMock(mockMetadataMap));
        miTreasDocketRequestController.createDocketRequest(testDocket.Id, selectionListJson);
        Test.stopTest();

        List<Docket_Request__c> drList = [SELECT Id, Account_Name__c FROM Docket_Request__c WHERE Docket__c = :testDocket.Id];
        System.assertEquals(1, drList.size());
        System.assertEquals('Test Account', drList[0].Account_Name__c);
    }
    
}