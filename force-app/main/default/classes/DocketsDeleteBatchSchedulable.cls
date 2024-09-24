global class DocketsDeleteBatchSchedulable implements schedulable{
    global void execute(Schedulablecontext sc) {
        DocketsDeleteBatch docketsDeleteB = new DocketsDeleteBatch();

        Database.executeBatch(docketsDeleteB,200);
    }
}