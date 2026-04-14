public with sharing class Helper_InsuranceClameManagement {
    public static void creatClamePayoutRecord(List<Claim_Assessment__c> newAssessment) {
        List<Claim_Payout__c> listOfCLP = new List<Claim_Payout__c>();
        seT<Id> setClaimId = new Set<Id>();
        for(Claim_Assessment__c clas:newAssessment){
            setClaimId.add(clas.Claim__c);
        }
        List<Claim__c> claimList =  [select Id,Status__c,Insurance_Policy__c,Insurance_Policy__r.Coverage_Amount__c,Insurance_Policy__r.RemainingCoverage__c from Claim__c  where id =: setClaimId limit 1];
        Map<Id,Decimal> mapRemainAmount = new Map<Id,Decimal>();
        // [SELECT Insurance_Policy__c, Insurance_Policy__r.RemainingCoverage__c FROM Claim__c where id In:setClaimId limit 1]
        List<Claim__c> claimList2 = new List<Claim__c>();
        
        for(Claim_Assessment__c cla:newAssessment){
            if(cla.Recommendation__c != null && cla.Recommendation__c == 'Approved'){
                Claim_Payout__c  clp = new Claim_Payout__c (PayoutAmount__c = cla.VerifiedAmount__c,Claim__c = cla.Claim__c,PayoutDate__c = date.toDay(),Payment_Status__c = 'Paid');
                Claim__c claim = new Claim__c(Id = claimList[0].Id,Status__c = 'Approved');
                // system.debug('claimList[0].Insurance_Policy__r.RemainingCoverage__c>>>>>'+claimList[0].Insurance_Policy__r.RemainingCoverage__c);
                Decimal remainAmount = claimList[0].Insurance_Policy__r.RemainingCoverage__c != null || claimList[0].Insurance_Policy__r.RemainingCoverage__c > 0?claimList[0].Insurance_Policy__r.RemainingCoverage__c - cla.VerifiedAmount__c:0;
                // Decimal vfAmount = cla.VerifiedAmount__c!=null?cla.VerifiedAmount__c:0;
                // System.debug('remainAmount>>>>'+remainAmount);
                if(!mapRemainAmount.containsKey(claimList[0].Id)){
                    
                    if(remainAmount == 0 || remainAmount == null){
                        Decimal amount = claimList[0].Insurance_Policy__r.Coverage_Amount__c != null?claimList[0].Insurance_Policy__r.Coverage_Amount__c - cla.VerifiedAmount__c:0;
                        System.debug('amount>>>'+amount);
                        mapRemainAmount.put(claimList[0].Insurance_Policy__c,amount);
                        
                    }else{
                        mapRemainAmount.put(claimList[0].Insurance_Policy__c,remainAmount);
                    }
                }
                claimList2.add(claim);
                listOfCLP.add(clp);
            }
        }
        // system.debug('mapRemainAmount>>>>'+mapRemainAmount);
        List<InsurancePolicy__c> updateIp = new List<InsurancePolicy__c>();
        for (Claim__c cl : claimList) {
            Id policyId = cl.Insurance_Policy__c;
            Decimal pRemainAmount = mapRemainAmount.containsKey(policyId)?mapRemainAmount.get(policyId):0;
            InsurancePolicy__c Ip = new InsurancePolicy__c(Id = policyId,RemainingCoverage__c = pRemainAmount);
            updateIp.add(Ip);
        }
        // System.debug('updateIp>>>>>>'+updateIp);
        if(!updateIp.isEmpty()){
            update updateIp;
        }
        if(!listOfCLP.isEmpty()){
            insert listOfCLP;
        }
        if(!claimList2.isEmpty()){
            update claimList2;
        }
    }
    
    public static void creatAssessmentRecord(List<Claim__c> newlistOfClaim){
        set<Id> clId = new Set<Id>();
        // system.debug('newlistOfClaim>>'+newlistOfClaim);
        for(Claim__c clm:newlistOfClaim ){
            if(clm.Claim_Amount__c != null){
                clId.add(clm.Id);
            }else clm.addError('Please fill claim amount');
        }
        // list<Claim_Assessment__c> cla = [select Id,Recommendation__c from Claim_Assessment__c where Claim__c IN:clId AND Recommendation__c ='Pending Review'];
        
        Map<Id,list<Claim_Assessment__c>> mapOfAssessment  = new Map<Id,list<Claim_Assessment__c>>();
        
        for(Claim_Assessment__c cla:[select Id,Recommendation__c,Claim__c from Claim_Assessment__c where Claim__c IN:clId]){
            if(cla != null || !mapOfAssessment.containsKey(cla.Claim__c)){
                mapOfAssessment.put(cla.Claim__c,new List<Claim_Assessment__c>());
            }
            mapOfAssessment.get(cla.Claim__c).add(cla);
        }
        list<Claim_Assessment__c> updateClaimAss = new list<Claim_Assessment__c>();
        list<Claim_Assessment__c> insertClaimAss = new list<Claim_Assessment__c>();
        for(Claim__c claim:newlistOfClaim ){
            Claim_Assessment__c claimAss = new Claim_Assessment__c(Claim__c = claim.Id,PolicyHolder__c = claim.Policy_Holder__c,VerifiedAmount__c = claim.Claim_Amount__c,Recommendation__c ='Pending Review');
            insertClaimAss.add(claimAss);
            List<Claim_Assessment__c> classList = mapOfAssessment != null && mapOfAssessment.containsKey(claim.Id)?mapOfAssessment.get(claim.Id):null;
            if(classList != null){
                for(Claim_Assessment__c classe : classList){
                    classe.Recommendation__c = 'Reject';
                    updateClaimAss.add(classe);
                }
            }
            
        }
        if(!insertClaimAss.isEmpty()){
            insert insertClaimAss;
        }
        if(!updateClaimAss.isEmpty()){
            update updateClaimAss;
        }
    }
    public static void checkIpRemainingamont(List<Claim__c> newlistOfClaim){
        //system.debug('newlistOfClaim>>>>'+newlistOfClaim);
        Set<Id> insId = new Set<Id>();
        for(Claim__c cla:newlistOfClaim){
            insId.add(cla.Insurance_Policy__c);
        }
        list<InsurancePolicy__c> inspList = [SELECT Id,Coverage_Amount__c, RemainingCoverage__c,Policy_Type__c FROM InsurancePolicy__c  where Id =:insId limit 1];
        //system.debug('inspList>>>'+inspList);
        Decimal amount = inspList[0].RemainingCoverage__c == null  || inspList[0].RemainingCoverage__c == 0 ?inspList[0].Coverage_Amount__c:inspList[0].RemainingCoverage__c;
        Decimal vfAmount = newlistOfClaim!=null && newlistOfClaim[0].Claim_Amount__c != null?newlistOfClaim[0].Claim_Amount__c:0;
        
        for(Claim__c claim:newlistOfClaim){
            claim.Claim_Type__c = inspList[0].Policy_Type__c;
            if(amount <= vfAmount && amount == inspList[0].Coverage_Amount__c){
                claim.addError('Clame amount should be lessthen from coverage amount');
            }
            else if(amount <= vfAmount){
                claim.addError('Clame amount should be lessthen from remaining amount');
            }
        }
    }
    public static void calculateTotalInusurancePolicy(set<Id> pHoId){
        //system.debug('pHoId>>>'+pHoId);
        List<AggregateResult> agr =   [SELECT PolicyHolder__c poId,COUNT(Id) totalIp FROM InsurancePolicy__c  GROUP BY PolicyHolder__c  HAVING  PolicyHolder__c IN:pHoId ];
        List<PolicyHolder__c > listOfPolHo = new List<PolicyHolder__c>();
        for(AggregateResult ag :agr){
            Id poliHoId = (Id)ag.get('poId');
            Integer totalInpo = (Integer)ag.get('totalIp');
            // system.debug('poliHoId>>>'+poliHoId+'>>>totalInpo>>>'+totalInpo);
            PolicyHolder__c  ph = new PolicyHolder__c (Id=poliHoId,TotalPolicies__c = totalInpo);
            listOfPolHo.add(ph);
        }
        if(!listOfPolHo.isEmpty()){
            update listOfPolHo;
        }
    }
    public static void calculateTotalCoverageAmount(Set<ID> phoId){
        //system.debug('phoId>>>>>>>'+phoId);
        List<AggregateResult> agre = [Select PolicyHolder__c,SUM(Coverage_Amount__c) Total from InsurancePolicy__c where PolicyHolder__c IN:phoId GROUP BY PolicyHolder__c ];
        Map<Id,Decimal> mapTocovAmount = new Map<Id,Decimal>();
        for(AggregateResult ar:agre){
            Id poId =(Id)ar.get('PolicyHolder__c');
            Decimal tAmount = (Decimal)ar.get('Total');
            mapTocovAmount.put(poId, (mapTocovAmount.containsKey(poId) ? mapTocovAmount.get(poId) : 0) + tAmount);
        }
        List<PolicyHolder__c> listPo = new List<PolicyHolder__c>();
        for(Id pId:phoId){
            Decimal tAmount =mapTocovAmount.containsKey(pId)? mapTocovAmount.get(pId):null;
            PolicyHolder__c po = new PolicyHolder__c(Id=pId,Total_IpAmount__c = tAmount);
            listPo.add(po);
        }
        if(listPo != null){
            // system.debug('listPo>>>>>'+listPo);
            update listPo;
        }
    }
}