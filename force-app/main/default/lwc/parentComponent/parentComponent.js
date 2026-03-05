import { LightningElement, track } from 'lwc';

export default class ParentComponent extends LightningElement {
    // @track messageForChild ='';
    // handelChange(event){
    //      this.messageForChild = event.target.value;
    // }

    receivedMessage = '';

    handleChildMessage(event) {
        this.receivedMessage = event.detail;
    }
    connectedCallback() {
        setTimeout(() => {
            const child = this.template.querySelector('c-child-component');
            if (child) {
                console.log('Child Component:', child);
                child.SetInputVeriable();
            }
        }, 0);

    }
}