import { LightningElement } from 'lwc';

export default class PromiseCreation extends LightningElement {
    v1 = '';
    // Create a promise
    generatePromise(message) {
        return new Promise((resolve, reject) => {
            if (!message) {
                this.v1 = 'message not found'; 
                reject('Message is empty');
            } else {
                setTimeout(() => {
                    console.log(message);
                    this.v1 = message; 
                    resolve('Promise resolved');
                }, 1000); 
            }
        });
    }

    
    async generatediffPromis() {
        try {
            await this.generatePromise('1st call');  
            await this.generatePromise('2nd call');  
            await this.generatePromise();            
        } catch (err) {
            console.log('Error caught:', err);      
        }
    }

    // Call it when component loads (or call from a button)
    connectedCallback() {
        this.generatediffPromis();
    }
    

    // Call that promise
    // connectedCallback() {
    //     this.generatePromise('1st call')
    //         .then(() => {
    //             console.log('1st promise resolved');
    //             generatePromise('2nd call'); 
    //         })
    //         .then(() => {
    //             console.log('2nd promise resolved');
    //             generatePromise(); 
    //         })
    //         .catch((err) => {
    //             console.log('promise Rejected', err); // ✅ will catch rejection here
    //         });
    // }
}