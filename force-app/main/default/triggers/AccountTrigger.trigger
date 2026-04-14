trigger AccountTrigger on Account (after update ,before delete,before insert,before update) {
    if(trigger.isAfter && trigger.isUpdate){
        AccountHandler.fierAccountPlatformEvent(trigger.new,trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isDelete){
        AccountHandler.preventAccountDeletionProcess(trigger.old);
    }
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        AccountHandler.copyAccBillAddToShipAdd(trigger.new , trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
        for(Account acc : trigger.new){
            if(trigger.oldMap != null && acc.Website != trigger.oldMap.get(acc.Id).Website){
                AccountHandler.updateWebsuteOnAccount(trigger.new);
            }
        }
    }
    if(trigger.isAfter && trigger.isUpdate){
        for(Account acc : trigger.new){
            if(trigger.oldMap != null && acc.OwnerId != trigger.oldMap.get(acc.Id).OwnerId){
                AccountHandler.ownerUpdateMethod(trigger.new,trigger.oldMap,trigger.newMap);
            }
        }
    }
}