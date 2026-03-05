import { LightningElement, track } from 'lwc';

export default class CalculatorParent extends LightningElement {

    @track result;

    handleFairEvent(event) {
        try {
            const { firstInput, secondInput, operation } = event.detail;

            const num1 = Number(firstInput);
            const num2 = Number(secondInput);

            if (operation === 'add') {
                this.result = num1 + num2;
            }
            else if (operation === 'subtract') {
                this.result = num1 - num2;
            }
            else if (operation === 'multiply') {
                this.result = num1 * num2;
            }
            else if (operation === 'divide') {
                this.result = num2 !== 0 ? (num1 / num2) : 'Cannot divide by zero';
            }
        } catch (error) {
            console.error('Error:', error.message);
        }
    }
    handleClickMethod() {
        this.template.querySelector('c-calculator-child').refresh({ detail: 'Hello Hemanta' });
        console.log('Hello Hemanta');
    }
}