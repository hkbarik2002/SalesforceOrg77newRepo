public class carObjectWithPlatformEvent_Controller {
    
    @AuraEnabled
    public static List<Car__c> getCars(Integer limitSize, Integer offsetSize){
        try {
            return [select Id,Name__c,SeatingCapacity__c,Status__c,Category__c,DailyRent__c from Car__c where DailyRent__c != null order by CreatedDate DESC LIMIT :limitSize
        OFFSET :offsetSize];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String creatCarRecord(Car__c carRec){
        if(carRec != null){
            insert carRec;
            return 'Car Record Created';
        }else{
            return 'Fail to create car record';
        }
    }
    
}