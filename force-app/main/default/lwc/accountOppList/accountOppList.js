import { LightningElement, api, wire } from 'lwc';
import getRelatedOpps from '@salesforce/apex/AccountRelatedController.getRelatedOpps';

export default class AccountOppList extends LightningElement {
    oppColumn = [];
    opps;
    error;
    isLoading = true;

    // Use the record name from Step 1.5
    @wire(getRelatedOpps)
    wiredOpps({ error, data }) {
        if (data) {
            //console.log('data>>>', JSON.stringify(data));
            this.oppColumn = data.fields.map(f => {
                return {
                    label: f,
                    fieldName: f
                }
            });
            this.opps = data.oppList;
            if (this.oppColumn.length > 0 && this.opps.length > 0) {
                this.isLoading = true;
            } else this.isLoading = false;
        } else if (error) {
            this.error = error;
            this.isLoading = false;
        }
    }
}