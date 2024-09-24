global without sharing class DeactivateUsersBatch implements Database.batchable<sObject> {

global DeactivateUsersBatch() {
        
        
  }
    
    
global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Date communityLastLoginDateCheck = Date.today().addMonths( - Integer.valueOf(Label.Deactivate_Community_Users_After_X_Months));
        //String strQuery = 'SELECT LastLoginDate, IsActive, Profile.UserLicense.Name FROM User WHERE IsActive = true and LastLoginDate < :communityLastLoginDateCheck';
        
        String strQuery = 'SELECT Id,LastLoginDate, IsActive,CreatedDate, Profile.UserLicense.Name FROM User WHERE IsActive = true';   
        if(Test.isRunningTest()){
            strQuery = 'SELECT Id,LastLoginDate, IsActive,CreatedDate,Profile.UserLicense.Name FROM User WHERE IsActive = true LIMIT 200';
        }
        
        return Database.getQueryLocator(strQuery);
  }


global void execute(Database.BatchableContext info, List<User> toBeExpiredUsers){


        Integer countCommunityuserDeactivated=0;
        Integer countInternaluserDeactivated=0;
        Date internalLastLoginDateCheck = Date.today().addDays( - Integer.valueOf(Label.Deactivate_Users_After_X_Days));
        system.debug('internalLastLoginDateCheck'+ internalLastLoginDateCheck);
        Date communityLastLoginDateCheck = Date.today().addDays( - Integer.valueOf(Label.Deactivate_Community_Users_After_X_Months));
        system.debug('communityLastLoginDateCheck'+ communityLastLoginDateCheck);
        
        /***********************************************************************************************************************
        - LastLoginDate & CreatedDate (for users who never logged in to system) are considered for Deactivating the Users.
        - Below logic evaluates, if LastLoginDate is 'null' considers CreatedDate to deactivate an User.  
        ************************************************************************************************************************/     
        
        List<User> inactiveUsersList = new List<User>(); 
        system.debug('Total List of users from Start Method'+ toBeExpiredUsers.size());
        system.debug('toBeExpiredUsers'+ toBeExpiredUsers);
        
        try{
            for(User u: toBeExpiredUsers){
                // Use the current User's License Type to determine which User deactivation criteria to use.
                
                
                if(u.LastLoginDate!=null){
                       
                    if(u.Profile.UserLicense.Name == 'Customer Community Plus' || u.Profile.UserLicense.Name == 'Customer Community Plus Login'){
                        system.debug('LastLoginDate is not null -----> Community user Inside'+u.Id);
                        //System.debug('U.id::' +u.Id);
                        if(u.LastLoginDate <= communityLastLoginDateCheck) {
                            u.IsActive=false;
                            countCommunityuserDeactivated = countCommunityuserDeactivated + 1;
                            inactiveUsersList.add(u);
                        } 
                    } else{
                            // This applies to internal Users, so the internal User deactivation criteria needs to be used, as opposed to the community User criteria.
                            system.debug('LastLoginDate is not null -----> Internal user Inside'+u.Id);
                            //System.debug('In else U.id::' +u.Id);
                            if(u.LastLoginDate <= internalLastLoginDateCheck && u.Profile.UserLicense.Name =='Salesforce') {
                                //System.debug('U.id::' +u.Id);
                                u.IsActive=false;
                                inactiveUsersList.add(u);
                                countInternaluserDeactivated = countInternaluserDeactivated +1;
                            }
                        }
                        
                } else { 
                        
                    if(u.Profile.UserLicense.Name == 'Customer Community Plus' || u.Profile.UserLicense.Name == 'Customer Community Plus Login'){
                        system.debug('LastLoginDate is null -----> Community user Inside'+u.Id);
                        
                        if(u.CreatedDate <= communityLastLoginDateCheck) {
                            u.IsActive=false;
                            inactiveUsersList.add(u);
                            countCommunityuserDeactivated = countCommunityuserDeactivated + 1;
                                } 
                        }
                        else{
                            system.debug('LastLoginDate is null -----> Internal user Inside'+u.Id);
                            // This applies to internal Users, so the internal User deactivation criteria needs to be used, as opposed to the community User criteria.
                            if(u.CreatedDate <= internalLastLoginDateCheck && u.Profile.UserLicense.Name =='Salesforce') {
                                u.IsActive=false;
                                inactiveUsersList.add(u);
                                countInternaluserDeactivated = countInternaluserDeactivated +1;
                            }
                        }
                        
                   }
                
               
               System.debug('countCommunityuserDeactivated::' +countCommunityuserDeactivated);
               System.debug('countInternaluserDeactivated::' +countInternaluserDeactivated);
               
            }
            
            System.debug('inactiveUsersList::' +inactiveUsersList.size());
            
            if(inactiveUsersList.size() > 0){
                    System.debug('inactiveUsersList::' +inactiveUsersList);
                    Database.SaveResult[] srList = Database.update(inactiveUsersList, false);
                    
                    // Loop through each returned result.
                    for(Database.SaveResult sr : srList) {
                        if(sr.isSuccess()) {
                            // This condition will be executed for successful records.
                            System.debug('Successfully deactivated the User and User Id is: ' + sr.getId());
                        } else {
                            // This condition will be executed for failed records.
                            for(Database.Error objErr : sr.getErrors()) {
                                System.debug('The following error has occurred: ' + objErr.getStatusCode() + ': ' + objErr.getMessage() + sr.getId());
                                System.debug('User object field which caused the error: ' + objErr.getFields());
                            }
                        }
                    } 
                }
        
        }catch(Exception e){
            System.debug('Exception: ' + e);
        }




    }

global void finish(Database.BatchableContext info) {
        System.debug(logginglevel.INFO, 'Execute Finish Method');
    }




}