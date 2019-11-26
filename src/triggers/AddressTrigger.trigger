trigger AddressTrigger on Address (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.createHandler(Address.sObjectType);
}