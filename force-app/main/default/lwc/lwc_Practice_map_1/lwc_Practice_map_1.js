import { LightningElement, track, wire } from 'lwc';
// import getAccountContactsMap from '@salesforce/apex/Lwc_Practice_map_1_Controller.getAccountContactsMap';
//import getOpportunitiesByUser from '@salesforce/apex/Lwc_Practice_map_1_Controller.getOpportunitiesByUser';
import getAllContacts from '@salesforce/apex/Lwc_Practice_map_1_Controller.getAllContacts';
export default class Lwc_Practice_map_1 extends LightningElement {
    @track Result = [];
    Errors = '';

    @wire(getAllContacts)
    wiredContacts({data,error}){
        this.Errors = '';
        if(data){
            const groupeMap = new Map();
            data.forEach(con => {
                const AccId = con.AccountId;
                const AccName = con.Account.Name;

                if(!groupeMap.has(AccId)){
                    groupeMap.set(AccId,{
                        accountId:AccId,
                        accountName:AccName,
                        contacts:[]
                    });
                }
                groupeMap.get(AccId).contacts.push(con)
            });
            this.Result = Array.from(groupeMap.values());
            console.log('>>>>>>res >>>',JSON.stringify(this.Result));
        }else{
            this.Errors = error?.body?.message || error?.message || 'Unknown error occurred';
        }
    }
    // connectedCallback() {
    //     this.getDataFromApex();
    // }
    
    /*getDataFromApex() {
        this.Result = [];
        this.Errors = '';
        getAccountContactsMap()
            .then(data => {
                const restdata = [];
                console.log('>>>>data', JSON.stringify(data));
                for (let accId in data) {
                    const acoId = {
                        AccountId: accId,
                        Contacts: data[accId].map(c => ({
                            Id: c.Id,
                            Name: c.Name,
                            Email: c.Email
                        }))
                    };
                    restdata.push(acoId);
                }
                this.Result = restdata;
                console.log('>>>>Result', JSON.stringify(this.Result));
            })
            .catch(err => {
                this.Errors = err.body ? err.body.message : err.message;
            });
    }*/
    /*getDataFromApex() {
        this.Result = [];
        this.Errors = '';
        getOpportunitiesByUser()
            .then(data => {
                const StortemData = [];
                for (let OwId in data) {
                    const oId = {
                        OwnerID: OwId,
                        Opportunity: data[OwId].map(o => ({
                            Id: o.Id,
                            Name: o.Name,
                            Amount: o.Amount,
                            StageName: o.StageName
                        }))
                    };
                    StortemData.push(oId);
                }
                this.Result = StortemData;
                 console.log('>>>>Result', JSON.stringify(this.Result));
            }).catch(err => {
                this.Errors = err.body ? err.body.message : err.message;
            });
    }*/
}