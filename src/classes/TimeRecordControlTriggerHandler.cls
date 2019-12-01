/**
* @author       Héctor Cervera Panella
* @date         26/11/2019
*               Implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class TimeRecordControlTriggerHandler implements ITrigger {

    // Var declaration
    private static User u = [SELECT Id, Profile.Name FROM User WHERE Id = : UserInfo.getUserId()]; // User executing code

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

    }

    public void beforeUpdate(SObject oldSobj, SObject sObj) {
        
        TimeRecordControl__c newTimeRec = (TimeRecordControl__c)sObj;
        TimeRecordControl__c oldTimeRec = (TimeRecordControl__c)oldSobj;

        String strErrorMsg = null;

        if(newTimeRec.Status__c!=oldTimeRec.Status__c){
            if(newTimeRec.Status__c == 'Resuelto Recursos Humanos' && u.Profile.Name != HHRR_ROLE_NAME){
                strErrorMsg = 'Solo Recursos Humanos puede marcar el registro como Resuelto Recursos Humanos';
            }else if(newTimeRec.Status__c == 'Contencioso' && u.Profile.Name != EMP_PROF_NAME){
                strErrorMsg = 'Solo el empleado puede marcar el registro como contencioso';
            }else if(newTimeRec.Status__c == 'Resuelto Inspección' && u.Profile.Name != LI_PROF_NAME){
                strErrorMsg = 'Solo Inspección de Trabajo puede marcar el registro como Resuelto inspección';
            }
        }

        if(newTimeRec.Status__c == 'Resuelto Recursos Humanos'){
            if(newTimeRec.RecordedByCompany__c<oldTimeRec.RecordedByCompany__c){
                strErrorMsg = 'Recursos Humanos solo puede resolver en favor del empleado';
            }
        }

        if(newTimeRec.Status__c == 'Contencioso' && String.isBlank(newTimeRec.ContentiousCause__c)){
            strErrorMsg = 'Debe indicar la causa de la discrepancia con el registro';
        }

        if(!String.isBlank(strErrorMsg)){
            newTimeRec.addError(strErrorMsg);
        }

        // Hacer supuestos de modificación por mejoras
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

}