import { LightningElement } from 'lwc';
import { labels } from './label';

export default class CustomLabelDemo extends LightningElement {

    labelList = Object.values(labels);
    connectedCallback() {
        console.log('labels>>', labels);
    }
}