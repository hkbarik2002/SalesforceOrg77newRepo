import { LightningElement, api } from 'lwc';

export default class LeadCard extends LightningElement {
    @api lead;
    @api isHighlighted = false;
    // renderedCallback() {
    //     console.log('Lead Data received:', JSON.parse(JSON.stringify(this.lead)));
    // }
    get cardClass() {
        return this.isHighlighted ? 'slds-box slds-theme_success' : 'slds-box';
    }

    handleReassign() {
        // CHILD TO PARENT: Send the ID of the lead to be reassigned
        this.dispatchEvent(new CustomEvent('reassign', {
            detail: { leadId: this.lead.Ids },
            bubbles: true,
            composed: true
        }));
    }
    getdatas;
    @api callFunctionChild(getdata) {
        this.getdatas = getdata;
        // console.log('getdata>>>>', this.getdatas);
    }
}