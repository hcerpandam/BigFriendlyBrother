trigger EmployeeBusinessHoursTrigger on EmployeeBusinessHours__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.createHandler(EmployeeBusinessHours__c.sObjectType);
}