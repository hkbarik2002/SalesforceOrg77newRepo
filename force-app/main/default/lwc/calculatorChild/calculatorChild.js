import { LightningElement, track, api } from 'lwc';

export default class CalculatorChild extends LightningElement {

    @track firstInput;
    @track secondInput;

    handleFirstNumberChange(event) {
        this.firstInput = event.target.value;
    }

    handleSecondNumberChange(event) {
        this.secondInput = event.target.value;
    }

    handleFairEvent(event) {
        const fairEvent = new CustomEvent('fair', {
            detail: {
                firstInput: this.firstInput,
                secondInput: this.secondInput,
                operation: event.target.name
            }
        });

        this.dispatchEvent(fairEvent);
    }
    @track firstInput;
    @api refresh(event) {
        console.log('>>>', JSON.stringify(event));
        this.firstInput = event.detail;
        console.log('>>>', this.firstInput);
    }
}