/**
* @author       Héctor Cervera Panella
* @date         26/11/2019
*               Implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class EmployeeTriggerHandler implements ITrigger {

    // Var declaration

    // Constant declaration

    private final static String GOD_PROF_NAME = 'GodBigFriendlyBrother';

    // Builder

    // Handler before methods

    /**
    * This method is called prior to execution of a BEFORE trigger. 
    * Use this to cache any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {

        if(Trigger.isInsert || Trigger.isUpdate){

            List<Employee__c> lstEmp = (List<Employee__c>)Trigger.new;

            for(Employee__c emp: lstEmp){
                String strErrorMsg = null;

                if(emp.LinkedUser__c == null){
                    strErrorMsg = 'No puede generarse un empleado sin usuario vinculado';
                }else{
                    if(emp.MobilePhone__c!=null){
                        if(emp.MobilePhone__c!=emp.LinkedUser__r.MobilePhone){
                            System.debug(LoggingLevel.DEBUG, 'emp.LinkedUser__r.MobilePhone: '+emp.LinkedUser__r.MobilePhone);
                            strErrorMsg = 'El teléfono móvil debe ser igual al del usuario vinculado';
                        }
                    }

                    if(String.isBlank(strErrorMsg) && emp.EmployeeEmail__c!=null){
                        if(emp.LinkedUser__r.Email!=emp.EmployeeEmail__c){
                            strErrorMsg = 'El email debe ser igual al del usuario vinculado';
                        }
                    }

                    if(String.isBlank(strErrorMsg) && emp.FullName__c!=null){
                        if(emp.LinkedUser__r.Name!=emp.FullName__c){
                            strErrorMsg = 'No puede modificarse el usuario vinculado';
                        }
                    }

                    if(String.isBlank(strErrorMsg) && emp.CompanyId__c!=null){
                        if(!String.valueOf(emp.CompanyId__c).endsWith('@techconsultant.com')){
                            strErrorMsg = 'El identificador de compañía debe seguir el formato xxx@@techconsultant.com';
                        }                      
                    }
                }
                if(!String.isBlank(strErrorMsg)){
                    emp.addError(strErrorMsg);
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