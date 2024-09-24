import { LightningElement } from 'lwc';

export default class CommunityFooterLwc extends LightningElement {
    currentYear;
    connectedCallback(){
       this.currentYear= new Date().getFullYear();
       console.log('this.currentYear==>'+this.currentYear);
    }
}