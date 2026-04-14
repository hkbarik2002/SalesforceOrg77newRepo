import { LightningElement } from 'lwc';

export default class SearchComponentSetTime extends LightningElement {
    searchKey = '';
    delayTimeout;

    handleInputChange(event) {
        const userInput = event.target.value;

        // 1. Clear any existing timeout
        window.clearTimeout(this.delayTimeout);

        // 2. Set a new timeout
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.searchKey = userInput;
            this.handleSearch(); // Run your logic here (e.g., Apex call)
        }, 300);
        console.log('dailyTimeout>>>>', this.delayTimeout);
    }

    handleSearch() {
        console.log('Searching for:>>', this.searchKey);
        // Your logic goes here
    }
}