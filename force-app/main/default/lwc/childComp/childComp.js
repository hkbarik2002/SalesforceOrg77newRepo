import { LightningElement, api } from 'lwc';

export default class ChildComp extends LightningElement {
    @api fsData;
    @api fsColumn;
    @api
    greet(name) {
        alert(`Hello, ${name} from Child Component!`);
    }
}