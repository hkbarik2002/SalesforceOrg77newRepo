import { LightningElement, wire, track } from 'lwc';
import getLeads from '@salesforce/apex/LeadTerratoryController.getLeads';

export default class TerritoryMaster extends LightningElement {
    @track allLeads = []; // Original data from server
    @track filteredLeads = []; // Data modified by search
    // searchTerm = '';

    @wire(getLeads)
    wiredLeads({ error, data }) {
        if (data) {
            this.allLeads = data;
            // console.log('data>>', JSON.stringify(this.allLeads));

            this.filteredLeads = data;
        }
    }

    handleSearchChange(event) {
        let searchTerm = event.target.value;
        if (searchTerm === '') {
            this.filteredLeads = this.allLeads;
            // console.log(' this.filteredLeads>>>>>>', this.filteredLeads);
            return;
        }
        this.filteredLeads = this.allLeads.map(lead => {
            return {
                ...lead,
                isMatch: lead.regionCode.includes(searchTerm)
            };
        });
    }

    handleChildReassign(event) {
        const leadId = event.detail.leadId;
    }
    handleClickSendData() {
        this.template.querySelector('c-lead-card').callFunctionChild({ detail: 'HelloHK' });
    }
}