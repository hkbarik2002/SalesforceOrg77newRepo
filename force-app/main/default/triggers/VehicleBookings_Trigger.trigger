trigger VehicleBookings_Trigger on VehicleBooking__c (before insert,before update,before delete,after update) {
    if(trigger.isBefore){
        VehicleBookings_Handler.calculateTotalDays(trigger.new,trigger.oldMap);
    }
    if(trigger.isAfter){
        VehicleBookings_Handler.updateCarObjStatu(trigger.new);
    }
}