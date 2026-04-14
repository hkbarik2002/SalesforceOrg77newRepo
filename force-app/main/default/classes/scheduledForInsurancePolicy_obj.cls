public with sharing class scheduledForInsurancePolicy_obj implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<InsurancePolicy__c  > expiringPolicies = [
            SELECT Id, Status__c 
            FROM InsurancePolicy__c   
            WHERE ValidTo__c  < TODAY 
            AND Status__c != 'Expired'
        ];
        
        for (InsurancePolicy__c   policy : expiringPolicies) {
            policy.Status__c = 'Expired';
        }
        
        if (!expiringPolicies.isEmpty()) {
            update expiringPolicies;
        }
    }
}