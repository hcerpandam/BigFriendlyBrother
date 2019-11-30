/**
* @author       Héctor Cervera Panella
* @date         26/11/2019
*               Implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class TimeRecordControlTriggerHandler implements ITrigger {

    // Var declaration
    private static User u = [SELECT Id, UserRole.Name FROM User WHERE Id = : UserInfo.getUserId()]; // User executing code

    // Constant declaration
    private final static String EMP_PROF_NAME = 'Employee';
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
            if(newTimeRec.Status__c == 'Fraudulento' && u.UserRole.Name == EMP_PROF_NAME){
                strErrorMsg = 'El empleado no puede marcar el registro como fraudulento';
            }else if(newTimeRec.Status__c == 'Contencioso' && u.UserRole.Name != EMP_PROF_NAME){
                strErrorMsg = 'Solo el empleado puede marcar el registro como contencioso';
            }else if(newTimeRec.Status__c == 'Resuelto Inspección' && u.UserRole.Name != LI_PROF_NAME){
                strErrorMsg = 'Solo Inspección de Trabajo puede marcar el registro como Resuelto inspección';
            }
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