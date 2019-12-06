/**
 * @file        BatchSendTimeRecordControls.apxc
 * @author      Héctor Cervera Panella
 * @date        02/12/2019
 * @description AutoScheduled batch to:
 *              Post all daily TimeRecordsControls__c into BFBSafe created a month ago
 */
global class BatchSendTimeRecordControls implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    // Vars
    private List<TimeRecordControl__c> lstTimeRecToPost = new List<TimeRecordControl__c>();
    private Integer CRON_INTERVAL;
    private Integer CRON_INTERVAL_DAY;
	private Integer BATCH_SIZE;
	private Integer QUERY_LIMIT;
    private Date insDate = System.today().addMonths(-1);

    // Builder
    global BatchSendTimeRecordControls(){
        CRON_INTERVAL = 5;
        BATCH_SIZE = 200;
        QUERY_LIMIT = 10000;
        CRON_INTERVAL_DAY = 1410;
    }

    // Start
    global List<TimeRecordControl__c> start(Database.BatchableContext BC) {
        lstTimeRecToPost = new List<TimeRecordControl__c>([SELECT Id FROM TimeRecordControl__c WHERE RecordDate__c =: insDate  LIMIT : QUERY_LIMIT]);
        return lstTimeRecToPost;
    }

    // Execute
    global void execute(Database.BatchableContext BC, List<TimeRecordControl__c> lstTimeRecToPost){
        if(!lstTimeRecToPost.isEmpty()){
            doCreateRemote(lstTimeRecToPost);
        }
    }

    // Finish
    global void finish(Database.BatchableContext BC){
        if (!Test.isRunningTest()) {
            DateTime currDayTime = System.now();
            System.debug(LoggingLevel.INFO,'Current DateTime is: '+currDayTime);
            Integer currHour = currDayTime.hour();
            System.debug(LoggingLevel.INFO,'Current hour is: '+currHour);
            Integer currMinute = currDayTime.minute();
            System.debug(LoggingLevel.INFO,'Current minute is: '+currMinute);
            if(currHour==02 && currMinute==30){
                System.debug(LoggingLevel.DEBUG, 'End of BatchSendTimeRecordControls at: '+currHour+':'+currDayTime.minute());
                Database.executeBatch(new BatchDeleteTimeRecordControls());
            }else{
                scheduleMe(CRON_INTERVAL, BATCH_SIZE);
            }
		}
    }

    // Util methods
    private static void scheduleMe(Integer interval, Integer batchSize) {
		System.scheduleBatch(new BatchSendTimeRecordControls(), Test.isRunningTest() ? 'ScheduleTestBatchSendTimeRecordControls' : 'BatchSendTimeRecordControls', interval, batchSize);
	}

    private static void doCreateRemote(List<TimeRecordControl__c> lstTimeRecToPost){
        CalloutsManagement.doCreate(lstTimeRecToPost);
    }
}