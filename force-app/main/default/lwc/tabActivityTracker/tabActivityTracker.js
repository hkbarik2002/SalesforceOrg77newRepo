import { LightningElement,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class TabActivityTracker extends LightningElement {
    tabApiName = '';
    refreshedTime = '';

    // Wire to get current tab info
    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        //console.log('getPageRef');
        if (pageRef?.type === 'standard__navItemPage') {
            this.tabApiName = pageRef.attributes.apiName;
            this.refreshData('Initial load');
        }
    }

    connectedCallback() {
        // Add event listener to detect tab revisit
       // console.log('connectedCallback');
        document.addEventListener('visibilitychange', this.handleTabVisibility);
    }

    disconnectedCallback() {
        //console.log('disconnectedCallback');
        document.removeEventListener('visibilitychange', this.handleTabVisibility);
    }

    handleTabVisibility = () => {
       // console.log('handleTabVisibility');
        if (document.visibilityState === 'visible') {
            this.refreshData('Tab revisited');
        }
    };

    refreshData() {
        console.log(JSON.stringify(this.tabApiName));
        // Add your data fetching logic here (Apex call, @wire refresh, etc.)
    }
}