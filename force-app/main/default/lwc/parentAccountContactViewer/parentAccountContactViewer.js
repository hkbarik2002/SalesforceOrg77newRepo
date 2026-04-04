import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import getAllContct from '@salesforce/apex/ParentAccountContactViewerController.getAllContactRelatedToAccount';


export default class ParentAccountContactViewer extends LightningElement {
    @api recordId; // Automatically populated if on a Record Page
    @track allContact;
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD, INDUSTRY_FIELD] })
    account;
    get name() {
        return getFieldValue(this.account.data, NAME_FIELD);
    }

    get industry() {
        return getFieldValue(this.account.data, INDUSTRY_FIELD);
    }


    @wire(getAllContct, { accountId: '$recordId' })
    if(contacts) {
        this.allContact = contacts.data;
    }
    sendData() {
        const name = 'Hemanta';
        this.refs.childCmp.displayName(this.allContact);
        this.lestdataCreat();
    }
    newArryList = [];
    lestdataCreat() {
        // this.allContact.forEach(ac => {
        //     let err = {};
        //     err.id = ac.Id;
        //     err.name = ac.Name;
        //     err.email = ac.Email;
        //     this.newArryList.push(err);
        // });
        let list = this.allContact.map(ac => {
            return {
                id: ac.Id,
                name: ac.Name,
                email: ac.Email,
            }
        })
        this.newArryList.push(list);
        console.log('newArryList>>>', this.newArryList);
    }
}