trigger MonthlyTimeRecordControlTrigger on MonthlyTimeRecordControl__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.createHandler(MonthlyTimeRecordControl__c.sObjectType);
}