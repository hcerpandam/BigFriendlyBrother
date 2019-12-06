/**
 * @file        BatchReprocessLeadDigital.apxc
 * @author      Héctor Cervera Panella
 * @date        05/12/2019
 * @description AutoScheduled batch to:
 *              Manage all diferent callouts defined in project 
 */
global with sharing class CalloutsManagement {
    
    // Constants
    private final static String VERB_GET = 'GET';
    private final static String VERB_POST = 'POST';
    private final static String VERB_DELETE = 'DELETE';
    private final static String AUTH = 'Basic bm9tcWprdGtwdXdud3I6NjI3ZmI0Yjc3Y2ZkNmE1MWQ0Yzk3ZWIxYmQzNjQ2N2IzZWM5MDVmZWVkNzNjODc4MDJmYzkyYTAxOGRiNTcxNA==';
    private final static String SENDPOINT = 'https://time-record-api.herokuapp.com';

    // Builders

    global CalloutsManagement(){}

    // Methods: Invoked from batch

    public static void doDelete(){
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();

        req.setMethod(VERB_DELETE);
        req.setEndpoint(SENDPOINT);
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

    public static void doCreate(List<TimeRecordControl__c> lstToCreate){
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();

        req.setMethod(VERB_POST);
        req.setEndpoint(SENDPOINT);
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

    /*public class TimeRecordControlQueable implements Queueable, Database.AllowsCallouts {

        //Envío
        private List <LeadDigitalWrapper> lstEncolables;
        private String endpoint;
        private EnergyLeadDigitalSendCCIntegration.DigitalEnergyLeadRequest eLeadRequest;
        //Informativo
        private GPMIR_obj_energyLead__c eLead;
        //Respuesta
        private EnergyLeadDigitalSendCCIntegration.DigitalEnergyLeadResponse eLeadResponse;
        //Actualización
        private List <GPMIR_obj_energyLead__c> updateStages = new List <GPMIR_obj_energyLead__c>();
        
        public EnergyLeadQueable(List <LeadDigitalWrapper> lstEncolables){
            this.lstEncolables=lstEncolables;
        }
        
        public void execute(QueueableContext context) {

            // Lock register in logger while doing callouts
            Wso2AbstractIntegration.executeFinishCallouts = false;
            // Execute save data logger and tokens in the same thread (synchronous)
            Wso2AbstractIntegration.executeWithJobs = false;
            
            EnergyLeadDigitalSendCCIntegration instanceImplementation = new EnergyLeadDigitalSendCCImplementation();
            
            for(LeadDigitalWrapper encolable : this.lstEncolables){
                endpoint=encolable.endpoint;                     
                EnergyLeadDigitalSendCCIntegration.DigitalEnergyLeadRequest eLeadRequest=encolable.eLeadRequest;
                eLead=encolable.eLead;
                System.debug(logginglevel.INFO,'Encolando el registro con Id '+eLead.Id);

                if(Test.isRunningTest()){
                    eLeadResponse = new EnergyLeadDigitalSendCCIntegration.DigitalEnergyLeadResponse(); 
                    eLeadResponse.code='400';
                    eLeadResponse.closed = false;
                    eLead.ServiceResponse__c=eLeadResponse.code+' Bad Request: La petición no está debidamente formada';
                    eLead.GPMIR_fld_stage__c='KO';
                }else{
                    eLeadResponse = instanceImplementation.sendToAgencies(endpoint, eLeadRequest);                   
                    if(eLeadResponse.code==null){
                        if(eLeadResponse.closed == false){
                            eLead.GPMIR_fld_stage__c='Enviado a Agencia';
                            eLead.ServiceResponse__c='200: Not closed';
                            System.debug(logginglevel.DEBUG,'El registro se ha enviado correctamente a la agencia. GPMIR_fld_stage__c: '+eLead.GPMIR_fld_stage__c);
                        } else if(eLeadResponse.closed == true){
                            eLead.GPMIR_fld_stage__c='KO-Duplicado';
                            eLead.ServiceResponse__c='200: Closed';
                            System.debug(logginglevel.DEBUG,'El registro ya ha sido tratado y está duplicado en la agencia. GPMIR_fld_stage__c: '+eLead.GPMIR_fld_stage__c);
                        }          
                    }else if(eLeadResponse.code.equals('400')){
                        eLead.GPMIR_fld_stage__c='KO';
                        eLead.ServiceResponse__c=eLeadResponse.code+' Bad Request: La petición no está debidamente formada';
                        System.debug(logginglevel.ERROR,'El registro no ha llegado a la agencia. (400) Bad Request: La petición no está debidamente formada');
                    }else if(eLeadResponse.code.equals('403')){
                        eLead.GPMIR_fld_stage__c='KO';
                        eLead.ServiceResponse__c='403 Unauthorized: La clave no es correcta';
                        System.debug(logginglevel.ERROR,'El registro no ha llegado a la agencia. (403) Unauthorized: La clave no es correcta');
                    }else if(eLeadResponse.code.equals('404')){
                        eLead.GPMIR_fld_stage__c='KO';
                        eLead.ServiceResponse__c='404 Not Found: El endpoint no existe';
                        System.debug(logginglevel.ERROR,'El registro no ha llegado a la agencia. (404) Not Found: El endpoint no existe');
                    }else{
                        eLead.GPMIR_fld_stage__c='KO';
                        eLead.ServiceResponse__c=eLeadResponse.code;
                        System.debug(logginglevel.ERROR,'El registro no ha llegado a la agencia. Error: '+eLeadResponse.code);
                    }
                }
                updateStages.add(eLead);
            }
            
            if(!updateStages.isEmpty()) {
                System.debug(logginglevel.INFO,'Se va a proceder a actualizar el GPMIR_fld_stage__c y ServiceResponse__c  de '+updateStages.size()+ ' registros');
                try {  
                    Update updateStages;
                    System.debug(logginglevel.DEBUG,'Actualización correcta de los registros');
                } catch(DmlException e) {
                    System.debug(logginglevel.ERROR,'Ha fallado la actualización de los registros. Excepción capturada: ' + e.getMessage());
                } 
            }
        }
    }*/

}