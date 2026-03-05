import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getpatientRecord from '@salesforce/apex/patientBillingController.getpatientRecord';
import getDoctorsRecord from '@salesforce/apex/patientBillingController.getAccountData';
import getpatientAppointment from '@salesforce/apex/patientBillingController.getpatientAppointment';
import getPatientTreatmentsAndBill from '@salesforce/apex/patientBillingController.getPatientTreatmentsAndBill';
import getTreatmentType from '@salesforce/apex/patientBillingController.getTreatmentType';
import creatNewTreatments from '@salesforce/apex/patientBillingController.creatNewTreatments';
import getPatienGender from '@salesforce/apex/patientBillingController.getPatienGender';
import insertNewPatient from '@salesforce/apex/patientBillingController.insertNewPatient';
import getAppointmentStatus from '@salesforce/apex/patientBillingController.getAppointmentStatus';
import insertNewAppointmentRecord from '@salesforce/apex/patientBillingController.insertNewAppointmentRecord';
import updateBillPay from '@salesforce/apex/patientBillingController.updateBillPay';
export default class PatientBilling extends LightningElement {

    appointMentColumns = [
        { label: 'Doctor Name', fieldName: 'Name' },
        { label: 'Status', fieldName: 'Status' },
        { label: 'Date', fieldName: 'Appointment_Date' },
        { label: 'Time', fieldName: 'Appointment_Time' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                    { label: 'Creat Treatment', name: 'creatTreatment' }
                ]
            }
        }
    ];
    treatmentColumns = [
        { label: 'Treatment Type', fieldName: 'Type__c' },
        { label: 'Cost', fieldName: 'Cost__c' },
    ];

    billingcolumns = [
        { label: 'Total Treatment Bill', fieldName: 'Total_Bill__c' },
        { label: 'Amount Paid', fieldName: 'Amount_Paid__c' },
        { label: 'Outstanding Balnces', fieldName: 'Outstanding_Balance__c' },
    ];

    patientOptions;
    @track patientValue;
    @track appointMentData;
    @track selectedAppointmentId;
    @track treatmentData;
    @track billingData;
    showTreatmentAndBillingData = false;
    showAppointmentData = false;
    treatmentType;
    @track selectedTreatmentType;
    @track EnteredtreatmentCost;
    showNewTreatment = false;
    @track showBillLabel;
    fullyPaid;
    @track outstandingBal;
    showPayBill = false;
    showToCreatPAtient = false;
    showToCreatAppointment = false
    genderData;
    patientConInfo;
    patientDob;
    patientGender;
    patientName;
    appStatusOption;
    aDoctorName;
    aDateTime;
    aStatus;
    stoPayAmount;
    isConnected = false;

    connectedCallback() {
        // this.isConnected = true;
        this.conGetpatientRecord();
    }

    // @wire(getpatientRecord)
    conGetpatientRecord() {
        getpatientRecord()
            .then(result => {
                // console.log('conn>>>>');
                this.patientOptions = result.map(d => ({
                    label: d.Name,
                    value: d.Id
                }));
                // console.log(' this.patientOptions>>>>', JSON.stringify(this.patientOptions));
            })
            .catch(error => this.handleError(error, 'getpatientRecord'));
    }

    @wire(getTreatmentType)
    wiredgetTreatmentType({ error, data }) {
        if (data) {
            //  console.log('wire1>>>>');
            //console.log('Data>>>>', data);
            this.treatmentType = data.map(d => ({ label: d, value: d }));
        }
        if (error) {
            console.error('Error>>>:', error);
        }
    }
    @wire(getDoctorsRecord)
    wiredgetDoctorsRecord({ error, data }) {
        if (data) {
            //  console.log('wire2>>>>');
            //console.log('Data>>>>', data);
            this.getdorData = data.map(d => ({ label: d.Name, value: d.Id }));
        }
        if (error) {
            console.error('Error>>>:', error);
        }
    }
    @wire(getPatienGender)
    wiregetPatienGender({ error, data }) {
        if (data) {
            // console.log('wire3>>>>');
            this.genderData = data.map(d => ({ label: d, value: d }));
        }
        if (error) {
            console.error('Error>>>:', error);
        }
    }
    @wire(getAppointmentStatus)
    wiregetAppointmentStatus({ error, data }) {
        if (data) {
            // console.log('wire4>>>>');
            this.appStatusOption = data.map(d => ({ label: d, value: d }));
        }
        if (error) {
            console.error('Error>>>:', error);
        }
    }

    handlePatientChange(event) {
        this.patientValue = event.detail.value;
        this.showTreatmentAndBillingData = false;
        this.callgetpatientAppointment();
        // console.log('Va>>>>', JSON.stringify(this.patientValue));
    }
    callgetpatientAppointment() {
        getpatientAppointment({ pId: this.patientValue })
            .then(data => {
                //console.log('dateTime>>>', JSON.stringify(data));
                this.appointMentData = data;
                this.showAppointmentData = true;
            }).catch(error => this.handleError(error, 'getpatientAppointment'));
    }
    handelRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        //console.log('row>>>', JSON.stringify(row));
        this.selectedAppointmentId = row.id;
        if (actionName === 'view') {
            //console.log('AID>>>', this.selectedAppointmentId);
            this.callgetPatientTreatmentsAndBill();
        }
        else if (actionName === 'creatTreatment') {
            this.showNewTreatment = true;
        }
    }
    callgetPatientTreatmentsAndBill() {
        getPatientTreatmentsAndBill({ appoId: this.selectedAppointmentId })
            .then(result => {
                // console.log('R>>>>>>', JSON.stringify(result));
                if (result[0].listOfTreatment.length === 0 && result[0].listOfBilling.length === 0
                ) {
                    this.showTreatmentAndBillingData = false;
                    this.showToast('Info', 'There is no treatment available', 'info');
                    return;
                }
                const treatmentrec = [];
                const billrec = [];
                result.forEach(res => {
                    treatmentrec.push(...res.listOfTreatment);
                    billrec.push(...res.listOfBilling);
                });
                const outstandingBalance = billrec[0].Outstanding_Balance__c;
                this.outstandingBal = outstandingBalance;
                if (outstandingBalance > 0) {
                    this.showBillLabel = 'Pay Bill';
                    this.fullyPaid = false;
                } else if (outstandingBalance === 0 || outstandingBalance == null) {
                    this.showBillLabel = 'Bill Paid';
                    this.fullyPaid = true;
                } else {
                    this.showBillLabel = 'No Bill Found';
                    this.fullyPaid = true;
                }
                this.treatmentData = treatmentrec;
                this.billingData = billrec;
                this.showTreatmentAndBillingData = true;

                //console.log('res>>>', JSON.stringify(this.treatmentData));
                //console.log('res000>>>', JSON.stringify(this.billingData));
            }).catch(error => this.handleError(error, 'getPatientTreatmentsAndBill'));

    }
    handleNewAppointment(event) {
        const field = event.target.name;
        if (field == 'aDostor') this.aDoctorName = event.target.value;
        if (field == 'aDate') this.aDateTime = event.target.value;
        if (field == 'aStatus') this.aStatus = event.target.value;
    }
    saveNewAppointment() {
        let newAppointmentData = {
            sobjectType: 'Appointment__c',
            Patient__c: this.patientValue,
            Date__c: this.aDateTime,
            Status__c: this.aStatus,
            Doctor_Name__c: this.aDoctorName
        }
        //console.log('newAppointmentData>>>>>', newAppointmentData);
        insertNewAppointmentRecord({ newAppointmentData })
            .then(result => {
                this.showToast('Success', 'Appointment created: ' + result, 'success');
                this.callgetpatientAppointment();
                newAppointmentData = {};
                this.aDoctorName = '';
                this.aDateTime = '';
                this.aStatus = '';
            }).catch(error => this.handleError(error, 'insertNewAppointmentRecord'));
    }

    handleNewPatient(event) {
        const field = event.target.name;
        if (field == 'tname') this.patientName = event.target.value;
        if (field == 'tGender') this.patientGender = event.target.value;
        if (field == 'tDob') this.patientDob = event.target.value;
        if (field == 'tContactInfo') this.patientConInfo = event.target.value;
    }
    saveNewPatient() {
        //console.log('newpatient>>>>', JSON.stringify(newpatient));
        let newpatient = {
            sobjectType: 'Patient__c',
            Name: this.patientName,
            DOB__c: this.patientDob,
            Gender__c: this.patientGender,
            Contact_Info__c: this.patientConInfo
        }
        //console.log('newpatient>>>>>', newpatient);
        insertNewPatient({ newpatient })
            .then(result => {
                //console.log('res>>>>', JSON.stringify(result));
                this.showToast('Success', 'Patient created: ' + result, 'success');
                this.conGetpatientRecord();
                this.patientValue = result;
                this.callgetpatientAppointment();
                newpatient = {};
                this.patientName = '';
                this.patientDob = '';
                this.patientGender = '';
                this.patientConInfo = '';
            })
            .catch(error => this.handleError(error, 'insertNewPatient'));
    }
    handleChangeForAddTreatmnet(event) {
        const field = event.target.name;
        if (field === 'tType') this.selectedTreatmentType = event.target.value;
        if (field === 'tCost') this.EnteredtreatmentCost = event.target.value;

    }
    handSaveTreatment() {
        //console.log('this.selectedTreatmentType>>>', this.EnteredtreatmentCost);
        if (!this.selectedTreatmentType || !this.EnteredtreatmentCost) {
            //console.log('>>>>>>>Ifff')
            this.showToast('Error', 'Please fill in all required fields before saving treatment.', 'error');
            return;
        }
        let newTreatment = {
            sobjectType: 'Treatment__c',
            Type__c: this.selectedTreatmentType,
            Cost__c: parseFloat(this.EnteredtreatmentCost),
            Appointment__c: this.selectedAppointmentId
        };
        creatNewTreatments({ newTreatment })
            .then(result => {
                this.showToast('Success', result, 'success');
                this.callgetPatientTreatmentsAndBill();
                newTreatment = {};
                this.selectedTreatmentType = '';
                this.EnteredtreatmentCost = 0;
                // console.log('newTreatment>>>', JSON.stringify(result));
            })
            .catch(error => this.handleError(error, 'creatNewTreatments'));
    }
    handlePayData(event) {
        const field = event.target.name;
        if (field === 'tPay') this.stoPayAmount = event.target.value;
    }
    handelbillpay() {
        if (!this.stoPayAmount) {
            this.showToast('Info', 'First enter Amount ', 'info');
            return;
        }
        updateBillPay({ appoId: this.selectedAppointmentId, bAmount: this.stoPayAmount })
            .then(result => {
                this.showToast('Success', result, 'success');
                this.stoPayAmount = '';
                this.callgetPatientTreatmentsAndBill();
            })
            .catch(error => this.handleError(error, 'updateBillPay'));

    }
    handNewTreatment() {
        this.showNewTreatment = true;
    }
    handleGenerateBill() {
        this.showPayBill = true;
    }
    handleAddPatient() {
        this.showToCreatPAtient = true;
    }
    closePopup() {
        this.showToCreatPAtient = false;
        this.showPayBill = false;
        this.showToCreatAppointment = false;
        this.showNewTreatment = false;
    }
    handNewAppointment() {
        this.showToCreatAppointment = true;
    }
    handleError(error, context) {
        console.error(`${context} error: `, error);
        this.showToast('Error', 'Something went wrong. Please try again.', 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    disconnectedCallback() {
        // this.isConnected = false;
        console.log('Component Disconnected>>');
    }
}