global with sharing class TimeRecordControlController {

    private static User u = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()]; // User executing code
    private static Employee__c emp = [SELECT Id, LinkedUser__r.Id FROM Employee__c WHERE LinkedUser__r.Id = : u.Id ]; // User executing code
    private static Date todayDate = Date.today();

    // Check if the employee must work today: If false display spinner, else execute employeeIsAtHeadquerts
    @AuraEnabled(cacheable=true)
    global static boolean employeeCanWork(){

        List<TimeRecordControl__c> lstTimeRec = new List<TimeRecordControl__c>([SELECT Id, EndWorkingTime__c, TimeRecordControlId__r.EmployeeId__r.LinkedUser__r.Id
                                FROM TimeRecordControl__c 
                                WHERE TimeRecordControlId__r.EmployeeId__r.LinkedUser__r.Id =: u.Id
                                AND RecordDate__c =: todayDate
                                AND EndWorkingTime__c!=null
                                LIMIT 1]);
        Boolean canWork = lstTimeRec.isEmpty() ? true: false;
        return canWork;
    }

    // Check if the employee geolocation matches any of the company headquarters
    @AuraEnabled(cacheable=true)
    public static String employeeIsAtHeadquerts(Coordinates geolocationObject){       
        List<Headquarters__c> lstHeadquarters = new List<Headquarters__c>([SELECT Name, HeadquartersGeolocation__Latitude__s, HeadquartersGeolocation__Longitude__s 
                                                                          FROM Headquarters__c
                                                                          WHERE HeadquartersGeolocation__Latitude__s =: geolocationObject.latitude
                                                                          AND HeadquartersGeolocation__Longitude__s =: geolocationObject.longitude
                                                                          LIMIT 1]);
               
        boolean checkTeleworking = lstHeadquarters.isEmpty() ? true: false;

        String strToReturn;

        if(checkTeleworking){
            strToReturn = 'Su ubicación no coincide con la de ninguna sede de la compañía. Marque la casilla de teletrabajo';
        }else{
            for(Headquarters__c sede: lstHeadquarters){
                strToReturn = 'Se encuentra usted en la sede '+sede.Name;
            }
        }

        return strToReturn;
    }

    // Get start working hours
    /*@AuraEnabled(cacheable=false)
    public static void saveNewTimeRecordControl__c(String caseToInsert){

        Case caseObject = (Case)JSON.deserialize(caseToInsert, Case.class);

        Database.SaveResult[] caseResult;
        caseResult = Database.insert(new List<Case>{caseObject}, false);
        System.debug('caseResult: ' + caseResult);

        System.debug('result: ' + caseResult);
		DmlResultWrapper resultWrap = new DmlResultWrapper(caseResult[0]);
		
        System.debug('Resultado: '+resultWrap);
		return JSON.serialize(resultWrap);
    }*/


    public class Coordinates{
        Decimal latitude;
        Decimal longitude;
    }

}