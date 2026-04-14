import { api, LightningElement } from 'lwc';

export default class ChildItemContainer extends LightningElement {

    @api item;
    increment() {
        const incrementEvent = new CustomEvent('increments', {
            detail: this.item.id

        });
        this.dispatchEvent(incrementEvent);
    }
}