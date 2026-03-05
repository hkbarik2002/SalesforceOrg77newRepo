import { LightningElement, track } from 'lwc';
import getPolicyHolder from '@salesforce/apex/ClaimInsurancePortal_Controller.getPolicyHolder';
import creatNewPolicyHolder from '@salesforce/apex/ClaimInsurancePortal_Controller.creatNewPolicyHolder';
import searchInsurancePolicies from '@salesforce/apex/ClaimInsurancePortal_Controller.searchInsurancePolicies';
import fetchClaimData from '@salesforce/apex/ClaimInsurancePortal_Controller.fetchClaimData';
import getClaimStatus from '@salesforce/apex/ClaimInsurancePortal_Controller.getClaimStatus';
import creatNewClaimRecord from '@salesforce/apex/ClaimInsurancePortal_Controller.creatNewClaimRecord';
import getInpStatusField from '@salesforce/apex/ClaimInsurancePortal_Controller.getInpStatusField';
import getInpPoliTypeField from '@salesforce/apex/ClaimInsurancePortal_Controller.getInpPoliTypeField';
import insertNewInsuPolicy from '@salesforce/apex/ClaimInsurancePortal_Controller.insertNewInsuPolicy';
import GetAssAndClaPayout from '@salesforce/apex/ClaimInsurancePortal_Controller.GetAssAndClaPayout';
import getRecommendationField from '@salesforce/apex/ClaimInsurancePortal_Controller.getRecommendationField';
import udateAssesmentData from '@salesforce/apex/ClaimInsurancePortal_Controller.udateAssesmentData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import SobjectType from '@salesforce/schema/RecordType.SobjectType';

export default class ClaimInsurancePortal extends LightningElement {

    insurancePolicyColumn = [
        { label: 'Policy Type', fieldName: 'Policy_Type__c' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Valid From ', fieldName: 'ValidFrom__c' },
        { label: 'Valid To', fieldName: 'ValidTo__c' },
        { label: 'Coverage Amount', fieldName: 'Coverage_Amount__c' },
        { label: 'Remaining Amount', fieldName: 'RemainingCoverage__c' },
        {
            label: 'Actions',
            type: 'action',
            typeAttributes: { rowActions: { fieldName: 'actions' } },
            cellAttributes: { alignment: 'center' }
        }
    ];
    claimDataColumn = [
        { label: 'Claim Amount', fieldName: 'Claim_Amount__c' },
        { label: 'Claim Date', fieldName: 'ClaimDate__c' },
        { label: 'Status', fieldName: 'Status__c' },
        {
            label: 'Action',
            type: 'action',
            typeAttributes: { rowActions: { fieldName: 'actions' } },
            cellAttributes: { alignment: 'center' }
        }
    ];
    assessmentColumn = [
        { label: 'Varified Amount', fieldName: 'VerifiedAmount__c' },
        { label: 'Recommendation', fieldName: 'Recommendation__c' },
        {
            label: 'Action',
            type: 'action',
            typeAttributes: { rowActions: { fieldName: 'actions' } },
            cellAttributes: { alignment: 'center' }
        }
    ];
    payOutDataColumn = [
        { label: 'Payout Amount', fieldName: 'PayoutAmount__c' },
        { label: 'Payment Status', fieldName: 'Payment_Status__c' }
    ];

    policieHolders;
    stPolicyHolder;
    creatCpho = false;
    poHoName; //poHo -> Policy Holder Name
    poHoDate;
    poHoPhone;
    insurancePolicy = [];
    showInPoli = false;
    @track selectedIpRecordIds;
    @track claimedData;
    showClaimData = false;
    showClaimInpu = false;
    clAmount;
    clStatus;
    clData;
    showInpoInputForm = false;
    inpPoliType;
    inpCoAmount;
    inpStatus;
    inpFromDate;
    inpToDate;
    ipPolityOption;
    ipStatusOption;
    cStatusOption;
    inpRecordId;
    clRecordId;
    allpayOutData;
    allAssessmentDate;
    showAssAndPayData = false;
    showAssessPopup = false;
    recommeFieldData;
    recommenValue;
    AssessRecordId;


    connectedCallback() {
        this.callgetPolicyHolder();
    }

    callgetPolicyHolder() {
        getPolicyHolder()
            .then(data => {
                //console.log('thidata>>>', data);
                this.policieHolders = data.map(d => ({ label: d.Name, value: d.Id }));
                //console.log('this.policieHolders>>>', this.policieHolders);
            }).catch(error => this.handleError(error, 'getPolicyHolder'));
    }

    hanPolicyHolderChange(event) {
        this.stPolicyHolder = event.detail.value;
        this.showInPoli = false;
        this.showClaimData = false;
        this.showAssAndPayData = false;
        //console.log('this.stPolicyHolder>>>', this.stPolicyHolder);
    }
    handelCreNewPoHo(event) {
        const actionName = event.target.name;
        if (actionName == 'phName') this.poHoName = event.target.value;
        if (actionName == 'phDate') this.poHoDate = event.target.value;
        if (actionName == 'phPhone') this.poHoPhone = event.target.value;
    }
    handleSavePoHO() {
        let poho = {
            SobjectType: 'PolicyHolder__c',
            Name: this.poHoName,
            DOB__c: this.poHoDate,
            ContactPhone__c: this.poHoPhone
        }
        // console.log('poho>>>>', poho);
        creatNewPolicyHolder({ poho })
            .then(data => {
                this.callgetPolicyHolder();
                this.stPolicyHolder = data.Id;
                this.showToast('Success', 'New policy holder created Id : ' + data.Id, 'success');
            })
            .catch(error => this.handleError(error, 'creatNewPolicyHolder'));
    }
    handleSearchPolicy() {
        searchInsurancePolicies({ pohol: this.stPolicyHolder })
            .then(data => {
                // console.log('data>>>', data);
                this.showInPoli = true;
                this.insurancePolicy = data.map(d => {
                    d.actions = [
                        { iconName: 'utility:edit_form', title: 'Edit', name: 'edit' },
                        { iconName: 'utility:preview', title: 'View Claims', name: 'view' }];
                    return d;
                });
                // console.log('this.insurancePolicy>>>', JSON.stringify(this.insurancePolicy));
            })
            .catch(error => this.handleError(error, 'searchInsurancePolicies'));
    }
    handleIpRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedIpRecordIds = selectedRows[0].Id;
        this.callfetchClaimData();
    }
    callfetchClaimData() {
        fetchClaimData({ ipoId: this.selectedIpRecordIds })
            .then(data => {
                //console.log('data>>>>>>>>>>>>>>', data);
                this.claimedData = data.map(da => {
                    da.actions = [
                        { iconName: 'utility:edit', title: 'Edit', name: 'edit' },
                        { iconName: 'utility:preview', title: 'View Assessment And ClaimPayout', name: 'view' }
                    ];
                    return da;
                });
                this.showClaimData = true;
            })
            .catch(error => this.handleError(error, 'fetchClaimData'));
    }
    handleNewClaim() {
        this.clAmount = '';
        this.clStatus = '';
        this.clData = '';
        this.callgetClaimStatus();
        this.showClaimInpu = true;
    }
    callgetClaimStatus() {
        getClaimStatus()
            .then(data => {
                this.cStatusOption = data.map(d => ({ label: d, value: d }));
                // console.log('this.cStatusOption>>>', JSON.stringify(this.cStatusOption));
            }).catch(error => this.handleError(error, 'getClaimStatus'));
    }
    handelClaimInputFields(event) {
        const actionName = event.target.name;
        if (actionName == 'cAmount') this.clAmount = event.target.value;
        if (actionName == 'cStatus') this.clStatus = event.target.value;
        if (actionName == 'cDate') this.clData = event.target.value;
    }
    handleSaveClaim() {
        let newClaimData = {
            SobjectType: 'Claim__c',
            Insurance_Policy__c: this.selectedIpRecordIds,
            Policy_Holder__c: this.stPolicyHolder,
            Claim_Amount__c: this.clAmount,
            Status__c: this.clStatus,
            ClaimDate__c: this.clData
        };
        // console.log('newClaimData>>>>>>>', newClaimData, '>>>this.clRecordId>>>>', this.clRecordId);
        creatNewClaimRecord({ newClaimData, clRecId: this.clRecordId })
            .then(data => {
                if (this.clRecordId === data.Id) {
                    this.showToast('Success', 'Claim Updated Id : ' + data.Id, 'success');
                    this.handleSaveAssess();
                } else {
                    this.showToast('Success', 'New Claim created Id : ' + data.Id, 'success');
                }
                //this.selectedIpRecordIds = '';
                // this.stPolicyHolder = '';
                this.clAmount = '';
                this.clStatus = '';
                this.clData = '';
                this.callfetchClaimData();
            }).catch(error => this.handleError(error, 'getClaimStatus'));
    }
    handleNewInPo() {
        this.inpPoliType = '';
        this.inpCoAmount = '';
        this.inpStatus = '';
        this.inpFromDate = '';
        this.inpToDate = '';
        //this.showInpoInputForm = true;
        this.getInsurancePolicyPickListField();
        this.showInpoInputForm = true;
    }
    async getInsurancePolicyPickListField() {
        const getInpStatusData = await getInpStatusField();
        this.ipStatusOption = getInpStatusData.map(g => ({ label: g, value: g }));
        // console.log('this.ipStatusOption>>>', this.ipStatusOption);
        const getInpPoliTypeData = await getInpPoliTypeField();
        this.ipPolityOption = getInpPoliTypeData.map(t => ({ label: t, value: t }));
        // console.log('this.ipPolityOption>>>', this.ipPolityOption);
        //this.showInpoInputForm = true;
    }

    handelInsuPoliInputFields(event) {
        const fieldName = event.target.name;
        if (fieldName === 'ipPolicyType') this.inpPoliType = event.target.value;
        if (fieldName === 'ipCovAmount') this.inpCoAmount = event.target.value;
        if (fieldName === 'ipStatus') this.inpStatus = event.target.value;
        if (fieldName === 'cFromDate') this.inpFromDate = event.target.value;
        if (fieldName === 'ipToDate') this.inpToDate = event.target.value;
    }
    handleSaveInsuPo() {
        let newInsuPoliData = {
            SobjectType: 'InsurancePolicy__c',
            PolicyHolder__c: this.stPolicyHolder,
            Policy_Type__c: this.inpPoliType,
            Coverage_Amount__c: this.inpCoAmount,
            Status__c: this.inpStatus,
            ValidFrom__c: this.inpFromDate,
            ValidTo__c: this.inpToDate
        };
        //console.log('newInsuPoliData>>>>>>', newInsuPoliData, '>>>>this.inpRecordId>>>>', this.inpRecordId);
        insertNewInsuPolicy({ newInsuPoliData, inpoId: this.inpRecordId })
            .then(data => {
                if (data.Id === this.inpRecordId) {
                    this.showToast('Success', 'Insurance Poilcy Updated Id : ' + data.Id, 'success');
                } else {
                    this.showToast('Success', 'New Insurance Poilcy created Id : ' + data.Id, 'success');
                }
                // this.stPolicyHolder = '';
                this.inpPoliType = '';
                this.inpCoAmount = '';
                this.inpStatus = '';
                this.inpFromDate = '';
                this.inpToDate = '';
                this.handleSearchPolicy();
            })
    }
    handleClaimRowAction(event) {
        this.callgetClaimStatus();
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'edit') {
            this.clRecordId = row.Id;
            this.clAmount = row.Claim_Amount__c;
            this.clStatus = row.Status__c;
            this.clData = row.ClaimDate__c;
            // console.log('row1>>>>>>>>', JSON.stringify(row));
            this.showClaimInpu = true;
        }
        if (actionName === 'view') {
            this.clRecordId = row.Id
            this.callGetAssAndClaPayout();
            this.showAssAndPayData = true;
        }
    }
    callGetAssAndClaPayout() {
        GetAssAndClaPayout({ calimId: this.clRecordId })
            .then(data => {
                this.allAssessmentDate = data.listOfAssessment.map(la => {
                    //console.log('Recommendation__c>>>>>>>>', JSON.stringify(la.Recommendation__c));
                    if (la.Recommendation__c === 'Pending Review') {
                        la.actions = [
                            { iconName: 'utility:edit', title: 'Edit', name: 'edit' },
                        ];
                    } else la.actions = [];
                    return la;
                });

                this.allpayOutData = data.listOfPayout;
                //console.log('allAssessmentDate>>>>> ', JSON.stringify(this.allAssessmentDate));
                //console.log('allpayOutData>>>>> ', JSON.stringify(this.allpayOutData));
            })
            .catch(error => this.handleError(error, 'GetAssAndClaPayout'));
    }
    assessmentRowAction(event) {
        this.callgetRecommendationField();
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'edit') {
            this.AssessRecordId = row.Id;
            // console.log('row.Recommendation__c>>>>', row.Recommendation__c);
            this.recommenValue = row.Recommendation__c;
            this.showAssessPopup = true;
        }
    }
    callgetRecommendationField() {
        getRecommendationField()
            .then(data => {
                this.recommeFieldData = data.map(rd => ({ label: rd, value: rd }));
                //  console.log('this.recommeFieldData>>>>>', this.recommeFieldData);
            })
            .catch(error => this.handleError(error, 'getRecommendationField'));
    }
    handelRecommField(event) {
        this.recommenValue = event.target.value;
    }
    handleSaveAssess() {
        let assessUpdateData = {
            SobjectType: 'Claim_Assessment__c',
            Id: this.AssessRecordId,
            Recommendation__c: this.recommenValue
        };
        // console.log('assessUpdateData>>>>>', assessUpdateData);
        udateAssesmentData({ assessUpdateData })
            .then(data => {
                this.showToast('Success', 'Assesment Updated Id : ' + data.Id, 'success');
                this.recommenValue = '';
                this.callfetchClaimData();
                this.callGetAssAndClaPayout();
                this.handleSearchPolicy();
            })
            .catch(error => this.handleError(error, 'udateAssesmentData'));
    }

    handleInPoRowAction(event) {
        // const { action, recordId } = event.detail;

        this.getInsurancePolicyPickListField();
        const actionName = event.detail.action.name;
        // console.log('>>>>>>>>>>>>', actionName);
        const row = event.detail.row;
        if (actionName === 'edit') {
            this.inpRecordId = row.Id;
            // console.log('row2>>>>>>>>', JSON.stringify(row.Policy_Type__c));
            this.inpPoliType = row.Policy_Type__c;
            this.inpCoAmount = row.Coverage_Amount__c;
            // console.log('row2>>>>>>>>', JSON.stringify(row.Status__c));
            this.inpStatus = row.Status__c;
            this.inpFromDate = row.ValidFrom__c;
            this.inpToDate = row.ValidTo__c;

            this.showInpoInputForm = true;
        }
        if (actionName === 'view') {
            this.selectedIpRecordIds = row.Id;
            this.callfetchClaimData();
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    handleError(error, context) {
        console.error(`${context} error: `, error);
        this.showToast('Error', 'Something went wrong. Please try again.', 'error');
    }
    handleCpho() {
        this.creatCpho = true;
    }
    closePopUp() {
        this.creatCpho = false;
        this.showClaimInpu = false;
        this.showInpoInputForm = false;
        this.showAssessPopup = false;
    }
}