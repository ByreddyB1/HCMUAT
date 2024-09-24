global without sharing class DeactivateUsersBatchSchedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      DeactivateUsersBatch b = new DeactivateUsersBatch();

      database.executebatch(b,10);
   }
}