public with sharing class CreatTransactionLwcFormController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountRecord(){
        try {
            return [SELECT Id,Name FROM Account limit 100];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string saveTransactionRecord(Transaction__c  trs){
        try {
            if(trs == null){
                throw new AuraHandledException('Transaction Record is null');
            }
            insert trs;
            system.debug('trs>>>'+trs);
            return 'Record Inserted Successfully : '+trs.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}