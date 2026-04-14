public class AccountOpportunityController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchAccountAndOpportunities(String acctName) {
        Map<String, Object> result = new Map<String, Object>();
        
        Account acc = [SELECT Id, Name, Industry FROM Account WHERE Name = :acctName LIMIT 1];
        List<Opportunity> opps = [SELECT Id, Name, Amount, StageName FROM Opportunity WHERE AccountId = :acc.Id];
        
        result.put('account', acc);
        result.put('opportunities', opps);
        return result;
    }
}