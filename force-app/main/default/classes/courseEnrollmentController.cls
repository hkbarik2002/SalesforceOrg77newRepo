public class courseEnrollmentController {
    @AuraEnabled(cacheable = true)
    public static List<Course__c> getCourse(){
        return [Select Id,name From Course__c ];
    }
    @AuraEnabled
    public static wrappercourseEnrollment getCourseRelatedData(ID courseId){
        //system.debug('cc>>> '+courseId);
        wrappercourseEnrollment wce = new wrappercourseEnrollment();
        for(Course__c cs :[Select name,Instructor__r.Name,Available_Seats__c From Course__c Where Id =:courseId limit 1]){ 
            wce.Name = cs.Name;
            wce.Instructor=cs.Instructor__r.Name;
            wce.Available_Seats = cs.Available_Seats__c; 
        }
        system.debug(wce);
        return wce;
    }
    
    @AuraEnabled
    public static List<wrappercourseEnrollment2> getEnrollmentRelatedData(Id courseId){
        List<wrappercourseEnrollment2> listWce = new List<wrappercourseEnrollment2>(); 
        for(Enrollment__c en : [SELECT Id, Student__r.Name,Course__r.name,CreatedDate,Status__c FROM Enrollment__c WHERE Course__c  =:courseId AND Status__c ='Requested']){
            wrappercourseEnrollment2 we = new wrappercourseEnrollment2();
            we.Ids = en.Id;
            we.Name = en.Course__r.name;
            we.student_Name = en.Student__r.Name;
            we.Created_Date = en.CreatedDate;
            we.Status = en.Status__c;
            listWce.add(we);
        } 
        if(!listWce.isEmpty()){
            system.debug(listWce);
            return listWce;
        }else return listWce;
    }
    
    @AuraEnabled
    public static string creatEnrolmentRecord(Id sId,Id cId,String status){
        system.debug(sId+'----'+cId+'----'+status);
        Enrollment__c enr = new Enrollment__c(Student__c = sid,Course__c = cid,Status__c = status);
        if(enr != null){
            system.debug(enr);
            insert enr;
            return 'Sucess';
        }else return 'Creation fail';
    }
    
    @AuraEnabled
    public static string updateToApprove(Id enoId){
        Enrollment__c en = [ SELECT Id, Status__c FROM Enrollment__c WHERE Id =:enoId ];
        en.Status__c = 'Approved';
        update en;
        return 'Enrollment Approved sucessfully';
    }
    @AuraEnabled
    public static string updateToReject(Id enoId){
        Enrollment__c en = [ SELECT Id, Status__c FROM Enrollment__c WHERE Id =:enoId ];
        en.Status__c = 'Rejected';
        update en;
        return 'Enrollment Rejected sucessfully';
    }
    
    @AuraEnabled
    public static List<Contact> getStudentData(){
        return [select Id,Name From Contact];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<String> getListStatus(){
        List<String> myPicklist = new List<String>();
        Schema.DescribeFieldResult field = Enrollment__c.Status__c.getDescribe();
        for (Schema.PicklistEntry f : field.getPicklistValues()){
            myPicklist.add(f.getLabel());
        }
        if(!myPicklist.isEmpty()){
            return myPicklist;
        }else return myPicklist;
    }
    @AuraEnabled
    public static Contact insertContact(Contact con){
        system.debug('con>> '+con);
        // Contact con = new Contact(FirstName = fName,LastName = lName,Phone  = cPhone);
        if(con !=  null){
            insert con;
            return con;
        }else return con;
        
    }
    @AuraEnabled(cacheable = true)
    public static Map<String, List<wrappercourseEnrollment3>> courseRelatedEnrolment(string courseEn){
        // List<Enrollment__c> = [SELECT id,Student__r.Name,Status__c FROM Enrollment__c  where Course__r.Name =: courseEn];
        string searchCource = '%' + courseEn + '%';
        Map<String, List<wrappercourseEnrollment3>> mapEnrolment = new Map<String, List<wrappercourseEnrollment3>>();
       // List<wrappercourseEnrollment3> listEnrolment = new List<wrappercourseEnrollment3>();
        for(Enrollment__c enData:[SELECT id,Student__r.Name,Status__c FROM Enrollment__c  where Course__r.Name LIKE :searchCource]){
            wrappercourseEnrollment3 wce = new wrappercourseEnrollment3();
            wce.Ids = enData.Id;
            wce.Name = enData.Student__r.Name;
            wce.Status = enData.Status__c;
            if(!mapEnrolment.containsKey(courseEn)){
                mapEnrolment.put(courseEn,new list<wrappercourseEnrollment3>());
            }
            mapEnrolment.get(courseEn).add(wce);
        }
        if(!mapEnrolment.isEmpty()){
            system.debug(mapEnrolment);
            return mapEnrolment;
        }else return mapEnrolment;
    }
    
    public class wrappercourseEnrollment3{
        @AuraEnabled public Id Ids{get;set;}
        @AuraEnabled public string Name{get;set;}
        @AuraEnabled public string Status{get;set;}
    }
    
    public class wrappercourseEnrollment{
        @AuraEnabled public string Name{get;set;}
        @AuraEnabled public string Instructor{get;set;}
        @AuraEnabled public Decimal Available_Seats{get;set;}
        
    }
    public class wrappercourseEnrollment2{
        @AuraEnabled public Id Ids{get;set;}
        @AuraEnabled public string Name{get;set;}
        @AuraEnabled public string student_Name{get;set;}
        @AuraEnabled public Datetime Created_Date{get;set;}
        @AuraEnabled public string Status{get;set;}
        
    }
}