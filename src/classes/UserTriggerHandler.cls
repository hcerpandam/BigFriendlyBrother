/**
* @author       Héctor Cervera Panella
* @date         26/11/2019
*               Implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
*/
public with sharing class UserTriggerHandler implements ITrigger{

    // Var declaration

    // Constant declaration

    // Builder

    // Handler before methods

    /**
    * This method is called prior to execution of a BEFORE trigger. 
    * Use this to cache any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {

    }

    public void beforeInsert(SObject sObj) {
        User u = (User)sObj;
        String strErrorMsg = null;

        if(String.isBlank(String.valueOf(u.MobilePhone))){
            strErrorMsg = 'El móvil del usuario es un campo obligatorio';
        }else if(validateMobilePhone(String.valueOf(u.MobilePhone))==false){
            strErrorMsg = 'El teléfono móvil no es válido';
        }
        if(!String.isBlank(strErrorMsg)){
            u.addError(strErrorMsg);
        }
    }

    public void beforeUpdate(SObject oldSobj, SObject sObj) {
        User newU = (User)sObj;
        User oldU = (User)oldSobj;

        String strErrorMsg = null;

        if(newU.MobilePhone!=oldU.MobilePhone){
            if(validateMobilePhone(String.valueOf(newU.MobilePhone))==false){
                strErrorMsg = 'El teléfono móvil no es válido';
                newU.addError(strErrorMsg);
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

    private static boolean validateMobilePhone(String phoneNum){
        
        String strRegex = '(0034|\\+34)?(\\d\\d\\d)-? ?(\\d\\d)-? ?(\\d)-? ?(\\d)-? ?(\\d\\d)';
        boolean proceed = Pattern.matches(strRegex,phoneNum);

        return proceed;
    }
    
}