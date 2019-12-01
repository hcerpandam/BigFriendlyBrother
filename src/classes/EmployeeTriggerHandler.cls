/**
* @author       Héctor Cervera Panella
* @date         26/11/2019
*               Implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class EmployeeTriggerHandler implements ITrigger {

    // Var declaration
    private static User u = [SELECT Id, Profile.Name FROM User WHERE Id = : UserInfo.getUserId()]; // User executing code

    // Constant declaration
    private final static String HHRR_PROF_NAME = 'HumanResources';

    // Builder

    // Handler before methods

    /**
    * This method is called prior to execution of a BEFORE trigger. 
    * Use this to cache any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {

        if(Trigger.isInsert || Trigger.isUpdate){

            List<Employee__c> lstEmp = (List<Employee__c>)Trigger.new;
            List<Id> lstIdLinkedUsers = new List<Id>();

            for(Employee__c empInstance: lstEmp){
                lstIdLinkedUsers.add(empInstance.LinkedUser__c);
            }

            List<User> lstUsers = [SELECT Id, Name, MobilePhone, Email FROM User WHERE Id IN :lstIdLinkedUsers];

            for(Employee__c emp: lstEmp){
                for(User u: lstUsers){
                    String strErrorMsg = null;

                    if(emp.LinkedUser__c == null){
                        strErrorMsg = 'No puede generarse un empleado sin usuario vinculado';
                    }else if(emp.LinkedUser__c==u.Id){
                        if(emp.MobilePhone__c!=null){
                            if(emp.MobilePhone__c!=u.MobilePhone){
                                strErrorMsg = 'El teléfono móvil debe ser igual al del usuario vinculado';
                            }
                        }

                        if(String.isBlank(strErrorMsg) && emp.EmployeeEmail__c!=null){
                            if(emp.EmployeeEmail__c!=u.Email){
                                strErrorMsg = 'El email debe ser igual al del usuario vinculado';
                            }
                        }

                        if(String.isBlank(strErrorMsg) && emp.FullName__c!=null){
                            if(emp.FullName__c!=u.Name){
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
        
    }

    public void beforeInsert(SObject sObj) {  
  
    }

    public void beforeUpdate(SObject oldSobj, SObject sObj) {
        
        Employee__c newEmp = (Employee__c)sObj;
        Employee__c oldEmp = (Employee__c)sObj;

        String strErrorMsg = null;

        if(u.Profile.Name!=HHRR_PROF_NAME){
            if(newEmp.CurrentLinkedHeadquarters__c!=oldEmp.CurrentLinkedHeadquarters__c){
                strErrorMsg = 'Solo Recursos Humanos puede modificar la sede asociada';
            }
        }

        if(!String.isBlank(strErrorMsg)){
            newEmp.addError(strErrorMsg);
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

}