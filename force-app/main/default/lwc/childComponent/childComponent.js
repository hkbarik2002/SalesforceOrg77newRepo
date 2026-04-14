import { LightningElement, api } from 'lwc';

export default class ChildComponent extends LightningElement {
    //  @api message; 
    handleClick() {
        const customEvent = new CustomEvent('messagefromchild', {
            detail: 'Hi Parent! I am your child.'
        });
        this.dispatchEvent(customEvent);
    }
    @api
    SetInputVeriable(value) {
        console.log('V>>>>>', value);
    }
}