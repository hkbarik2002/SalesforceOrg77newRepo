public class Batch_IncreaseRentPerDay implements Database.batchable<sObject> {
    public string sCatagory;
    public Batch_IncreaseRentPerDay(string cata){
        this.sCatagory = cata;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('sCatagory>>>>'+sCatagory);
        return Database.getQueryLocator([SELECT Id,Name__c, Category__c,DailyRent__c  FROM Car__c  WHERE  Category__c =:sCatagory AND DailyRent__c != null]);
    }
    public void execute(Database.BatchableContext bc,List<sObject> scope){
        system.debug('scope>>>>'+scope);
        List<Car__c> carList  = (List<Car__c>)scope;
        // system.debug('carList>>>>'+carList);
        Map<Id,Decimal> mapIdAmount = new Map<Id,Decimal>();
        for(Car__c cl : carList ){
            mapIdAmount.put(cl.Id,!mapIdAmount.containsKey(cl.Id)?cl.DailyRent__c:mapIdAmount.get(cl.Id));
        }
        system.debug('mapIdAmount>>>'+mapIdAmount);
        List<Car__c> upCarList = new List<Car__c>();
        for(Car__c cl2 : carList){
            Decimal calAmount;
            if(mapIdAmount.containsKey(cl2.Id)){
                Decimal amo = mapIdAmount.get(cl2.Id);
                calAmount = (amo*.1)+cl2.DailyRent__c;
            }
            cl2.DailyRent__c = calAmount;
            upCarList.add(cl2);       
        }
        system.debug('upCarList>>>'+upCarList);
        if(!upCarList.isEmpty()){
            //update upCarList;
        }
    } 
    public void finish(Database.BatchableContext bc){
        
    }
}