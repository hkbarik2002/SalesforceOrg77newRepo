import { LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
export default class CDCwithAccountDatatable extends LightningElement {
    channelName = '/data/AccountChangeEvent'; // Subscribe to Account CDC
    subscription = {};
    wiredResult; // To store @wire response
    @track data = [];
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Industry', fieldName: 'Industry', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' }
    ];

    // Fetch data initially
    @wire(getAccounts)
    wiredAccounts(result) {
        this.wiredResult = result;
        if (result.data) {
            this.data = result.data;
        } else if (result.error) {
            console.error('Error fetching accounts', result.error);
        }
    }

    connectedCallback() {
        this.subscribeToCdc();
    }

    subscribeToCdc() {
        const messageCallback = (response) => {
            console.log('Account Change Event received: ', JSON.stringify(response));

            // Refresh datatable when event is received
            refreshApex(this.wiredResult);
        };

        subscribe(this.channelName, -1, messageCallback)
        .then((response) => {
            console.log('Subscribed to AccountChangeEvent channel');
            this.subscription = response;
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, (response) => {
            console.log('Unsubscribed from channel');
        });
    }
}