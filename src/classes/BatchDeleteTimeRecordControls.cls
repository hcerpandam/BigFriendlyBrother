/**
 * @file        BatchDeleteTimeRecordControls.apxc
 * @author      Héctor Cervera Panella
 * @date        02/12/2019
 * @description AutoScheduled batch to:
 *              Delete all daily TimeRecordsControls__c where isCopy is True or where created a month ago
 *              Call the BFBSafe App static resource to delete all records created four years ago
 */
global class BatchDeleteTimeRecordControls implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    // Vars
    private List<TimeRecordControl__c> lstTimeRecToDelete = new List<TimeRecordControl__c>();
    private Integer CRON_INTERVAL;
	private Integer BATCH_SIZE;
	private Integer QUERY_LIMIT;
    private Date insDate = System.today().addMonths(-1);

    // Builder
    global BatchDeleteTimeRecordControls(){
        CRON_INTERVAL = 5;
        BATCH_SIZE = 200;
        QUERY_LIMIT = 10000;
    }

    // Start
    global List<TimeRecordControl__c> start(Database.BatchableContext BC) {
        lstTimeRecToDelete = new List<TimeRecordControl__c>([SELECT Id FROM TimeRecordControl__c WHERE isCopy__c = TRUE OR RecordDate__c =: insDate  LIMIT : QUERY_LIMIT]);
        doDeleteRemote();
        return lstTimeRecToDelete;
    }

    // Execute
    global void execute(Database.BatchableContext BC, List<TimeRecordControl__c> lstTimeRecToDelete){
        if(!lstTimeRecToDelete.isEmpty()){
            delete lstTimeRecToDelete;
        }      
    }

    // Finish
    global void finish(Database.BatchableContext BC){
        if (!Test.isRunningTest()) {
            DateTime currDayTime = System.now();
            Integer currHour = currDayTime.hour();
            System.debug(LoggingLevel.INFO,'Current hour is: '+currHour);
            if(currHour==03){
                System.debug(LoggingLevel.DEBUG, 'End of BatchDeleteTimeRecordsControl at: '+currHour+':'+currDayTime.minute());
            }else{
                scheduleMe(CRON_INTERVAL, BATCH_SIZE);
            }
		}
    }

    // Util methods
    private static void scheduleMe(Integer interval, Integer batchSize) {
		System.scheduleBatch(new BatchDeleteTimeRecordControls(), Test.isRunningTest() ? 'ScheduleTestBatchDeleteTimeRecordControls' : 'BatchDeleteTimeRecordControls', interval, batchSize);
	}

    private static void doDeleteRemote(){
        CalloutsManagement.doDelete();
    }
}