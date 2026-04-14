// multiButtonCell.js
import { LightningElement, api } from 'lwc';

export default class MultiButtonCell extends LightningElement {
    @api recordId; // To identify the row the action belongs to

    handleActionA(event) {
        const recordId = event.target.dataset.id;
        const customEvent = new CustomEvent('actiona', {
            composed: true,
            bubbles: true,
            detail: { recordId }
        });
        this.dispatchEvent(customEvent);
    }

    handleActionB(event) {
        const recordId = event.target.dataset.id;
        const customEvent = new CustomEvent('actionb', {
            composed: true,
            bubbles: true,
            detail: { recordId }
        });
        this.dispatchEvent(customEvent);
    }
}