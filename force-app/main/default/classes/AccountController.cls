public with sharing class AccountController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [
            select id,Name,Industry,Phone from Account order by name asc limit 50
        ];
    }
}