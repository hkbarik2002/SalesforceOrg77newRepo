import { LightningElement, track, wire } from 'lwc';
import getTopCustomers from '@salesforce/apex/CustomerInsightsController.getTopCustomers';
import accountRelatedOppAndCon from '@salesforce/apex/CustomerInsightsController.accountRelatedOppAndCon';
export default class TopCustomerDashboard extends LightningElement {
    /*columns = [
        { label: 'Account Id', fieldName: 'accountId', type: 'text' },
        { label: 'Total Revenue', fieldName: 'totalRevenue', type: 'currency' },
        { label: 'Primary Contact Name', fieldName: 'contactName', type: 'text' },
        { label: 'Primary Contact Email', fieldName: 'contactEmail', type: 'email' }
    ];

    @track customerData = [];
    @track error;

    @wire(getTopCustomers)
    wiredData({ error, data }) {
        if (data) {
            console.log('Data>>>>>>',JSON.stringify(data));
            this.customerData = data;
        } else if (error) {
            this.error = error;
            console.error(error);
        }
    }*/

    @track contactColumns = [
        { label: 'Account Id', fieldName: 'AccountId', type: 'text' },
        { label: 'Contact Name', fieldName: 'Name', type: 'text' },
        { label: 'Email', fieldName: 'Email', type: 'email' }
    ];

    @track oppColumns = [
        { label: 'Account Id', fieldName: 'AccountId', type: 'text' },
        { label: 'Opportunity Name', fieldName: 'Name', type: 'text' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency' }
    ];

    @track contactData = [];
    @track opportunityData = [];
    @wire(accountRelatedOppAndCon)
    wireData({ erreo, data }) {
        if (data) {
            let contacts = [];
            let opportunitys = [];
            data.forEach(wrap => {
                if (wrap.contactList) {
                    wrap.contactList.forEach(con => {
                        contacts.push({
                            accountId: wrap.ids,
                            ...con
                        });
                    });
                }
                if (wrap.opportunityList) {
                    wrap.opportunityList.forEach(opp => {
                        opportunitys.push({
                            accountId: wrap.ids,
                            ...opp
                        });
                    });
                }
            });
            // console.log('contacts>>>', JSON.stringify(contacts));
            // console.log('opportunitys>>>', JSON.stringify(opportunitys));
            this.contactData = contacts;
            this.opportunityData = opportunitys;
        } else {
            console.error(erreo);
        }
    }

}