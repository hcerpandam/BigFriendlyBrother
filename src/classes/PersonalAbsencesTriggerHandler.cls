/**
* @author       Héctor Cervera Panella
* @date         26/11/2019
*               Implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class PersonalAbsencesTriggerHandler implements ITrigger {

    // Var declaration
    private static User u = [SELECT Id, Profile.Name FROM User WHERE Id = : UserInfo.getUserId()]; // User executing code
    private static List<String> lstabsenceCausesByHHHRR = new List<String>{'Fallecimiento/Enfermedad hasta segundo grado','Enfermedad laboral','Enfermedad no laboral'};

    // Constant declaration
    private final static String HHRR_ROLE_NAME = 'HumanResources';
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

        PersonalAbsences__c instance = (PersonalAbsences__c)sObj;
        String strErrorMsg = null;

        if(u.Profile.Name!=HHRR_ROLE_NAME && u.Profile.Name!=GOD_PROF_NAME){
            if(!String.isBlank((String.valueOf(instance.AbsenceReason__c)))){
                if(!lstabsenceCausesByHHHRR.contains(String.valueOf(instance.AbsenceReason__c))){
                    strErrorMsg = 'Solo Recursos Humanos puede marcar esta causa de justificación';
                }
            }
        }else if(!String.isBlank(String.valueOf(instance.AbsenceReason__c)) && (!String.isBlank(String.valueOf(instance.AbsenceStart__c)) || !String.isBlank(String.valueOf(instance.AbsenceEnd__c)))){
            if((String.valueOf(instance.AbsenceReason__c))!='Vacaciones' && (lstabsenceCausesByHHHRR.contains(instance.AbsenceReason__c) || 
                lstabsenceCausesByHHHRR.contains(instance.AbsenceReason__c))){
                strErrorMsg = 'Los plazos de inicio y fin son inalterables';
            }
        }
        if(!String.isBlank(strErrorMsg)){
            instance.addError(strErrorMsg);
        }
    }

    public void beforeUpdate(SObject oldSobj, SObject sObj) {

        PersonalAbsences__c oldInstance = (PersonalAbsences__c)oldSobj;
        PersonalAbsences__c newInstance = (PersonalAbsences__c)sObj;

        String strErrorMsg = null;

        if(u.Profile.Name!=HHRR_ROLE_NAME && u.Profile.Name!=GOD_PROF_NAME){
            if(newInstance.AbsenceReason__c!=oldInstance.AbsenceReason__c){
                if(!lstabsenceCausesByHHHRR.contains(String.valueOf(newInstance.AbsenceReason__c))){
                    strErrorMsg = 'Solo Recursos Humanos puede marcar esta causa de justificación';
                }
            }
        }else if((newInstance.AbsenceStart__c!=oldInstance.AbsenceStart__c) || (newInstance.AbsenceEnd__c!=oldInstance.AbsenceEnd__c)){
            if((String.valueOf(newInstance.AbsenceReason__c))!='Vacaciones' && (lstabsenceCausesByHHHRR.contains(newInstance.AbsenceReason__c) || 
                lstabsenceCausesByHHHRR.contains(oldInstance.AbsenceReason__c))){
                strErrorMsg = 'Los plazos de inicio y fin son inalterables';
            }
        }
        if(!String.isBlank(strErrorMsg)){
            newInstance.addError(strErrorMsg);
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