public with sharing class PaginationForAccountController {
     @AuraEnabled(cacheable = true)
    public static List<Account> getAccount(Integer pageSize,Integer pageNumber){
        try {
            If(pageNumber == null || pageNumber < 1){
                pageNumber = 1;
            }
            If(pageSize == null || pageSize < 1){
                pageSize = 5;
            }
            Integer offset = (pageNumber - 1)*pageSize;
            List<Account> acc1 = [Select Name,Type,BillingCity,BillingState From Account ORDER BY Name ASC LIMIT : pageSize OFFSET :offset];
            return acc1;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Integer totalAccountCount(String searchKEy){
        try {
            String query = 'Select Count() from Account';
            return Database.countQuery(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}