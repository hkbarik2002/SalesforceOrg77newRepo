import { LightningElement, track } from 'lwc';
import getWheatherDetail from '@salesforce/apex/WheatherDetailsClass.getWheatherDetail';
export default class WheatherDetails extends LightningElement {
    @track city;
    @track weather = [];
    @track errorMessage;
    @track isLoading = false;
    handleCityChange(event) {
        this.city = event.detail.value;

    }
    handleGetWeather() {
        if (!this.city) {
            this.errorMessage = 'Please enter a city name.';
            return;
        }
        this.isLoading = true;
        this.errorMessage = null;
        this.weather = null;
        getWheatherDetail({ cityName: this.city })
            .then(result => {
                if (result) {
                    console.log('pW>>> ', JSON.stringify(result));
                    this.weather = result;
                    console.log('W>>> ', JSON.stringify(this.weather));
                } else {
                    this.errorMessage = 'No weather data found for the entered city.';
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.errorMessage = 'Error fetching weather: ' + (error.body?.message || error.message);
                this.isLoading = false;
            });
    }
}