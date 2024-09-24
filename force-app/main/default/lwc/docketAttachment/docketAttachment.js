import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import uploadAttachment from '@salesforce/apex/DocketAttachmentController.uploadAttachment';
import fetchInitialData from '@salesforce/apex/DocketAttachmentController.fetchInitialDetails';
export default class DocketAttachment extends LightningElement {
    @api isGuestUser=false;
    @api recordId;
    @track uploadedFilesId;
    @track docketAttchMedaDataList;
    isVisibleToCommunityNo=false;
    defaultVisibleToCommValue;
    enableToUploadButton=true;
    enableToUploadButtonCon=true;
    isShowToNote=false;
    showSpinner=false;
    isNoteRequire=true;
    attachmentTypeValueCo ='';
    get options() {
        return [
            { label: '--None--', value: '' },
            { label: 'Authorized Representative Declaration (POA Form 151)', value: 'Authorized Representative Declaration (POA Form 151)' },
            { label: 'Taxpayer Supporting Documentation', value: 'Taxpayer Supporting Documentation' },
            { label: 'Withdrawal Request', value: 'Withdrawal Request' },
            { label: 'General Correspondence', value: 'General Correspondence' }
        ];
    }

    connectedCallback() {
        console.log('conn');
        this.showSpinner=true;
        fetchInitialData({  })
        .then(result => {
            this.showSpinner = false;
            this.docketAttchMedaDataList=result;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('---ERROR--- ', JSON.stringify(error));
        });
    }
    retrievedRecordId = false;
    renderedCallback() {
        if (!this.retrievedRecordId && this.recordId) {
            this.retrievedRecordId = true;
            console.log('recordId==>'+this.recordId);
        }
        if(!this.isGuestUser){
            this.onChangeVisibleToComm();
        }
        
    }

    onChangeNotesCom(event){
        if(this.isNoteRequire){
            if(event.target.value.trim()){
                this.enableToUploadButton=false;
            }else{
                this.enableToUploadButton=true;
            }
        }
        
    }

    handleChange(event) {
        if(event.detail.value){
            this.enableToUploadButton=true;
            if(event.detail.value == 'General Correspondence' || event.detail.value == 'Taxpayer Supporting Documentation'){
                this.isShowToNote = true;
                this.isNoteRequire = true;
            }else{
                this.isShowToNote = true;
                this.isNoteRequire=false;
                this.enableToUploadButton=false;
            }
            //this.enableToUploadButtonCon = false;
        }else{
            this.isNoteRequire = true;
            this.isShowToNote = false;
            this.enableToUploadButton=true;
        }
        this.attachmentTypeValueCo = event.detail.value;
    }

    onChangeAttachmentType(event){
        if(event.target.value){
            var isExistInMetaData = this.docketAttchMedaDataList.filter(item => item.Attachment_Type__c == event.target.value && item.Default_Type_to_No__c == true);
            if(isExistInMetaData.length > 0){
                this.isVisibleToCommunityNo=false;
                //this.enableToUploadButton=false;
            }else{
                this.isVisibleToCommunityNo=true;
                this.defaultVisibleToCommValue='';
                //this.enableToUploadButton=true;
            }
            this.isShowToNote=true;
           //c/googleAddressLookupLWC this.onChangeVisibleToComm();
        }else{
            this.isVisibleToCommunityNo=false;
            this.enableToUploadButton=true;
            this.isShowToNote=false;
        }
    }
    
    onChangeVisibleToComm(){
        let isValid = [...this.template.querySelectorAll('lightning-input-field')].reduce( (val, inp) => {
            let inpVal = true;
            // Custom Logic
            console.log('inp.fieldName-->'+inp.fieldName);
            switch (inp.fieldName) {
                case 'Visible_to_Community__c':
                    inpVal = inp.value ? true : false;
                    
                    break;
                case 'Contains_FTI__c':
                    inpVal = inp.value ? true : false;
                    
                    break;
                case 'Attachment_Type__c':
                    inpVal = inp.value ? true : false;
                        
                    break;
                default:
                    inpVal = true;
                    break;
            }
            return val && inpVal;
        }, true);
        console.log('sbc==>'+isValid);
        if(isValid){
            this.enableToUploadButton=false;
        }else{
            this.enableToUploadButton=true;
        }
    }
    

    handleUploadFinished(event) {
        // Get the list of uploaded files
         this.uploadedFilesId = event.detail.files[0].contentVersionId;
         const btn = this.template.querySelector( ".hidden" );
         if( btn ){ 
            btn.click();
         }
        //alert('No. of files uploaded : ' + uploadedFiles.length);
    }
    handleSuccess(event) {
        this.showSpinner=true;
        uploadAttachment({ docAttchId: event.detail.id,contentVersionId:this.uploadedFilesId })
        .then(result => {
            this.showSpinner=false;
            if(result=='Success'){
                this.showToast('Success', 'Docket Attachment uploaded.', 'success');
                this.closeQuickAction();
            }else{
                this.showToast('Error', 'Something went wrong', 'error');
            }
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('---ERROR--- ', JSON.stringify(error));
        });
    }

    handleSubmit(event) {
        event.preventDefault();
        this.showSpinner=true;
        const myfield = event.detail.fields;
        if(this.recordId){
            myfield.Docket__c =this.recordId;
        }
        if(this.isVisibleToCommunityNo==false){
            myfield.Visible_to_Community__c ='No';
        }
        if(this.isGuestUser){
            myfield.Visible_to_Community__c ='Yes';
            myfield.Contains_FTI__c ='No';
            myfield.FTI_Comments__c ='';
            myfield.Attachment_Type__c =this.attachmentTypeValueCo;
        }
        myfield.Attachment_Backup_Status__c ='Not Started';
        this.template.querySelector('lightning-record-edit-form').submit(myfield);
    } 


    closeQuickAction() {
        
        if(this.isGuestUser){
            this.dispatchEvent(new CustomEvent('close', { detail: {} }));
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
            eval("$A.get('e.force:refreshView').fire();");
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