import { LightningElement, api } from 'lwc';

export default class ChildShowHideComponent extends LightningElement {
    @api selectedOption;

    get showName() {
        return this.selectedOption === 'name';
    }

    get showPhone() {
        return this.selectedOption === 'phone';
    }

    get showEmail() {
        return this.selectedOption === 'email';
    }
}