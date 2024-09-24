global class ExpiredPOABatchSchedulable implements schedulable{
    global void execute(Schedulablecontext sc) {
        ExpiredPOABatch expPOABatch = new ExpiredPOABatch();

        Database.executeBatch(expPOABatch,200);
    }
}