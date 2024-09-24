global with sharing class DocketSharingBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        DocketSharingBatch batch = new DocketSharingBatch();

        Database.executebatch(batch);
    }
}