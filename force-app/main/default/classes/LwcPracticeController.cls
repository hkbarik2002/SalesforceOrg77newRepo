public with sharing class LwcPracticeController {
    @AuraEnabled(cacheable = true)
    public static Map<Id,Map<String,List<SObject>>> searchByEmailId( String WebEmails){
        Map<Id,Map<String,List<SObject>>> finalResult = new Map<Id,Map<String,List<SObject>>>();
        Set<Id> AcId = new Set<Id>();
        
        For(Account ac:[Select Id From Account Where Website =: WebEmails]){
            AcId.add(ac.Id);
        }
        Map<Id,List<Contact>> conMapList = new Map<Id,List<Contact>>();
        For(Contact co:[Select Id,AccountId,Name,Department From Contact Where AccountId =:AcId]){
            If(!conMapList.containsKey(co.AccountId)){
                conMapList.put(co.AccountId,new List<Contact>());
            }
            conMapList.get(co.AccountId).add(co);
        }
        // System.Debug('conMapList '+ conMapList);
        Map<Id,List<Opportunity>> oppMapList = new Map<Id,List<Opportunity>>();
        For(Opportunity op:[Select Id, AccountId,Name,StageName From Opportunity Where AccountId =:AcId]){
            If(!oppMapList.containsKey(op.AccountId)){
                oppMapList.put(op.AccountId,new List<Opportunity>());
            }
            oppMapList.get(op.AccountId).add(op);
        }
        // System.Debug('oppMapList '+ oppMapList);
        For(Id ids:AcId){
            Map<String,List<SObject>> innerMap = new Map<String,List<SObject>>();
            If(conMapList.containsKey(ids)){
                innerMap.put('Contacts',conMapList.get(ids));
            }
            If(oppMapList.containsKey(ids)){
                innerMap.put('Opportunitys',oppMapList.get(ids));
            }
            // System.Debug('innerMap '+ innerMap);
            If(!finalResult.containsKey(ids)){
                finalResult.put(ids,innerMap);
            }
            // System.Debug('finalResult '+ finalResult);
        }
        If(!finalResult.isEmpty()){
            // System.Debug('finalResult '+ finalResult);
            return finalResult;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Account> getAccountList(integer offS, integer limi){
        if(offS != null || limi != null){
            return [Select Id,Name,Industry,AnnualRevenue From Account LIMIT :limi OFFSET :offS];
        }
        return null;
    }
    @AuraEnabled(cacheable = true)
    public static List<Account> CountTotlAccount(){
        try {
            return [Select Id From Account];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}