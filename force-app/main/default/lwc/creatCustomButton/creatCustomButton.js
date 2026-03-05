import { LightningElement, api, track } from 'lwc';

export default class CreatCustomButton extends LightningElement {
    @api recordId;
    @track buttonName;

    handleClick(event) {
        this.buttonName = event.target.name;
        let paramData = { recordId: this.recordId, buttonName: this.buttonName };
        console.log(paramData);
        const ev = new CustomEvent('buttonmethod', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: paramData,
        });
        this.dispatchEvent(ev);
    }
}