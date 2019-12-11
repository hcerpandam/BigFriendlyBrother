/**
 * @file        BatchInformEmployeeHasLeftWorkplace.apxc
 * @author      Héctor Cervera Panella
 * @date        06/12/2019
 * @description AutoScheduled batch to:
 *              Inform EmployeeHasLeftWorkplace__c according to previous and current geolocation
 */
global class BatchInformEmployeeHasLeftWorkplace implements Database.Batchable<sObject>, Database.Stateful{

    // Vars
    private List<TimeRecordControl__c> lstTimeRecToInform = new List<TimeRecordControl__c>();
    private List<TimeRecordControl__c> lstTimeRecToUpdate = new List<TimeRecordControl__c>();
    private Integer CRON_INTERVAL;
    private Integer CRON_INTERVAL_NIGHT;
	private Integer BATCH_SIZE;
	private Integer QUERY_LIMIT;
    private Date insDate = System.today();
    private DateTime insDateTime = System.now();
    private Time currTime = insDateTime.time();

    // Builder
    global BatchInformEmployeeHasLeftWorkplace(){
        CRON_INTERVAL = 10;
        BATCH_SIZE = 200;
        QUERY_LIMIT = 5000;
        CRON_INTERVAL_NIGHT = 600;
    }

    // Start
    global List<TimeRecordControl__c> start(Database.BatchableContext BC) {
        lstTimeRecToInform = new List<TimeRecordControl__c>([SELECT Id, isTeleworking__c, EndWorkingTime__c, EmployeeHasLeftWorkplace__c,  TimeRecordControlId__r.EmployeeId__r.MobilePhone__c, 
                        StartWorkingHoursGeolocation__Latitude__s, StartWorkingHoursGeolocation__Longitude__s, GeolocationOnCheckEndWorkingHours__Latitude__s, 
                        GeolocationOnCheckEndWorkingHours__Longitude__s, CheckEndWorkingHours__c, EndCheckEndWorkingHours__c, RecordedByCompany__c 
                        FROM TimeRecordControl__c
                        WHERE RecordDate__c =: insDate 
                        AND isTeleworking__c = FALSE 
                        AND CheckEndWorkingHours__c >=:currTime 
                        AND EndCheckEndWorkingHours__c <=: currTime 
                        AND EmployeeHasLeftWorkplace__c!=TRUE
                        AND EndWorkingTime__c!=NULL
                        LIMIT : QUERY_LIMIT]);
        return lstTimeRecToInform;
    }

    // Execute
    global void execute(Database.BatchableContext BC, List<TimeRecordControl__c> lstTimeRecToInform){
        if(!lstTimeRecToInform.isEmpty()){
            for(TimeRecordControl__c ins: lstTimeRecToInform){
                if(ins.StartWorkingHoursGeolocation__Latitude__s!=ins.GeolocationOnCheckEndWorkingHours__Latitude__s && 
                ins.StartWorkingHoursGeolocation__Longitude__s!=ins.GeolocationOnCheckEndWorkingHours__Longitude__s){
                    ins.EmployeeHasLeftWorkplace__c = true;
                    lstTimeRecToUpdate.add(ins);
                }
            }
        }
        if(lstTimeRecToUpdate.isEmpty()){
            update lstTimeRecToUpdate;
        }
    }

    // Finish
    global void finish(Database.BatchableContext BC){
        if (!Test.isRunningTest()) {
            DateTime currDayTime = System.now();
            System.debug(LoggingLevel.INFO,'Current DateTime is: '+currDayTime);
            Integer currHour = currDayTime.hour();
            System.debug(LoggingLevel.INFO,'Current hour is: '+currHour);

            if(currHour==23){
                scheduleMe(CRON_INTERVAL_NIGHT, BATCH_SIZE);
                System.debug(LoggingLevel.DEBUG, 'End of BatchInformEmployeeHasLeftWorkplace at: '+currHour);
            }else{
                scheduleMe(CRON_INTERVAL, BATCH_SIZE);
            }
		}
    }

    // Util methods
    private static void scheduleMe(Integer interval, Integer batchSize) {
		System.scheduleBatch(new BatchInformEmployeeHasLeftWorkplace(), Test.isRunningTest() ? 'ScheduleTestBatchInformEmployeeHasLeftWorkplace' : 'BatchInformEmployeeHasLeftWorkplace', interval, batchSize);
	}

}