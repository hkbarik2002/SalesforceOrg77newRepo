import { LightningElement, api } from 'lwc';
export default class ChildAccountContactViewer extends LightningElement {
    @api contactsData;
    contactList
    @api
    displayName(conList) {
        this.contactList = conList;
    }
}