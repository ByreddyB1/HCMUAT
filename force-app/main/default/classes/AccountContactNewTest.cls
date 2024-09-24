@IsTest
private class AccountContactNewTest {
    @IsTest
    static void testBehavior() {
        Docket_Auto_Number__c dan= new Docket_Auto_Number__c(Current_Auto_Number__c=1);

        insert dan;

        Account acc = new Account(Name='TestAccount',Type='Representing Agency',Tax_ID__c='abcd1234');

        insert acc;

        Test.startTest();

        List<ListView> listViewAcc = AccountContactNew.getListViews();
        System.assertEquals(false,listViewAcc.isEmpty());

        List <Account_Type__mdt> accTypeMtd = AccountContactNew.getData();
        System.assertEquals(false,accTypeMtd.isEmpty());

        String returnString = AccountContactNew.checkAccForTaxId('abcd1234');
        System.assertEquals(true, String.isNotBlank(returnString));

        AccountContactNew.deleteAccount(acc.Id);

        Test.stopTest();
    }
}