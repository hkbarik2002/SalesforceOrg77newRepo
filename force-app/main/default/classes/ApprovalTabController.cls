public with sharing class ApprovalTabController {
    @AuraEnabled(cacheable = true)
    public static Map<String,List<SObject>> getApprovalData(){
        try {
            Set<Id> AccId = new Set<Id>();
            for(Account acc :[SELECT Id FROM Account WHERE  Id IN(select Accountid from Opportunity where AccountId != null) AND Id IN(select Accountid from Case where AccountId != null)]){
                AccId.add(acc.Id);
            }
            if(AccId.isEmpty()) return null;
            return new Map<String,List<SObject>>{
                'AccList' => [SELECT Id, Name, BillingCity FROM Account WHERE Id IN :AccId],
                'OppList' => [SELECT Id, Name, StageName, Amount, Type FROM Opportunity WHERE AccountId IN :AccId],
                'CaseList' => [SELECT Id, Subject, Account.Name, Owner.Name FROM Case WHERE AccountId IN :AccId]
            };
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Case> ApexToGetCaseData(List<Id> AccLId){
        if(AccLId.isEmpty()) throw new AuraHandledException('AccLId is Empty');
        return  [SELECT Id, Subject, Account.Name, Owner.Name FROM Case WHERE AccountId IN :AccLId];
    }
    @AuraEnabled
    public static List<Opportunity> ApexToGetOpportunityData(List<Id> OppLIds){
        if(OppLIds.isEmpty()) throw new AuraHandledException('OppLIds is Empty');
        return [SELECT Id, Name, StageName, Amount, Type FROM Opportunity WHERE Id IN :OppLIds];
    }
}