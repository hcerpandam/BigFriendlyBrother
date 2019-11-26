trigger EmployeeTrigger on Employee__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.createHandler(Employee__c.sObjectType);
}