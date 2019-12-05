/**
 * @file        BatchReprocessLeadDigital.apxc
 * @author      Héctor Cervera Panella
 * @date        02/12/2019
 * @description AutoScheduled batch to:
 *              Delete all daily TimeRecordsControls__c where isCopy is True
 *              Call the BFBSafe App static resource to delete all records created four years ago
 */
global class BatchDeleteTimeRecordControls implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    // Vars
    private List<TimeRecordControl__c> lstTimeRecToDelete = new List<TimeRecordControl__c>();
    
    // Constants
    private Integer CRON_INTERVAL;
    private Integer CRON_INTERVAL_DAY;
	private Integer BATCH_SIZE;
	private Integer QUERY_LIMIT;


    // Builder
    global BatchDeleteTimeRecordControls(){
        CRON_INTERVAL = 5;
        BATCH_SIZE = 200;
        QUERY_LIMIT = 10000;
        CRON_INTERVAL_DAY = 1440;
    }

    // Start
    global List<TimeRecordControl__c> start(Database.BatchableContext BC) {
        lstTimeRecToDelete = new List<TimeRecordControl__c>([SELECT Id FROM TimeRecordControl__c WHERE isCopy__c = TRUE LIMIT : QUERY_LIMIT]);
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
            System.debug(LoggingLevel.INFO,'Current DateTime is: '+currDayTime);
            Integer currMin = currDayTime.hour();
            System.debug(LoggingLevel.INFO,'Current minute is: '+currMin);
            if(currMin==15){
                scheduleMe(CRON_INTERVAL_DAY, BATCH_SIZE);
            }else{
                scheduleMe(CRON_INTERVAL, BATCH_SIZE);
            }
		}
        // Here queable job to delete from BFBSafe
    }

    // Util methods
    private static void scheduleMe(Integer interval, Integer batchSize) {
		System.scheduleBatch(new BatchDeleteTimeRecordControls(), Test.isRunningTest() ? 'ScheduleTestBatchDeleteTimeRecordControls' : 'BatchDeleteTimeRecordControls', interval, batchSize);
	}

    /*private static HttpResponse doGetResponse(){
        HTTP insHttp = new HTTP();

        HttpRequest req = new HttpRequest();
        req.setMethod(HTTP_VERB);
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Host', 'si.sirkus.es');
        req.setHeader('Host', NAMED_CRE);
        req.setHeader('Connection', 'Keep-Alive');
        req.setEndpoint(EDNPOINT);
        req.setHeader('Authorization', 'Basic bm9tcWprdGtwdXdud3I6NjI3ZmI0Yjc3Y2ZkNmE1MWQ0Yzk3ZWIxYmQzNjQ2N2IzZWM5MDVmZWVkNzNjODc4MDJmYzkyYTAxOGRiNTcxNA==');
        //req.setHeader(key, value);   
        //req.setBody('user=' + sUser +'&pass=' + sPassword);
        //req.setEndpoint('https://si.sirkus.es/api/v1/' + TOKEN + '/helper-reference/all');
        //req.setHeader('Cookie',COOKIE);
        req.setTimeout(2 * 60 * 1000);

        HttpResponse res = insHttp.send(req);
        res.getStatus();
        res.getBody();
        System.debug(LoggingLevel.DEBUG, 'Response: '+res);
    }*/
}