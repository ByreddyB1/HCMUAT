import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getData from '@salesforce/apex/AccountContactNew.getData';
import deleteAccount from '@salesforce/apex/AccountContactNew.deleteAccount';
import checkAccForTaxId from '@salesforce/apex/AccountContactNew.checkAccForTaxId';

export default class AccountContactNew extends LightningElement {
    isShowConInfo = true;
    isShowConAdd = false;
    accId = '';
    isAccountTypeSelected = false;
    showForTaxpayers = false;
    isShowDivision = false;
    firstName = '';
    lastName = '';
    fTIValueAcc = '';
    street = '';
    streetCon = '';
    country = '';
    countryCon = '';
    stopRecur=true;
    province = '';
    provinceCon = '';
    postalCode = '';
    postalCodeCon = '';
    city = '';
    cityCon = '';
    existAccAsLabel='';
    existAccAsId='';
    showSpinner=false;
    @track accMetadataRecord;
    isShowConCreationOption=true;
    connectedCallback() {
        this.showSpinner=true;
        getData({ })
            .then(result => {
                this.showSpinner=false;
                console.log('inside success');
                this.accMetadataRecord = result;
            })
            .catch(error => {
                this.showSpinner=false;
                let errorMessage;
                if (error) {
                    if (Array.isArray(error.body)) {
                        errorMessage = error.body.map(e => e.message).join(", ");
                    } else if (typeof error.body.message === "string") {
                        errorMessage = error.body.message;
                    }
                }
                if (errorMessage) {
                    console.log(errorMessage);
                    this.showToast('Error', errorMessage, 'error');
                }
            });
    }
    closeModal() {
        this.dispatchEvent(new CustomEvent('close', { detail: {} }));
    }
    handleClickOnAccLink(event){
        this.dispatchEvent(new CustomEvent('successt',
            {
                detail: {
                    srId: this.existAccAsId,
                }
            }
        ));
    }
    handleSubmit(event) {
        event.preventDefault();
        this.showSpinner=true;
        const myfield = event.detail.fields;
        console.log('myfields==>' + JSON.stringify(myfield));
        myfield.BillingCity = this.city;
        myfield.BillingState = this.province;
        myfield.BillingStreet = this.street;
        myfield.BillingPostalCode = this.postalCode;
        myfield.BillingCountry = this.country;
        if(! this.showForTaxpayers){
            myfield.Contains_FTI__c='No';
            this.showSpinner=false;
            this.template.querySelector('lightning-record-edit-form').submit(myfield);
        }else{
            checkAccForTaxId({ taxId: myfield.Tax_ID__c })
            .then(result => {
                this.showSpinner=false;
                console.log('inside success checkAccForTaxId');
                console.log('result==>'+result);
                if(result=='Not Exist'){
                    this.template.querySelector('.taxIdClass').style.display = 'none';
                    this.template.querySelector('lightning-record-edit-form').submit(myfield);
                }else{
                    this.existAccAsId=result.substring(0, result.indexOf('-'));
                    this.existAccAsLabel=result.substring(result.indexOf('-') + 1);
                    this.template.querySelector('.taxIdClass').style.display = '';
                    this.showToast('Duplicate Tax Id', 'An Account already exists with this Tax ID. Please use the existing one instead of creating a duplicate.', 'Error');
                   
                }
            })
            .catch(error => {
                this.showSpinner=false;
                console.log('error while tax Id');
                let errorMessage;
                if (error) {
                    if (Array.isArray(error.body)) {
                        errorMessage = error.body.map(e => e.message).join(", ");
                    } else if (typeof error.body.message === "string") {
                        errorMessage = error.body.message;
                    }
                }
                if (errorMessage) {
                    console.log(errorMessage);
                    this.showToast('Error', errorMessage, 'error');
                }
            });
        }
        
        
    }
    handleSubmitCon(event) {
        event.preventDefault();
        const myfield = event.detail.fields;
        console.log('myfields==>' + JSON.stringify(myfield));
        if (!this.isShowConAdd) {
            myfield.MailingCity = this.city;
            myfield.MailingState = this.province;
            myfield.MailingStreet = this.street;
            myfield.MailingPostalCode = this.postalCode;
            myfield.MailingCountry = this.country;
        } else {
            myfield.MailingCity = this.cityCon;
            myfield.MailingState = this.provinceCon;
            myfield.MailingStreet = this.streetCon;
            myfield.MailingPostalCode = this.postalCodeCon;
            myfield.MailingCountry = this.countryCon;
        }
        if(! this.showForTaxpayers){
            myfield.Contains_FTI__c='No';
        }
        myfield.AccountId = this.accId;
        this.template.querySelector('.contact-record-form').submit(myfield);
    }
    handleSuccessCon(event) {
        console.log('in con success==>' + event.detail.id);

        this.showToast('Success', 'Record has been created', 'success');
        //this.showSpinner=false;
        this.dispatchEvent(new CustomEvent('successt',
            {
                detail: {
                    srId: event.detail.id,
                }
            }
        ));
    }
    handleSuccess(event) {
        if(this.stopRecur){
            console.log('in acc success==>' + event.detail.id);
            event.preventDefault();
            if (!this.isShowConInfo) {
                this.showToast('Success', 'Record has been created', 'success');
                //this.showSpinner=false;
                this.dispatchEvent(new CustomEvent('successt',
                    {
                        detail: {
                            srId: event.detail.id,
                        }
                    }
                ));
            } else {
                this.stopRecur=false;
                this.accId = event.detail.id;
                const btn = this.template.querySelector(".hidden");
                if (btn) {
                    btn.click();
                }
            }
        }
        
    }
    handleError(event) {
        console.log('errorMessage=ac=>' + event.detail.detail);
        this.showToast('Error while creating Account', event.detail.detail, 'error');
        this.stopRecur=true;
    }
    handleErrorCon(event) {
        console.log('errorMessage=con=>' + event.detail.detail);
        this.stopRecur=true;
        this.showSpinner=true;
        deleteAccount({ accId: this.accId })
            .then(result => {
                this.showSpinner=false;
                console.log('inside delete success ');
                this.showToast('Error while creating Contact', event.detail.detail, 'error');
            })
            .catch(error => {
                this.showSpinner=false;
                let errorMessage;
                console.log('error=1==>',error);
                console.log('error=2==>'+JSON.stringify(error));
                if (error) {
                    if (Array.isArray(error.body)) {
                        errorMessage = error.body.map(e => e.message).join(", ");
                    } else if (typeof error.body.message === "string") {
                        errorMessage = error.body.message;
                    }
                }
                if (errorMessage) {
                    console.log(errorMessage);
                    this.showToast('Error', errorMessage, 'error');
                }
            });
        
    }
    onAccountNameChange(event) {
        console.log('Acc name==>' + event.target.value);
        if (event.target.value && !this.isShowConCreationOption) {
            this.firstName = event.target.value.substring(0, event.target.value.indexOf(' ')); // "72"
            this.lastName = event.target.value.substring(event.target.value.indexOf(' ') + 1);
            console.log('this.firstName==>' + this.firstName);
            console.log('this.lastName==>' + this.lastName);
            //this.firstName=event.target.value;
        }

    }
    onTypeSelect(event) {
        console.log('yo');
        console.log('Value==>' + event.target.value);
        if (event.target.value) {
            this.isShowConInfo=true;
            let tempList = this.accMetadataRecord.filter(item => item.MasterLabel == event.target.value);
            if (tempList.length > 0) {
                this.isAccountTypeSelected = true;
                if (event.target.value == 'Individual Taxpayer' || event.target.value == 'Business Taxpayer') {
                    this.showForTaxpayers = true;
                    this.isShowDivision = false;
                } else {
                    if (event.target.value == 'Treasury Division') {
                        this.isShowDivision = true;
                    } else {
                        this.isShowDivision = false;
                    }
                    this.showForTaxpayers = false;
                }
            }
            if(event.target.value == 'Individual Taxpayer'){
                this.isShowConCreationOption=false;
                
            }else{
                this.isShowConCreationOption=true;
                this.firstName='';
                this.lastName='';
            }

        } else {
            this.isAccountTypeSelected = false;
            this.isShowConCreationOption=true;
        }
    }
    onContactInfoTaggleChange(event) {
        this.isShowConInfo = event.target.checked;
    }
    onContactAddTaggleChange(event) {
        this.isShowConAdd = event.target.checked;
    }
    onTaxtChange(event) {
        if (event.target.value && event.target.value.length > 10) {
            this.template.querySelector('.taxIdClass').style.display = '';
        } else {
            this.template.querySelector('.taxIdClass').style.display = 'none';
        }
    }
    onChangeFTI(event) {
        this.fTIValueAcc = event.target.value;
    }
    genericInputChange(event) {
        console.log('label => ', event.target.addressLabel);
        if (event.target.addressLabel == 'Account Address Information') {
            this.street = event.target.street;
            this.country = event.target.country;
            this.province = event.target.province;
            this.postalCode = event.target.postalCode;
            this.city = event.target.city;
        } else {
            this.streetCon = event.target.street;
            this.countryCon = event.target.country;
            this.provinceCon = event.target.province;
            this.postalCodeCon = event.target.postalCode;
            this.cityCon = event.target.city;
        }

    }
    showToast(toastTitle, toastMsg, toastVarient) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMsg,
            variant: toastVarient
        });
        this.dispatchEvent(event);
    }
}