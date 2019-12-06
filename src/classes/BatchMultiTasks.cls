/**
 * @file        BatchReprocessLeadDigital.apxc
 * @author      Héctor Cervera Panella
 * @date        02/12/2019
 * @description AutoScheduled batch to:
 *              Create month time record controls 
 *              Create time record controls
 *              Inform non supervenue absences including holidays
 */
global class BatchMultiTasks implements Database.Batchable<sObject>, Database.Stateful{

    // Vars
	private static List<Employee__c> lstEmployees;
    private static List<TimeRecordControl__c> lstTimeRec;
    private static List<MonthlyTimeRecordControl__c> lstMonTimeRec;
    private static Date insDate = Date.today();
    private Map<Integer,Integer> mapDaysByMonth;

    private Integer CRON_INTERVAL;
    private Integer CRON_INTERVAL_WEEK;
	private Integer BATCH_SIZE;
	private Integer QUERY_LIMIT;

    // Builder
	global BatchMultiTasks(){
        CRON_INTERVAL = 10;
        BATCH_SIZE = 200;
        QUERY_LIMIT = 2500;
        CRON_INTERVAL_WEEK = 10080;
    }

    // Start
    global List<Employee__c> start(Database.BatchableContext BC) {
        
        lstEmployees = new List<Employee__c>([SELECT Id, PersonalAbsencesId__c, PersonalAbsencesId__r.ApprovedByHHRR__c, PersonalAbsencesId__r.AbsenceStart__c, 
                        PersonalAbsencesId__r.AbsenceEnd__c, PersonalAbsencesId__r.DailyAbsenceRangeNotSupervening__c, CurrentLinkedHeadquarters__r.Name
                        FROM Employee__c 
                        WHERE PersonalAbsencesId__c  =:null OR PersonalAbsencesId__r.AbsenceEnd__c > : insDate
                        LIMIT : QUERY_LIMIT]);
                                          
        List<Id> lstIdEmployees = getId(lstEmployees);
        Map<Integer,Integer> mapDaysByMonth = getDaysByMonth();
        lstMonTimeRec = new List<MonthlyTimeRecordControl__c>([SELECT Id, RangeStart__c, RangeEnd__c, EmployeeId__c
                        FROM MonthlyTimeRecordControl__c 
                        WHERE EmployeeId__c 
                        IN : lstIdEmployees 
                        AND RangeEnd__c  > :insDate
                        LIMIT : QUERY_LIMIT]);
        return lstEmployees;  
    }

    // Execute
    global void execute(Database.BatchableContext BC, List<Employee__c> lstEmployees){
        
		List<MonthlyTimeRecordControl__c> lstMonthTimeRecToCreate = new List<MonthlyTimeRecordControl__c>();
        List<TimeRecordControl__c> lstTimeRecToCreate = new List<TimeRecordControl__c>();
      
        List<HolidaysByHeadquarters__c> lstCs = HolidaysByHeadquarters__c.getAll().values();
        Date dat;
        Date datMonthly;
        Date dat1 = insDate;
        Date dat2 = insDate.addDays(1);
        Date dat3 = insDate.addDays(2);
        Date dat4 = insDate.addDays(3);
        Date dat5 = insDate.addDays(4);
        Date dat6 = insDate.addDays(5);
        Date dat7 = insDate.addDays(6);

        // Create new MonthlyTimeRecordControl__c in case of mmonth change and assign them to all employees
        for(MonthlyTimeRecordControl__c monIns: lstMonTimeRec){
            if(dat1.month()!=dat7.month()){
                if(dat1.month()!=dat3.month()){
                    datMonthly = dat3;
                }else if(dat1.month()!=dat4.month()){
                    datMonthly = dat4;
                }else if(dat1.month()!=dat5.month()){
                    datMonthly = dat5;
                }else if(dat1.month()!=dat6.month()){
                    datMonthly = dat6;
                }else{
                    datMonthly = dat7;
                }
                // Generate MonthlyTimeRecordControl__c starting value of datMonthly and assign to all employees
                for(Employee__c empMonthly: lstEmployees){
                    MonthlyTimeRecordControl__c monthTimeRec = new MonthlyTimeRecordControl__c();
                    monthTimeRec.EmployeeId__c = empMonthly.Id;
                    monthTimeRec.RangeStart__c = datMonthly;
                    monthTimeRec.RangeEnd__c = Date.valueOf(mapDaysByMonth.get(datMonthly.month()));
                    lstMonthTimeRecToCreate.add(monthTimeRec);
                }
            }
        }
        
        insert lstMonthTimeRecToCreate;
		
        // Inform holidays
        for(HolidaysByHeadquarters__c insCS: lstCs){
            for(Employee__c emp: lstEmployees){
                if((emp.CurrentLinkedHeadquarters__r.Name.contains(insCS.HeadquartersName__c) || insCS.HeadquartersName__c == 'Nacional' &&
                    insDate >= Date.valueOf(insCS.HolidayDate__c) && insDate <=Date.valueOf(insCS.HolidayDate__c).addDays(4))){
                        
                    if(Date.valueOf(insCS.HolidayDate__c) == insDate){
                        dat = dat1;
                    }else if(Date.valueOf(insCS.HolidayDate__c) == dat2){
                        dat = dat2;
                    }else if(Date.valueOf(insCS.HolidayDate__c) == dat3){
                        dat = dat3;
                    }else if(Date.valueOf(insCS.HolidayDate__c) == dat4){
                        dat = dat4;
                    }else{
                        dat = dat5;
                    }
                }

                TimeRecordControl__c timeRecIns = new TimeRecordControl__c();              
                timeRecIns.RecordDate__c = dat;
                timeRecIns.isTeleworking__c = true;
                timeRecIns.Status__c = 'Aceptado';
                timeRecIns.StartWorkingTime__c = Time.newInstance(08, 00, 0, 0);
                timeRecIns.EndWorkingTime__c = Time.newInstance(17, 00, 0, 0);
                timeRecIns.BreakStart__c = Time.newInstance(11, 00, 0, 0);
                timeRecIns.BreakEnd__c = Time.newInstance(11, 15, 0, 0);               
                timeRecIns.LaunchStart__c = Time.newInstance(14, 00, 0, 0);
                timeRecIns.LaunchFinish__c = Time.newInstance(15, 00, 0, 0);
                for(MonthlyTimeRecordControl__c insMTRC : lstMonTimeRec){
                    for(MonthlyTimeRecordControl__c insMTRC2 : lstMonthTimeRecToCreate){
                    	if(insMTRC.EmployeeId__c == emp.Id){
                        	timeRecIns.TimeRecordControlId__c = insMTRC.EmployeeId__c;
                        }else if(insMTRC2.EmployeeId__c == emp.Id){
                            timeRecIns.TimeRecordControlId__c = insMTRC2.EmployeeId__c;
                        }
                	}
            	}
                lstTimeRecToCreate.add(timeRecIns);
        	}
        }
        
        // Inform non supervenue absences
        for(Employee__c emp: lstEmployees){
            if((emp.PersonalAbsencesId__c!= null && emp.PersonalAbsencesId__r.ApprovedByHHRR__c == true && 
                insDate >= Date.valueOf(emp.PersonalAbsencesId__r.AbsenceEnd__c) && 
                insDate <=Date.valueOf(emp.PersonalAbsencesId__r.AbsenceStart__c).addDays(4))){
                
                Date datAbsenceStart = Date.valueOf(emp.PersonalAbsencesId__r.AbsenceStart__c);
                Date datAbsenceEnd = Date.valueOf(emp.PersonalAbsencesId__r.AbsenceEnd__c);
                Integer numberAbsenceDaysWeek;

                if(datAbsenceStart<=insDate){
                    numberAbsenceDaysWeek = datAbsenceEnd.daysBetween(insDate)>5 ? 5 : datAbsenceEnd.daysBetween(insDate);
                }else{
                    numberAbsenceDaysWeek = datAbsenceEnd.daysBetween(datAbsenceStart)>4? 4: datAbsenceEnd.daysBetween(datAbsenceStart);
                }
                for(Integer i=0; i<=numberAbsenceDaysWeek; i++){
                    TimeRecordControl__c timeRecIns = new TimeRecordControl__c();              
                    timeRecIns.RecordDate__c = dat;
                    timeRecIns.isTeleworking__c = true;
                    timeRecIns.Status__c = 'Aceptado';
                    timeRecIns.StartWorkingTime__c = Time.newInstance(08, 00, 0, 0);
                    timeRecIns.EndWorkingTime__c = Time.newInstance(17, 00, 0, 0);
                    timeRecIns.BreakStart__c = Time.newInstance(11, 00, 0, 0);
                    timeRecIns.BreakEnd__c = Time.newInstance(11, 15, 0, 0);               
                    timeRecIns.LaunchStart__c = Time.newInstance(14, 00, 0, 0);
                    timeRecIns.LaunchFinish__c = Time.newInstance(15, 00, 0, 0);
                    for(MonthlyTimeRecordControl__c insMTRC : lstMonTimeRec){
                        for(MonthlyTimeRecordControl__c insMTRC2 : lstMonthTimeRecToCreate){
                            if(insMTRC.EmployeeId__c == emp.Id){
                                timeRecIns.TimeRecordControlId__c = insMTRC.EmployeeId__c;
                            }else if(insMTRC2.EmployeeId__c == emp.Id){
                                timeRecIns.TimeRecordControlId__c = insMTRC2.EmployeeId__c;
                            }
                        }
                    }
                    lstTimeRecToCreate.add(timeRecIns);
                }
            }
        }
        insert lstTimeRecToCreate;
    } 


    // Finish
    global void finish(Database.BatchableContext BC){
        if (!Test.isRunningTest()) {
            DateTime currDayTime = System.now();
            System.debug(LoggingLevel.INFO,'Current DateTime is: '+currDayTime);
            Integer currHour = currDayTime.hour();
            System.debug(LoggingLevel.INFO,'Current Hour is: '+currHour);
            if(currHour==07){
                scheduleMe(CRON_INTERVAL_WEEK, BATCH_SIZE);
            }else{
                scheduleMe(CRON_INTERVAL, BATCH_SIZE);
            }
		}
    }

    // Util methods
    private static List<Id> getId(List<Employee__c> lstEmployeeIns){
        List<Id> lstIds = new List<Id>();

        if(!lstEmployeeIns.isEmpty()){
            for(Employee__c insEmp: lstEmployeeIns){
                lstIds.add(insEmp.Id);
            }
        }

        return lstIds;
    }

    private static Map<Integer, Integer> getDaysByMonth(){
        Map<Integer,Integer> toReturn = new Map<Integer,Integer>();

        toReturn.put(1,31);
        toReturn.put(2,28);
        toReturn.put(3,31);
        toReturn.put(4,30);
        toReturn.put(5,31);
        toReturn.put(6,30);
        toReturn.put(7,31);
        toReturn.put(8,31);
        toReturn.put(9,30);
        toReturn.put(10,31);
        toReturn.put(11,30);
        toReturn.put(12,31);

        return toReturn;
    }

    private static void scheduleMe(Integer interval, Integer batchSize) {
		System.scheduleBatch(new BatchMultiTasks(), Test.isRunningTest() ? 'ScheduleTestBatchMultiTasks' : 'BatchMultiTasks', interval, batchSize);
	}
    
}