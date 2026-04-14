import { LightningElement, track } from 'lwc';

export default class DistanceCalculator extends LightningElement {

    @track lat1;
    @track lon1;
    distance;

    handleLat1Change(event) {
        this.lat1 = event.target.value;
        console.log('this.lat1>>>>>', this.lat1);
    }
    handleLon1Change(event) {
        this.lon1 = event.target.value;
        console.log('this.lon1>>>>>', this.lon1);
    }
    handleCalculate() {
        console.log('handleCalculate');
    }
}