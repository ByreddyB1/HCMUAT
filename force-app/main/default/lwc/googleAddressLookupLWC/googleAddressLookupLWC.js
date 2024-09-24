import { LightningElement,track,api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class GoogleAddressLookupLWC extends LightningElement {
    @api street;
    @api country;
    @api province;
    @api postalCode;
    @api city;
    genericInputChange(event){
        console.log('Street => ' , event.target.street);
        console.log('City => ' , event.target.city);
        console.log('Province => ' , event.target.province);
        console.log('Country => ' , event.target.country);
        console.log('postal Code => ' , event.target.postalCode);
        this.street=event.target.street;
        this.country=event.target.country;
        this.province=event.target.province;
        this.postalCode=event.target.postalCode;
        this.city=event.target.city;
        ["street", "country", "province","postalCode","city"].forEach((prop) =>
            this.dispatchEvent(new FlowAttributeChangeEvent(prop, this[prop]))
            );
    }
}