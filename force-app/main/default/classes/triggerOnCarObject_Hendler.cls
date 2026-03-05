public with sharing class triggerOnCarObject_Hendler {
    public static void fairPlatformEvent(List<Car__c> newListOfCar) {
        if(newListOfCar == null || newListOfCar.isEmpty()) {
            return;
        }
        
        List<AfterInsertCar_Pv__e> eventList = new List<AfterInsertCar_Pv__e>();
        
        for(Car__c car : newListOfCar){
            eventList.add(
                new AfterInsertCar_Pv__e(
                Message__c = 'CarInserted'));
        }
        
        // Publish all events together
        List<Database.SaveResult> results = EventBus.publish(eventList);
        
        // Check for errors
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                System.debug('Error: ' + sr.getErrors()[0].getMessage());
            }
        }
    }
}