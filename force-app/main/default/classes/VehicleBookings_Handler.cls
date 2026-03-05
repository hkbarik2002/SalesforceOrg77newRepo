public class VehicleBookings_Handler {
    public Static void calculateTotalDays(List<VehicleBooking__c> newListVb,Map<Id,VehicleBooking__c> oldMapVb){
        if(trigger.isInsert || trigger.isUpdate){
            Date startDate;
            Date endDate;
            Integer srNo = 1;
            Boolean isCalculate = false;
            Map<Id,List<Date>> mapListDate = new Map<Id,List<Date>>();
            Map<Integer,List<Date>> mapNumListDate = new Map<Integer,List<Date>>();
            for(VehicleBooking__c vcb:newListVb){
                if(vcb.id != null && oldMapVb.get(vcb.id).Status__c =='Confirmed' && vcb.Status__c != oldMapVb.get(vcb.id).Status__c ){
                    vcb.addError('Record is locked because Status is Confirmed.');
                    break;
                }
                Date Endate = (oldMapVb != null && oldMapVb.containsKey(vcb.id))?oldMapVb.get(vcb.id).EndDate__c:null;
                if(vcb.EndDate__c > Endate && vcb.TotalDays__c != null){
                    isCalculate = VehicleBookings_Helper.provideDiscount(newListVb,oldMapVb);
                }
            }
            
            for(VehicleBooking__c vb:newListVb){
                if(vb.StartDate__c < date.today()){
                    vb.addError('Start date cannot be in the past');
                    break;
                }
                if(vb.StartDate__c > vb.EndDate__c){
                    vb.addError('End date cannot be lessthen from start date');
                    break;
                }
                if(vb.Id != null){
                    VehicleBooking__c vbRe = oldMapVb.get(vb.Id);
                    if(vb.StartDate__c != vbRe.StartDate__c || vb.EndDate__c != vbRe.EndDate__c){
                        startDate = vb.StartDate__c;
                        endDate = vb.EndDate__c;
                        If(!mapListDate.containsKey(vb.Id)){
                            mapListDate.put(vb.Id,new List<Date>());
                        }
                        mapListDate.get(vb.Id).add(startDate);
                        mapListDate.get(vb.Id).add(endDate);
                    }
                }
            }
            if(isCalculate == false){
                VehicleBookings_Helper.calculateTotalDay(newListVb,mapListDate);
            }
            VehicleBookings_Helper.PreventOverlappingBookings(newListVb,oldMapVb);
        }
        if(trigger.isDelete){
            //system.debug('Deletenew>>>>'+newListVb);
            system.debug('Deleteold>>>>'+oldMapVb);
            for(Id vbsId:oldMapVb.keySet()){
                VehicleBooking__c recVBC =  oldMapVb.get(vbsId);
                if(recVBC.Status__c =='Confirmed'){
                    recVBC.addError('You cannot delete this record because the booking is Confirmed.');
                }
            }
        }
    }
    public static void updateCarObjStatu(List<VehicleBooking__c> newListVb){
        if(trigger.isUpdate){
            VehicleBookings_Helper.updateCarObjeStatus(newListVb);
        }
    }
}