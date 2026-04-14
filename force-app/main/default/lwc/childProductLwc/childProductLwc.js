import { LightningElement, api, track } from 'lwc';

export default class ChildProductLwc extends LightningElement {
    @track totalPrice;
    @api unitPrice;
    @api productName;
    handleChange(event) {
        //console.log('event>>', event.detail.value);
        this.totalPrice = this.unitPrice * event.detail.value;
    }
}