/******************************************************
 Author: Bhushan
 Description: Test class for eccDocketRequestController apex class.
 ******************************************************/
@isTest
public class eccDocketRequestCntlTest {

    @isTest
    static void testEccDocketRequest() {
    
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
        String mockResponse = '[{"ID_TYPE":"BP","ID_NUMBER":"123456789","ACCOUNT_NO":"SAP123456","ACCOUNT_NAME":"Test Account","ASSESSMENT_NO":"Assess123","SYSTEM_DATE":"2023-07-10","PRIMARY_SECONDARY_ACCT":"P","PROJECT_CODE":"BEC","INTENT_DATE":"2023-07-01","FTI_FLAG":"","TAX_TYPE":"DETI","TAX_PERIOD_START_DATE":"2023-01-01","TAX_PERIOD_END_DATE":"2023-12-31","ORIGINAL_TAX_AMOUNT":1000.00,"ORIGINAL_PENALTY_AMOUNT":100.00,"ORIGINAL_INTEREST_AMOUNT":50.00,"FINAL_DATE":"2023-07-11","HEARING_HOLD":"X","FBTYP":"CTYI","ERROR_MESSAGE":""}]';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockResponse);
        res.setStatusCode(200);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));
        
        List<eccDocketRequestController.outputResponse> result = eccDocketRequestController.eccDocketRequest(testDocket.Id);
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
        List<eccDocketRequestController.outputResponse> selectionList = new List<eccDocketRequestController.outputResponse>();
        eccDocketRequestController.outputResponse selection = new eccDocketRequestController.outputResponse();
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
        selection.TaxType = 'DETI';
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
        eccDocketRequestController.createDocketRequestECC(testDocket.Id, selectionListJson);
        Test.stopTest();

        List<Docket_Request__c> drList = [SELECT Id, Account_Name__c FROM Docket_Request__c WHERE Docket__c = :testDocket.Id];
        System.assertEquals(1, drList.size());
        System.assertEquals('Test Account', drList[0].Account_Name__c);
    }
    
  
}