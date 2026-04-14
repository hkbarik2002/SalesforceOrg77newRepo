public class Helper_EnrollmentObj {
    public static void checkSeatAvailability(List<Enrollment__c> newEnrol){
       // system.debug(newEnrol);
        set<Id> coId  = new set<Id>();
        for(Enrollment__c en:newEnrol){
            if(en.Course__c != null){
                coId.add(en.Course__c);
            }
        }
        Course__c co = [select id ,Name,Available_Seats__c from Course__c where id =:coId limit 1 ];
        for(Enrollment__c enr:newEnrol){
            if(co.Available_Seats__c == 0){
                enr.addError('Seats are not Available');
            }
        }
    }
    public static void updateCourseAvailability(List<Enrollment__c> listEnrol){
        map<Id,Integer> mapCountChanges = new map<Id,Integer>();
        for(Enrollment__c e:listEnrol){
            if(e.Course__c != null){
                Integer countChanges = mapCountChanges.containsKey(e.Course__c)? mapCountChanges.get(e.Course__c) : 0;
                
                if(trigger.isInsert || trigger.isUnDelete){
                    countChanges -= 1;
                }
                else if(trigger.isDelete){
                    countChanges += 1;
                }
                mapCountChanges.put(e.Course__c,countChanges);
            }
        }
        List<Course__c> ListCourse = new List<Course__c>();
        for(Id coIds :mapCountChanges.keySet()){
            system.debug(mapCountChanges.get(coIds));
           Course__c nc = new Course__c( 
               id = coIds , Available_Seats__c = mapCountChanges.get(coIds)+[select id ,Available_Seats__c from Course__c where id =:coIds limit 1 ].Available_Seats__c);
            ListCourse.add(nc);
        }
        if(!ListCourse.isEmpty()){
            update ListCourse;
        }
    }
}