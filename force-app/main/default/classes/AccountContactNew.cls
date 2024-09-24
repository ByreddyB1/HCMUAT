public with sharing class AccountContactNew {
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = [SELECT Name FROM ListView WHERE SobjectType = 'Account'];

        // Perform isAccessible() check here
        return listviews;
    }

    @AuraEnabled(cacheable=true)
    public static List <Account_Type__mdt> getData() {
        return [ SELECT MasterLabel FROM Account_Type__mdt ];
    }

    @AuraEnabled
    public static void deleteAccount(String accId) {
        try{
            Account acc = new Account(Id=accId);

            delete acc;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String checkAccForTaxId(String taxId) {
        String returnString='Not Exist';
        List<Account> accList = [SELECT Name FROM Account WHERE Tax_ID__c =: taxId];

        if(accList.size()>0){
            returnString=accList[0].Id+'-'+accList[0].Name;
        }

        return returnString;
    }
}