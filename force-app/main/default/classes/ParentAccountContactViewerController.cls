public class ParentAccountContactViewerController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAllContactRelatedToAccount(Id accountId) {
        if(accountId == null) return null;
        return [SELECT Id, Name, Email FROM Contact WHERE AccountId = :accountId];
    }
}