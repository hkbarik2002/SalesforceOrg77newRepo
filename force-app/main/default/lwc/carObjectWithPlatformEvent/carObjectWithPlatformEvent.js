import { LightningElement, track } from 'lwc';
import creatCarRecord from '@salesforce/apex/carObjectWithPlatformEvent_Controller.creatCarRecord';
import getCars from '@salesforce/apex/carObjectWithPlatformEvent_Controller.getCars';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class CarObjectWithPlatformEvent extends LightningElement {

    // ------------------ DATATABLE COLUMNS ------------------
    carColumns = [
        { label: 'Name', fieldName: 'Name__c' },
        { label: 'Daily Rent', fieldName: 'DailyRent__c' },
        { label: 'Seating Capacity', fieldName: 'SeatingCapacity__c' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Category', fieldName: 'Category__c' }
    ];

    CategoryOptions = [
        { label: 'SUV', value: 'SUV' },
        { label: 'Sedan', value: 'Sedan' },
        { label: 'Hatchback', value: 'Hatchback' }
    ];

    // ------------------ FORM FIELDS ------------------
    showCarForm = false;

    @track Name__c;
    @track DailyRent__c;
    @track SeatingCapacity__c;
    @track Category__c;

    // ------------------ DATA ------------------
    carData = [];

    // ------------------ PLATFORM EVENT ------------------
    channelName = '/event/AfterInsertCar_Pv__e';
    subscription = null;
    isLoading = false;

    // ------------------ INFINITE LOADING ------------------
    rowLimit = 5;
    rowOffset = 0;
    enableInfiniteLoading = true;

    // ============================================================
    // LIFECYCLE
    // ============================================================

    connectedCallback() {
        this.loadCars();
        this.subscribeToEvent();
        this.registerErrorListener();
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription, () => {
                console.log('Unsubscribed successfully');
            });
        }
    }

    // ============================================================
    // LOAD DATA (WITH INFINITE LOADING SUPPORT)
    // ============================================================

    loadCars() {
        return getCars({
            limitSize: this.rowLimit,
            offsetSize: this.rowOffset
        })
            .then(result => {

                if (result.length > 0) {

                    if (this.rowOffset === 0) {
                        // 🔥 VERY IMPORTANT → new reference
                        this.carData = [...result];
                    } else {
                        this.carData = [...this.carData, ...result];
                    }

                    this.rowOffset += this.rowLimit;

                    if (result.length < this.rowLimit) {
                        this.enableInfiniteLoading = false;
                    }

                } else {
                    this.enableInfiniteLoading = false;
                }

            })
            .catch(error => {
                console.error('Load error:', error);
            });
    }

    handleLoadMore() {
        if (this.enableInfiniteLoading) {

            this.isLoading = true;

            this.loadCars().then(() => {
                this.isLoading = false;
            });
        }
    }


    // ============================================================
    // FORM HANDLING
    // ============================================================

    handleChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleNew() {
        this.showCarForm = true;
    }

    handleCancel() {
        this.showCarForm = false;
    }

    handleSave() {

        let record = {
            SobjectType: 'Car__c',
            Name__c: this.Name__c,
            Category__c: this.Category__c,
            DailyRent__c: this.DailyRent__c,
            SeatingCapacity__c: this.SeatingCapacity__c
        };

        this.createCar(record);

        this.resetForm();
        this.showCarForm = false;
    }

    handleSaveAndNew() {

        let record = {
            SobjectType: 'Car__c',
            Name__c: this.Name__c,
            Category__c: this.Category__c,
            DailyRent__c: this.DailyRent__c,
            SeatingCapacity__c: this.SeatingCapacity__c
        };

        this.createCar(record);
        this.resetForm();
    }

    resetForm() {
        this.Name__c = '';
        this.DailyRent__c = '';
        this.SeatingCapacity__c = '';
        this.Category__c = '';
    }

    createCar(newCar) {
        creatCarRecord({ carRec: newCar })
            .then(result => {
                this.showToast(result);
            })
            .catch(error => {
                this.showToast(error.body?.message || 'Error occurred', 'error');
            });
    }

    showToast(message, variant = 'success') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant === 'success' ? 'Success' : 'Error',
                message: message,
                variant: variant
            })
        );
    }

    // ============================================================
    // PLATFORM EVENT SUBSCRIPTION
    // ============================================================

    subscribeToEvent() {

        const messageCallback = (response) => {
            // console.log('Platform Event received:', JSON.stringify(response));

            // 🔥 COMPLETE RESET
            this.rowOffset = 0;
            this.enableInfiniteLoading = true;
            this.carData = [];

            // 🔥 RELOAD DATA
            this.loadCars();
        };

        subscribe(this.channelName, -1, messageCallback)
            .then(response => {
                this.subscription = response;
                //console.log('Subscribed to:', response.channel);
            });
    }

    registerErrorListener() {
        onError(error => {
            console.error('EMP API error:', JSON.stringify(error));
        });
    }
}