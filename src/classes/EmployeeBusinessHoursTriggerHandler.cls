/**
* @author       Héctor Cervera Panella
* @date         26/11/2019
*               Implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class EmployeeBusinessHoursTriggerHandler implements ITrigger {

    // Var declaration

    // Constant declaration

    // Builder

    // Handler before methods

    /**
    * This method is called prior to execution of a BEFORE trigger. 
    * Use this to cache any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {
        List<EmployeeBusinessHours__c> lstEmpBusHrs = (List<EmployeeBusinessHours__c>)Trigger.new;

        if(Trigger.isInsert || Trigger.isUpdate){
            for(EmployeeBusinessHours__c empBusHrs: lstEmpBusHrs){
                String strErrorMsg = null;

                if(empBusHrs.StartTime__c!=null && empBusHrs.EndTime__c!=null){
                    if(empBusHrs.StartTime__c<empBusHrs.EndTime__c){
                        strErrorMsg = 'La hora de salida no puede ser anterior a la de entrada';
                    }
                }

                if(!String.isBlank(strErrorMsg)){
                    empBusHrs.addError(strErrorMsg);
                }
            }
        }
        
    }

    public void beforeInsert(SObject sObj) {  

    }

    public void beforeUpdate(SObject oldSobj, SObject sObj) {
        
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