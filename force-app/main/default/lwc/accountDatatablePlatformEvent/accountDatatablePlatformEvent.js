import { LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class AccountDatatablePlatformEvent extends LightningElement {
    channelName = '/event/Account_Update_Event__e'; // Custom Platform Event channel
    subscription = {};
    wiredResult;
    @track data = [];
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Industry', fieldName: 'Industry', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' }
    ];

    // Initial load
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
        this.subscribeToPlatformEvent();
        this.registerErrorListener();
    }

    subscribeToPlatformEvent() {
        const messageCallback = (response) => {
            console.log('Platform Event received: ', JSON.stringify(response));
            // Refresh table whenever event arrives
            refreshApex(this.wiredResult);
        };

        subscribe(this.channelName, -1, messageCallback)
        .then((response) => {
            console.log('Subscribed to channel: ', response.channel);
            this.subscription = response;
        });
    }

    registerErrorListener() {
        onError(error => {
            console.error('Error in empApi: ', JSON.stringify(error));
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, (response) => {
            console.log('Unsubscribed from channel');
        });
    }
}