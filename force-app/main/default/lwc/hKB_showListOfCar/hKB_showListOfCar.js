import { LightningElement, wire } from 'lwc';
import getAllCardata from '@salesforce/apex/AllCardata.getAllCardata';
export default class HKB_showListOfCar extends LightningElement {
    carcolumn = [
        { label: 'Name', fieldName: 'Name__c' },
        { label: 'Category', fieldName: 'Category__c' },
        { label: 'Daily Rent', fieldName: 'DailyRent__c' },
    ];

    listCar = [];

    @wire(getAllCardata)
    wiredCars({ error, data }) {
        if (data) {
            console.log('data>>>>', data);
            this.listCar = data;
        } else if (error) {
            console.log(error);
        }
    }

}