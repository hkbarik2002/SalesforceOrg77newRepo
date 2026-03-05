public class Handler_EnrollmentObj {
    public static void checkSeatsAvailability(List<Enrollment__c> newEnrol){
        if(trigger.isInsert){
            Helper_EnrollmentObj.checkSeatAvailability(newEnrol);
        }
    }
    public static void dMLOnEnrollmentObj(List<Enrollment__c> newEnrol,List<Enrollment__c> oldEnrol){
        if(trigger.isInsert){
            Helper_EnrollmentObj.updateCourseAvailability(newEnrol);
        }
        if(trigger.isDelete){
            Helper_EnrollmentObj.updateCourseAvailability(oldEnrol);
        }
        if(trigger.isUnDelete){
            Helper_EnrollmentObj.updateCourseAvailability(newEnrol);
        }
    }
}