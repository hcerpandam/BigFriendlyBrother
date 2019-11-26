trigger TimeRecordControlTrigger on TimeRecordControl__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.createHandler(TimeRecordControl__c.sObjectType);
}