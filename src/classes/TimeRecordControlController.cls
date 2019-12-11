global with sharing class TimeRecordControlController {

    private static User u = [SELECT Id, Name FROM User WHERE Id = : UserInfo.getUserId()]; // User executing code
    private static Employee__c emp = [SELECT Id, LinkedUser__r.Id FROM Employee__c WHERE LinkedUser__r.Id = : u.Id ]; // Related employee. Can throw exception
    private static Datetime currDayTime = datetime.now();
    private static Date todayDate = Date.today();
    private static TimeRecordControl__c timeRec = new TimeRecordControl__c();

    // Check if the employee must work today: If true create new TimeRecordControl__c, else display spinner
    @AuraEnabled
    public static boolean employeeMustWork(){

        // If there is any previous TimeRecordControl__c created for today by batch
        List<TimeRecordControl__c> lstTimeRec = new List<TimeRecordControl__c>([SELECT Id, EndWorkingTime__c, TimeRecordControlId__r.EmployeeId__r.LinkedUser__r.Id
                                FROM TimeRecordControl__c 
                                WHERE TimeRecordControlId__r.EmployeeId__r.LinkedUser__r.Id =: u.Id
                                AND RecordDate__c =: todayDate
                                AND EndWorkingTime__c!=null
                                LIMIT 1]);
        
        Boolean canWork = lstTimeRec.isEmpty() ? true: false;
        
        // True: New TimeRecordControl__c
        if(canWork){
            timeRec.RecordDate__c = todayDate;
            timeRec.StartWorkingTime__c = Time.newInstance(currDayTime.hour(), currDayTime.minute(), currDayTime.second(), currDayTime.millisecond());
            timeRec.TimeRecordControlId__c = [SELECT Id FROM MonthlyTimeRecordControl__c 
                                              WHERE EmployeeId__r.LinkedUser__r.Id =: u.Id 
                                              AND RangeStart__c=:todayDate.toStartOfMonth() 
                                              LIMIT 1].Id;
            
            if(timeRec.TimeRecordControlId__c!=null){
                insert timeRec;
            } 
        }

        return canWork;
    }

    // Check if the employee geolocation matches any of the company headquarters
    @AuraEnabled
    public static Boolean employeeIsAtHeadquarters(Decimal decLatitude, Decimal decLongitude){
		System.debug('En employeeIsAtHeadquarters');
        List<Headquarters__c> lstHeadquarters = new List<Headquarters__c>([SELECT Name, HeadquartersGeolocation__Latitude__s, HeadquartersGeolocation__Longitude__s 
                                                                          FROM Headquarters__c
                                                                          WHERE HeadquartersGeolocation__Latitude__s =: decLatitude
                                                                          AND HeadquartersGeolocation__Longitude__s =: decLongitude
                                                                          LIMIT 1]);
               
        boolean checkTeleworking = lstHeadquarters.isEmpty() ? true: false;

        if(checkTeleworking){
            timeRec.isTeleworking__c = true;
        }else{
            for(Headquarters__c sede: lstHeadquarters){
                timeRec.GeolocationOnCheckEndWorkingHours__Latitude__s = sede.HeadquartersGeolocation__Latitude__s;
                timeRec.GeolocationOnCheckEndWorkingHours__Longitude__s = sede.HeadquartersGeolocation__Longitude__s;
            }
        }
        
        update timeRec;
        return checkTeleworking;
    }
}