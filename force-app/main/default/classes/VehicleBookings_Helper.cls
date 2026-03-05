public class VehicleBookings_Helper {
    //It Update total days and total Amount field
    public static void calculateTotalDay(List<VehicleBooking__c> newListVb,Map<Id,List<Date>> mapListDate){
        Integer driveCharge = 300;
        for(VehicleBooking__c vb:newListVb){
            if(mapListDate.containsKey(vb.Id)){
                List<Date> dateList = mapListDate.get(vb.Id);
                // Integer pvTotalDay = mapListDate.containsKey(vb.Id).TotalDays__c;
                Integer totalDay = 0;
                for(Integer i = 0; i< dateList.size()-1;i++){
                    Date startD = dateList[i];
                    Date nextEnd = dateList[i+1];
                    
                    Integer diff = startD.daysBetween(nextEnd);
                    totalDay = diff > 0 ? totalDay + diff:totalDay + 0;
                }
                // system.debug('totalDay1>>'+totalDay);
                vb.TotalDays__c = totalDay;
                Decimal totalMony = vb.IsDriverRequired__c == true ? vb.RentPerDay__c * totalDay + driveCharge:vb.RentPerDay__c * totalDay; 
                vb.TotalAmount__c = totalMony;
                vb.DriverCharge__c = vb.IsDriverRequired__c == true ? driveCharge:0;
                vb.FinalAmount__c = vb.Status__c == 'Confirmed'  ? totalMony : 0;
            }else{
                Integer totalDay = 0;
                totalDay += vb.StartDate__c.daysBetween(vb.EndDate__c);
                vb.TotalDays__c = totalDay;
                //system.debug('totalDay2>>'+totalDay);
                Decimal totalMony = vb.IsDriverRequired__c == true ? vb.RentPerDay__c * totalDay + driveCharge:vb.RentPerDay__c * totalDay; 
                vb.TotalAmount__c = totalMony;
                vb.DriverCharge__c = vb.IsDriverRequired__c == true ? driveCharge:0;
                vb.FinalAmount__c = vb.Status__c == 'Confirmed'  ? totalMony : 0;
            }
        }
    }
    
    // It check which car avelable between those data that you provide.
    public static void PreventOverlappingBookings(List<VehicleBooking__c> newListVb,Map<Id,VehicleBooking__c> oldMapVb){
        Set<Id> cmId = new Set<Id>();
        Map<Id,Date> tosDate = new Map<Id,Date>();
        Map<Id,Date> toeDate = new Map<Id,Date>();
        Boolean isEndDate = false;
        for(VehicleBooking__c vb :newListVb){
            Date sd = (vb.Id != null && oldMapVb.containsKey(vb.Id))? oldMapVb.get(vb.Id).StartDate__c: null;
            
            Date ed = (vb.Id != null && oldMapVb.containsKey(vb.Id))? oldMapVb.get(vb.Id).EndDate__c: null;
            if(vb.StartDate__c == sd  && vb.EndDate__c == ed){
                break;
            }
            // system.debug('vb.StartDate__c>>>'+vb.StartDate__c+'>>sd>>>>'+sd+'>>>vb.EndDate__c>>>>'+vb.EndDate__c+'>>>ed>>>'+ed);
            isEndDate = ((vb.StartDate__c == sd || vb.StartDate__c != sd) && vb.EndDate__c != ed) ? true : false;
            
            cmId.add(vb.Car__c);
            tosDate.put(vb.Car__c,tosDate.containsKey(vb.Car__c)? tosDate.get(vb.Car__c): vb.StartDate__c);
            toeDate.put(vb.Car__c,toeDate.containsKey(vb.Car__c)? toeDate.get(vb.Car__c): vb.EndDate__c);
        }
        List<VehicleBooking__c> bookedCarList = new List<VehicleBooking__c>();
        
        for (Id carId : cmId) {
            bookedCarList.addAll([
                SELECT Id,Car__r.Name__c, StartDate__c, EndDate__c
                FROM VehicleBooking__c
                WHERE Car__c = :carId
                AND StartDate__c >= :tosDate.get(carId)
                AND EndDate__c <= :toeDate.get(carId)
            ]);
            // system.debug('bookedCarList>>>>>>'+bookedCarList);
        }
        // system.debug('isEndDate>>>'+isEndDate);
        if(!isEndDate){
            for(VehicleBooking__c vb :newListVb){
                if(bookedCarList != null){
                    for(VehicleBooking__c bc :bookedCarList){
                        vb.addError(bc.Car__r.Name__c+' Car already booked and date should be between :'+bc.StartDate__c+' To '+bc.EndDate__c);
                    }
                }
            }
        }
    }
    public static void updateCarObjeStatus(List<VehicleBooking__c> newListVb){
        set<Id> carId = new Set<Id>();
        Boolean isBooked = false; 
        Boolean isAvailable = false; 
        for(VehicleBooking__c vb:newListVb){
            if(vb.Status__c == 'Confirmed'){
                carId.add(vb.Car__c);
                isBooked = true;
            }
            if(vb.Status__c == 'Cancelled'){
                carId.add(vb.Car__c);
                isAvailable = true;
            }
        }
        if(isBooked){
            List<Car__c> carList = [select id,Status__c from Car__c where id IN:carId AND Status__c !=:'Booked'];
            List<Car__c> updateCar = new List<Car__c>();
            for(Car__c c:carList){
                c.Status__c = 'Booked';
                updateCar.add(c);
            }
            if(!updateCar.isEmpty()){
                update updateCar;
            }
        }
        if(isAvailable){
            List<Car__c> carList = [select id,Status__c from Car__c where id IN:carId];
            List<Car__c> updateCar = new List<Car__c>();
            for(Car__c c:carList){
                c.Status__c = 'Available';
                updateCar.add(c);
            }
            if(!updateCar.isEmpty()){
                update updateCar;
            }
        }
    }
    // If extends more than 7 days → auto 5% discount
    public static Boolean provideDiscount(List<VehicleBooking__c> newListVb,Map<Id,VehicleBooking__c> oldMapVb){
        Boolean isCalculate;
        for (VehicleBooking__c vbc : newListVb) {
            
            Decimal prevTotalDay = 0;
            
            if (oldMapVb.containsKey(vbc.Id)) {
                prevTotalDay = oldMapVb.get(vbc.Id).TotalDays__c;
            }
            
            // Calculate new total days
            Decimal newTotalDays = vbc.StartDate__c.daysBetween(vbc.EndDate__c);
            if(newTotalDays <= 7){
                isCalculate = false;
                break;
            }            
            // Find difference
            Decimal diff = newTotalDays - prevTotalDay;
            System.debug('diff>>>>> ' + diff);
            Decimal charge = (diff * vbc.RentPerDay__c) - (diff * vbc.RentPerDay__c * 0.05);  // 5% charge
            System.debug('Extra charge: ' + charge);
            vbc.TotalAmount__c = (diff > 7 && oldMapVb.containsKey(vbc.Id))? oldMapVb.get(vbc.Id).TotalAmount__c + charge : newTotalDays *vbc.RentPerDay__c;
            vbc.TotalDays__c = newTotalDays;
            System.debug('vbc.TotalAmount__c>>>>> ' + vbc.TotalAmount__c);
            isCalculate = diff > 7 ? true :false;
        }
        return  isCalculate;
        
    }
}