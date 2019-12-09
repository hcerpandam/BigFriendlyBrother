/**
 * @file        CalloutsManagement.apxc
 * @author      Héctor Cervera Panella
 * @date        06/12/2019
 * @description Contains all methods to do the CRUD to BFBSafe
 * CanFail:     Non use of @future or queables: Probably exception uncommited changes
 */
global with sharing class CalloutsManagement {
    
    // Constants
    private final static String VERB_GET = 'GET';
    private final static String VERB_POST = 'POST';
    private final static String VERB_DELETE = 'DELETE';
    private final static String AUTH = 'Basic bm9tcWprdGtwdXdud3I6NjI3ZmI0Yjc3Y2ZkNmE1MWQ0Yzk3ZWIxYmQzNjQ2N2IzZWM5MDVmZWVkNzNjODc4MDJmYzkyYTAxOGRiNTcxNA==';
    private final static String GENERIC_ENDPOINT = 'https://time-record-api.herokuapp.com';
    private final static String GET50K_ENDPOINT = 'https://time-record-api.herokuapp.com/contencioso-inaccion';
    private final static String GET50K_ENDPOINT_BY_EMPLOYEE = 'https://time-record-api.herokuapp.com/contencioso-inaccion/empleado/';

    // Builder

    global CalloutsManagement(){}

    // Methods: Invoked from batch

    // DELETE
    public static void doDelete(){
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();

        req.setMethod(VERB_DELETE);
        req.setEndpoint(GENERIC_ENDPOINT);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('Authorization', AUTH);
        req.setTimeout(2 * 60 * 1000);
        
        HttpResponse resp = new HttpResponse();
        resp = http.send(req);
        resp.getStatusCode();
        resp.getBody();
        System.debug(LoggingLevel.DEBUG, 'Answer recieved from BFBSafe: '+resp.getStatusCode());

    }

    // CREATE
    public static void doCreate(List<TimeRecordControl__c> lstToCreate){
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();

        req.setMethod(VERB_POST);
        req.setEndpoint(GENERIC_ENDPOINT);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('Authorization', AUTH);
        req.setTimeout(2 * 60 * 1000);

        req.setBody(JSON.serializePretty(lstToCreate));
        
        HttpResponse resp = new HttpResponse();
        resp = http.send(req);
        resp.getStatusCode();
        resp.getBody();
        System.debug(LoggingLevel.DEBUG, 'Answer recieved from BFBSafe: '+resp.getStatusCode());

    }

    // Methods invoked by UI

    // UPDATE
    public static void doUpdate(TimeRecordControl__c toUpdate){
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();

        req.setMethod(VERB_POST);
        req.setEndpoint(GENERIC_ENDPOINT);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('Authorization', AUTH);
        req.setTimeout(2 * 60 * 1000);

        req.setBody(JSON.serializePretty(toUpdate));
        
        HttpResponse resp = new HttpResponse();
        resp = http.send(req);
        resp.getStatusCode();
        resp.getBody();
        System.debug(LoggingLevel.DEBUG, 'Answer recieved from BFBSafe: '+resp.getStatusCode());

    }

    // GET: All TimeRecorControls wich Status__c == 'Contencioso por inacción' ORDER BY CreatedDate LIMIT 50.000 
    public static List<TimeRecordControl__c> doGet50KFirstContentious(){
        List<TimeRecordControl__c> lstReceived = new List<TimeRecordControl__c>();
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();

        req.setMethod(VERB_POST);
        req.setEndpoint(GET50K_ENDPOINT);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('Authorization', AUTH);
        req.setTimeout(2 * 60 * 1000);
        
        HttpResponse resp = new HttpResponse();
        resp = http.send(req);
        resp.getStatusCode();
        resp.getBody();
        System.debug(LoggingLevel.DEBUG, 'Answer recieved from BFBSafe: '+resp.getStatusCode());

        if(resp.getStatusCode() == 200){
            String str = resp.getBody();
            lstReceived = (List<TimeRecordControl__c>) JSON.deserialize(str, List<TimeRecordControl__c>.class);
        }

        if(!lstReceived.isEmpty()){
            for(TimeRecordControl__c insTimeRec : lstReceived){
                insTimeRec.isCopy__c = true;
            }
        }

        return lstReceived;
    }

    // GET: All TimeRecorControls wich Status__c == 'Contencioso por inacción' AND belogs to the Employee__c of the param ORDER BY CreatedDate LIMIT 50.000 
    public static List<TimeRecordControl__c> doGet50KFirstContentiousByEmployee(Employee__c emp){
        List<TimeRecordControl__c> lstReceived = new List<TimeRecordControl__c>();
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();

        req.setMethod(VERB_POST);
        req.setEndpoint(GET50K_ENDPOINT_BY_EMPLOYEE+'/'+emp.Id);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('Authorization', AUTH);
        req.setTimeout(2 * 60 * 1000);
        
        HttpResponse resp = new HttpResponse();
        resp = http.send(req);
        resp.getStatusCode();
        resp.getBody();
        System.debug(LoggingLevel.DEBUG, 'Answer recieved from BFBSafe: '+resp.getStatusCode());

        if(resp.getStatusCode() == 200){
            String str = resp.getBody();
            lstReceived = (List<TimeRecordControl__c>) JSON.deserialize(str, List<TimeRecordControl__c>.class);
        }

        if(!lstReceived.isEmpty()){
            for(TimeRecordControl__c insTimeRec : lstReceived){
                insTimeRec.isCopy__c = true;
            }
        }

        return lstReceived;
    }

}