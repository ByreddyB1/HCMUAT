import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import communityBasePath from '@salesforce/community/basePath';
import getData from '@salesforce/apex/DocketAttachCustomController.getAllDocs';
import { NavigationMixin } from 'lightning/navigation';

export default class DocketAttachmentRelatedListCustom extends NavigationMixin(LightningElement) {
    @api recordId;
    @track allFiles = undefined;
    fileName;
    baseUrl;
    count;
    showPreview = false;
    fileExtension;
    downloadUrl;
    connectedCallback() {
        console.log('conn recordId==>' + this.recordId);
        //this.showSpinner=true;
        this.baseUrl = communityBasePath.slice(0, communityBasePath.length - 1);
        getData({ parentId: this.recordId })
            .then(result => {
                //this.showSpinner = false;
                this.count = result.length;
                if (result.length > 0) {
                    this.allFiles = result;
                    
                } else {
                    this.allFiles = undefined;
                }
            })
            .catch(error => {
                // this.showSpinner = false;
                console.log('---ERROR--- ', JSON.stringify(error));
            });
    }
    
    filePreview(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
              url: event.currentTarget.dataset.url
            }
           },false)
    }
    
}