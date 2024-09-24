/******************************************************
 Author: Bhushan
 Description: Test class for miCalloutApexAction Apex class.
 ******************************************************/
@isTest
public class miCalloutApexActionTest {

@isTest
    static void testMiTreasCallout() {
        // Set up the mock response
        String mockResponse = '{"d":{"results":[{"AccountName":"Test Account","FTIFlag":"No","IdentificationType":"BP","IdentificationNumber":"123456789","ErrorMessage":"","SAPAccountNumber":"SAP123456"}]}}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockResponse);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));

        // Prepare input parameters
        miCalloutApexAction.APIParameters inputParams = new miCalloutApexAction.APIParameters();
        inputParams.identiType = 'BP';
        inputParams.identiNumber = '123456789';

        List<miCalloutApexAction.APIParameters> inputParamList = new List<miCalloutApexAction.APIParameters>();
        inputParamList.add(inputParams);

        Test.startTest();
        List<miCalloutApexAction.outputResponse> result = miCalloutApexAction.miTreasCallout(inputParamList);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Test Account', result[0].accountname);
        System.assertEquals('No', result[0].FTIFlag);
        System.assertEquals('BP', result[0].OutputiType);
        System.assertEquals('123456789', result[0].OutputiNumber);
        System.assertEquals('SAP123456', result[0].OutputBPnber);
        System.assertEquals(200, result[0].StatusCode);
        System.assertEquals('', result[0].ErrorMessage);
    }
    
    @isTest
    static void testCreateAccount() {
        // Prepare the account creation test
        List<miCalloutApexAction.accountOutput> accountOutput = miCalloutApexAction.createAccount('Test Account', 'No', 'BP', '123456789', 'SAP123456');

        System.assertEquals(1, accountOutput.size());
        System.assertNotEquals(null, accountOutput[0].accId);
        System.assertEquals(false, accountOutput[0].containsDuplicates);
    }

    }