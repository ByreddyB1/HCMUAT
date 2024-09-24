public with sharing class UserHandler {
    public static void afterInsert(List<User> usersList) {
        for(User u :usersList){
            System.debug('u value: ' + u);

            // If at least one new User was created and marked Active, run the DocketSharingBatch job to make sure the sharing is set up correctly.
            if(u.IsActive){
                DocketSharingBatch docketSharingBatch = new DocketSharingBatch();

                Database.executebatch(docketSharingBatch);

                break;
            }
        }
    }

    public static void afterUpdate(List<User> usersList, Map<Id, User> oldUsersMap) {
        System.debug('oldUsersMap value: ' + oldUsersMap);

        for(User u :usersList){
            System.debug('u value: ' + u);
            System.debug('u.IsActive value: ' + u.IsActive);
            System.debug('oldUsersMap.get(u.Id).IsActive value: ' + oldUsersMap.get(u.Id).IsActive);

            // If at least one new User was updated to Active, run the DocketSharingBatch job to make sure the sharing is set up correctly.
            if(u.IsActive && oldUsersMap.get(u.Id).IsActive == false){
                DocketSharingBatch docketSharingBatch = new DocketSharingBatch();

                Database.executebatch(docketSharingBatch);

                break;
            }
        }
    }
}