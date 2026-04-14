import { LightningElement, track } from 'lwc';

export default class ParentComp extends LightningElement {
    @track inputValue;  // optional in modern LWC, but not harmful

    handleChange(event) {
        this.inputValue = event.target.value;
    }

    callChildMethod() {
        const child = this.template.querySelector('c-child-comp');
        if (child) {
            child.greet(this.inputValue);
        }
    }
}