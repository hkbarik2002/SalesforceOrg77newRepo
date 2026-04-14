global class MassAccountDeleteBatch
implements Database.Batchable<SObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String accountQuery =
            'SELECT Id FROM Account  ' +
            'WHERE  CreatedDate = LAST_N_DAYS:5';
        
        return Database.getQueryLocator(accountQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }
        system.debug('accountIds>>>>'+accountIds);
        List<Mass_Delete_Config__mdt> configs =
            [SELECT Child_Object__c, Lookup_Field__c
             FROM Mass_Delete_Config__mdt
             WHERE Is_Active__c = true
             ORDER BY Delete_Order__c ASC];
        system.debug('configs>>>>'+ configs);
        for (Mass_Delete_Config__mdt cfg : configs) {
            MassDeleteHelper.deleteRecords(cfg, accountIds);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Mass Account Delete Finished');
    }
}