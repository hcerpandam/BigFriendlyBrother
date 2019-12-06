/**
* @author       Héctor Cervera Panella
* @date         26/11/2019
*               Implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class TimeRecordControlTriggerHandler implements ITrigger {

    // Var declaration
    private static User u = [SELECT Id, Profile.Name FROM User WHERE Id = : UserInfo.getUserId()]; // User executing code
    private Date insDate = System.today().addMonths(-1);

    // Constant declaration
    private final static String EMP_PROF_NAME = 'Employee';
    private final static String HHRR_ROLE_NAME = 'HumanResources';
    private final static String LI_PROF_NAME = 'LabourInspector';
    private final static String GOD_PROF_NAME = 'GodBigFriendlyBrother';

    // Builder

    // Handler before methods

    /**
    * This method is called prior to execution of a BEFORE trigger. 
    * Use this to cache any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {
        
    }

    public void beforeInsert(SObject sObj) {
        TimeRecordControl__c insTimeRec = (TimeRecordControl__c)sObj;
        if(insTimeRec.RecordDate__c<insDate){
            insTimeRec.IsCopy__c = true;
        }
    }

    public void beforeUpdate(SObject oldSobj, SObject sObj) {
        
        TimeRecordControl__c newTimeRec = (TimeRecordControl__c)sObj;
        TimeRecordControl__c oldTimeRec = (TimeRecordControl__c)oldSobj;

        String strErrorMsg = null;

        if(newTimeRec.IsCopy__c == true){
            if(u.Profile.Name != LI_PROF_NAME){
                strErrorMsg = 'Solo Inspección de Trabajo puede modificar un registro de control pasado un mes';
            }
        }

        if(!String.isBlank(strErrorMsg)){
            newTimeRec.addError(strErrorMsg);
        }else if(newTimeRec.Status__c!=oldTimeRec.Status__c){
            System.debug(LoggingLevel.DEBUG,'Profile executing code: '+u.Profile.Name);

            if(newTimeRec.Status__c == 'Resuelto Recursos Humanos' && u.Profile.Name != HHRR_ROLE_NAME){
                strErrorMsg = 'Solo Recursos Humanos puede marcar el registro como Resuelto Recursos Humanos';
            }else if(newTimeRec.Status__c == 'Contencioso' && u.Profile.Name != EMP_PROF_NAME){
                strErrorMsg = 'Solo el empleado puede marcar el registro como contencioso';
            }else if(newTimeRec.Status__c == 'Resuelto Inspección' && u.Profile.Name != LI_PROF_NAME){
                strErrorMsg = 'Solo Inspección de Trabajo puede marcar el registro como Resuelto inspección';
            }else if(u.Profile.Name == EMP_PROF_NAME && (oldTimeRec.Status__c.contains('Fraudulento') || (oldTimeRec.Status__c == 'Inspeccionar') && newTimeRec.Status__c == 'Aceptado')){
                strErrorMsg = 'El empleado no puede marcar un registro Fraudulento como Aceptado';
            }
        }

        if(!String.isBlank(strErrorMsg)){
            newTimeRec.addError(strErrorMsg);
        }else{
            if(newTimeRec.Status__c == 'Resuelto Recursos Humanos'){
                if(newTimeRec.RecordedByCompany__c<oldTimeRec.RecordedByCompany__c){
                    strErrorMsg = 'Recursos Humanos solo puede resolver en favor del empleado';
                }
            }
        }
        
        if(!String.isBlank(strErrorMsg)){
            newTimeRec.addError(strErrorMsg);
        }else{
            if(newTimeRec.Status__c == 'Contencioso' && String.isBlank(newTimeRec.ContentiousCause__c)){
                strErrorMsg = 'Debe indicar la causa de la discrepancia con el registro';
            }
        }       

        // Still need to control null pointers on breaks and non closed ranges
        if(!String.isBlank(strErrorMsg)){
            newTimeRec.addError(strErrorMsg);
        }else{
            if(newTimeRec.isTeleworking__c || newTimeRec.EmployeeHasLeftWorkplace__c == true){
                newTimeRec.RecordedByCompany__c = (toNumber(newTimeRec.EndWorkingTime__c) - newTimeRec.LaunchRange__c - ((toNumber(newTimeRec.BreakEnd__c) - toNumber(newTimeRec.BreakStart__c))-0.25) - (toNumber(newTimeRec.CheckRequirement__c) - toNumber(newTimeRec.CheckInsertion__c)) - toNumber(newTimeRec.StartWorkingTime__c));
                newTimeRec.Status__c = newTimeRec.RecordedByCompany__c> 10 ? 'Inspeccionar' : 'Aceptado';
            }else{
                if(newTimeRec.EmployeeHasLeftWorkplace__c == false){         
                    if(newTimeRec.EndWorkingTime__c!=null){
                        newTimeRec.Status__c = 'Fraudulento por no registro horas extra';
                        newTimeRec.RecordedByCompany__c = (toNumber(newTimeRec.EndWorkingTime__c) - newTimeRec.LaunchRange__c - ((toNumber(newTimeRec.BreakEnd__c) - toNumber(newTimeRec.BreakStart__c))-0.25) - (toNumber(newTimeRec.CheckRequirement__c) - toNumber(newTimeRec.CheckInsertion__c)) - toNumber(newTimeRec.StartWorkingTime__c));                  
                    }else{
                        newTimeRec.Status__c = 'Fraudulento por inacción';
                        newTimeRec.RecordedByCompany__c = 0;
                    }
                }        
            }
        }    
    }

    public void beforeDelete(SObject sObj) {

    }

    // Handler after methods

    public void bulkAfter() {

    }

    public void afterInsert(SObject sObj) {

    }

    public void afterUpdate(SObject oldSobj, SObject sObj) {
        
    }

    public void afterDelete(SObject sObj) {

    }

    /**
    * This method is called once all records have been processed by the trigger.
    * Use this method to accomplish any final operations such as creation or updates of other records.
    */
    public void andFinally() {

    }

    // Other methods

    private static boolean isNull(Decimal instance){
        return instance == null ? true: false;
    }

    private static double toNumber(Time instance){
        return (instance.hour()+instance.minute()/60);
    }
}