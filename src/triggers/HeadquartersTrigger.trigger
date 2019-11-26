trigger HeadquartersTrigger on Headquarters__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.createHandler(Headquarters__c.sObjectType);
}