import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createDocketRequestAndAttachment from '@salesforce/apex/NewHearingRequestController.createDocketRequestAndAttachment';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import DOCKET_REQUEST from '@salesforce/schema/Docket_Request__c';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserAccId from '@salesforce/schema/User.AccountId';
import UserConId from '@salesforce/schema/User.ContactId';

export default class NewHearingRequest extends NavigationMixin(LightningElement) {
    selectedRequestType = '';
    styleComp = 'width: 30%; height: calc(100vh - 435px);';
    showSpinner = false;
    isShowIntentSecondaryRefundSection = false;
    isShowLicenseDenialSection = false;
    isShowSeizureSection = false;
    isShowRequestTypeSection = false;
    taxName = '';
    @track docketRequestData = {};
    @track requestData = [];
    isShowSubtype = false;
    selectedRequestSubType = '';
    isShowIntentNumber = false;
    isFirstTime = false;
    attachmentTypeValue = '';
    isSingleRequest = false;
    isModalOpen = false;
    isShowToNote = false;
    enableToUploadButton = true;
    isNoteRequire = true;
    idToBeUplodated;
    contentVersionIdList = [];
    taxpayerNotesValue = '';
    isCheckedBehalfTaxpayer=false;
    @wire(getObjectInfo, { objectApiName: DOCKET_REQUEST })
    objectInfo;
    currentUserAccountId;
    currentUserContactId;

    @wire(getRecord, { recordId: Id, fields: [UserAccId, UserConId]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserAccountId = data.fields.AccountId.value;
            this.currentUserContactId = data.fields.ContactId.value;
        } else if (error) {
            console.log('Error while getting current user AccountId and ContactId==>'+error);
        }
    }
    get docketRequestRecordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        if (this.selectedRequestType == 'Intent to Assess/Refund Denial or Adjustment') {
            if (this.selectedRequestSubType) {
                return Object.keys(rtis).find(rti => rtis[rti].name === this.selectedRequestSubType);
            }
        } else {
            return Object.keys(rtis).find(rti => rtis[rti].name === this.selectedRequestType);
        }
    }
    get requestSubTypeoptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Intent to Assess', value: 'Intent to Assess' },
            { label: 'Refund Denial or Adjustment', value: 'Refund Denial or Adjustment' }
        ];
    }
    get requestTypeoptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Intent to Assess', value: 'Intent to Assess' },
            { label: 'Secondary Assessment', value: 'Secondary Assessment' },
            { label: 'Refund Denial or Adjustment', value: 'Refund Denial or Adjustment' },
            { label: 'License Denial', value: 'License Denial' },
            { label: 'Seizure', value: 'Seizure' },
            { label: 'Intent to Assess/Refund Denial or Adjustment', value: 'Intent to Assess/Refund Denial or Adjustment' },
        ];
    }
    get attachmentTypeOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Authorized Representative Declaration (POA Form 151)', value: 'Authorized Representative Declaration (POA Form 151)' },
            { label: 'Supporting Documentation', value: 'Supporting Documentation' },

        ];
    }
    onChangeCheckbox(event){
        this.isCheckedBehalfTaxpayer = event.detail.checked;
    }
    handleChangeRequestSubType(event) {
        var dataId = event.currentTarget.getAttribute("data-id");
        var filteredDableData = this.requestData.filter(item => item.id == dataId);
        filteredDableData.forEach(element => {
            element.subType = event.detail.value;
            if (event.detail.value != 'Intent to Assess') {
                element.intentNumber = '';
                element.isShowIntentNumber = false;
            } else {
                element.isShowIntentNumber = true;
            }
            element.taxType = '';
        });
        this.selectedRequestSubType = event.detail.value;
    }
    handleChangeRequestType(event) {
        this.docketRequestData = {};
        this.showSpinner = true;
        this.requestData = [];
        this.isShowSubtype = false;
        //this.isShowIntentNumber = false;
        this.selectedRequestSubType = '';
        this.isShowRequestTypeSection = false;
        this.selectedRequestType = event.detail.value;
        if (event.detail.value) {
            this.isFirstTime = true;
            this.styleComp = 'width: 30%;';
            if (event.detail.value == 'Intent to Assess/Refund Denial or Adjustment' || event.detail.value == 'Intent to Assess' || event.detail.value == 'Secondary Assessment' || event.detail.value == 'Refund Denial or Adjustment') {
                this.isShowRequestTypeSection = true;
                this.isShowIntentSecondaryRefundSection = true;
                this.addRow();
                if (event.detail.value == 'Intent to Assess/Refund Denial or Adjustment') {
                    this.isShowSubtype = true;
                }
            } else {
                this.requestData = [];
                this.isShowRequestTypeSection = false;
                this.isShowIntentSecondaryRefundSection = false;
            }
            if (event.detail.value == 'License Denial') {
                this.isShowLicenseDenialSection = true;
            } else {
                this.isShowLicenseDenialSection = false;
            }
            if (event.detail.value == 'Seizure') {
                this.isShowSeizureSection = true;
            } else {
                this.isShowSeizureSection = false;
            }
        } else {
            this.styleComp = 'width: 30%; height: calc(100vh - 435px);';
            this.isShowIntentSecondaryRefundSection = false;
            this.isShowLicenseDenialSection = false;
            this.isShowSeizureSection = false;
        }

        this.showSpinner = false;
    }
    onDocketRequestFieldsChange(event) {
        var fieldName = event.currentTarget.getAttribute("data-field");
        if (fieldName == 'Date_of_Notice__c') {
            //console.log('event.detail.value==>'+event.detail.value);
            this.docketRequestData.dateOfNotice = event.detail.value;
        } else if (fieldName == 'Complaint_Number__c') {
            this.docketRequestData.complaintNumber = event.detail.value;
        } else if (fieldName == 'Owner_Believed_to_Be__c') {
            this.docketRequestData.believedToBe = event.detail.value;
        } else if (fieldName == 'Location_Where_Seized__c') {
            this.docketRequestData.seizedLocation = event.detail.value;
        }
    }
    onDocketRequestsFieldsChange(event) {
        var fieldName = event.currentTarget.getAttribute("data-field");
        var dataId = event.currentTarget.getAttribute("data-id");
        var filteredDableData = this.requestData.filter(item => item.id == dataId);
        if (fieldName == 'Date_of_Notice__c') {
            filteredDableData.forEach(element => {
                element.dateOfNotice = event.detail.value;

            });
        } else if (fieldName == 'Intent_Number__c') {
            filteredDableData.forEach(element => {
                element.intentNumber = event.detail.value;

            });
        } else if (fieldName == 'Tax_Period_End_Date__c') {
            filteredDableData.forEach(element => {
                element.taxEndDate = event.detail.value;

            });
        } else if (fieldName == 'Tax_Type__c') {
            filteredDableData.forEach(element => {
                element.taxType = event.detail.value;

            });
        }

    }
    addRow() {
        let isValid = [...this.template.querySelectorAll('lightning-input-field')].reduce((val, inp) => {
            let inpVal = true;
            switch (inp.fieldName) {
                case 'Date_of_Notice__c':
                    inpVal = inp.value ? true : false;

                    break;
                case 'Intent_Number__c':
                    inpVal = inp.value ? true : false;

                    break;
                case 'Tax_Period_End_Date__c':
                    inp = inp.value ? true : false;

                    break;
                case 'Tax_Type__c':
                    inpVal = inp.value ? true : false;

                    break;
                default:
                    inpVal = true;
                    break;
            }
            return val && inpVal;
        }, true)

        if (isValid || this.isFirstTime) {
            if (this.requestData.length > 0 && this.selectedRequestType == 'Intent to Assess/Refund Denial or Adjustment') {
                var filteredDableData = this.requestData.filter(item => item.subType == '');
                if (filteredDableData.length > 0) {
                    this.showToast('Error', 'Please fill all required details in existing request information section', 'error');
                    return;
                }
            }
            var oldRow = [...this.requestData];
            let newRowObject;
            if (this.selectedRequestType == 'Intent to Assess' || this.selectedRequestType == 'Secondary Assessment') {
                newRowObject = { 'id': oldRow.length + 1, 'isLast': true, 'isShowIntentNumber': true, 'subType': '', 'dateOfNotice': '', 'intentNumber': '', 'taxEndDate': '', 'taxType': '' };
            } else {
                newRowObject = { 'id': oldRow.length + 1, 'isLast': true, 'isShowIntentNumber': false, 'subType': '', 'dateOfNotice': '', 'intentNumber': '', 'taxEndDate': '', 'taxType': '' };
            }
            if (oldRow.length > 0) {
                oldRow.forEach(element => {
                    element.isLast = false;
                });
            } else {
                if (this.selectedRequestType == 'Intent to Assess' || this.selectedRequestType == 'Secondary Assessment') {
                    newRowObject = { 'id': oldRow.length + 1, 'isLast': false, 'isShowIntentNumber': true, 'subType': '', 'dateOfNotice': '', 'intentNumber': '', 'taxEndDate': '', 'taxType': '' };
                } else {
                    newRowObject = { 'id': oldRow.length + 1, 'isLast': false, 'isShowIntentNumber': false, 'subType': '', 'dateOfNotice': '', 'intentNumber': '', 'taxEndDate': '', 'taxType': '' };
                }

            }
            oldRow.push(newRowObject);
            this.requestData = oldRow;
        } else {
            this.showToast('Error', 'Please fill all required details in existing request information section', 'error');
        }
        this.isFirstTime = false;

    }
    showToast(toastTitle, toastMsg, toastVarient) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMsg,
            variant: toastVarient
        });
        this.dispatchEvent(event);
    }
    removeRow(event) {
        if (this.requestData) {
            var dataId = event.currentTarget.getAttribute("data-id");
            var filteredDableData = this.requestData.filter(item => item.id != dataId);
            var secondLastRow = filteredDableData.filter(item => item.id == (parseInt(dataId) - 1));
            secondLastRow.forEach(element => {
                console.log('element.id==>' + element.id);
                element.isLast = true;
                if (element.id == '1') {
                    element.isLast = false;
                }

            });
            this.requestData = filteredDableData;

        }
    }

    handleSubmit(event) {
        event.preventDefault();
        this.showSpinner = true;
        let isValid = [...this.template.querySelectorAll('lightning-input-field')].reduce((val, inp) => {
            let inpVal = true;
            switch (inp.fieldName) {
                case 'Date_of_Notice__c':
                    inpVal = inp.value ? true : false;

                    break;
                case 'Complaint_Number__c':
                    inpVal = inp.value ? true : false;

                    break;
                case 'Owner_Believed_to_Be__c':
                    inp = inp.value ? true : false;

                    break;
                case 'Location_Where_Seized__c':
                    inpVal = inp.value ? true : false;

                    break;
                case 'Provide_an_Explanation_of_the_Dispute__c':
                    inpVal = inp.value ? true : false;

                    break;
                case 'Intent_Number__c':
                    inpVal = inp.value ? true : false;

                    break;
                case 'Tax_Period_End_Date__c':
                    inp = inp.value ? true : false;

                    break;
                case 'Tax_Type__c':
                    inpVal = inp.value ? true : false;

                    break;
                default:
                    inpVal = true;
                    break;
            }
            return val && inpVal;
        }, true)
        var isAllDone = true;
        if (this.requestData.length > 0 && this.selectedRequestType == 'Intent to Assess/Refund Denial or Adjustment') {
            var filteredDableData = this.requestData.filter(item => item.subType == '');
            if (filteredDableData.length > 0) {
                // this.showToast('Error', 'Please fill all required details in existing request information section', 'error');
                isAllDone = false;
            }
        }
        if (isValid && isAllDone) {
            let searchCmp = this.template.querySelector(".ProvideAnExp");
            const myfield = event.detail.fields;
            if (searchCmp) {
                myfield.Provide_an_Explanation_of_the_Dispute__c = searchCmp.value;
            }
            myfield.Type__c = this.selectedRequestType;
            var date = new Date();
            myfield.Received_Date__c = date.toISOString().substring(0, 10);
            
            if(!this.isCheckedBehalfTaxpayer){
                myfield.Taxpayer_Account__c = this.currentUserAccountId;
                myfield.Taxpayer_Contact__c = this.currentUserContactId;  
            }
            this.template.querySelector('lightning-record-edit-form').submit(myfield);
        } else {
            this.showSpinner = false;
            this.template.querySelectorAll('lightning-input-field').forEach(element => {
                element.reportValidity();
            });
            let searchCmp = this.template.querySelector(".nameCmp");
            searchCmp.reportValidity();
            this.showToast('Error', 'Please fill all required details in the Hearing request form.', 'error');
        }
    }
    handleSuccess(event) {
        createDocketRequestAndAttachment({
            docketId: event.detail.id,
            selectedRequestType: this.selectedRequestType,
            mulDocketRequestRecords: this.requestData,
            singleDocketReqDeatils: this.docketRequestData
        })
            .then(result => {
                this.showSpinner = false;
                console.log('result==>' + result);
                this.showToast('Success', 'The Hearing Request has been submitted successfully', 'success');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: event.detail.id,
                        objectApiName: 'Docket__c',
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('error while createDocketRequestAndAttachment');
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
    handleError(event) {
        console.log('errorMessage=ac=>' + event.detail.detail);
        this.showSpinner = false;
        this.showToast('Error while creating Docket', event.detail.detail, 'error');
    }
    handleErrorAttachment(event) {
        console.log('errorMessage=ac=>' + event.detail.detail);
        this.showSpinner = false;
        this.showToast('Error while creating Docket Attachment', event.detail.detail, 'error');
    }
    handleChangeAttachmentType(event) {
        if (event.detail.value) {
            this.enableToUploadButton = true;
            if (event.detail.value == 'Supporting Documentation') {
                this.isShowToNote = true;
                this.isNoteRequire = true;
            } else {
                this.isShowToNote = true;
                this.isNoteRequire = false;
                this.enableToUploadButton = false;
            }
            //this.enableToUploadButtonCon = false;
        } else {
            this.isNoteRequire = false;
            this.isShowToNote = false;
            this.enableToUploadButton = true;
        }

        this.attachmentTypeValue = event.detail.value;
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        this.contentVersionIdList = [];//event.detail.files[0].contentVersionId;
        event.detail.files.forEach(element => {
            this.contentVersionIdList.push(element.documentId);
        });
        if (this.isSingleRequest) {
            this.docketRequestData.docketAttachmentType = this.attachmentTypeValue;
            this.docketRequestData.contentVersionIdList = this.contentVersionIdList;
            this.docketRequestData.taxpayerNotes = this.taxpayerNotesValue;
        } else {
            var secondLastRow = this.requestData.filter(item => item.id == this.idToBeUplodated);
            secondLastRow.forEach(element => {
                element.docketAttachmentType = this.attachmentTypeValue;
                element.contentVersionIdList = this.contentVersionIdList;
                element.taxpayerNotes = this.taxpayerNotesValue;
            });
        }
        this.closeModal();
    }


    onChangeNotesCom(event) {
        if (this.isNoteRequire) {
            if (event.target.value.trim()) {
                this.enableToUploadButton = false;
            } else {
                this.enableToUploadButton = true;
                this.taxpayerNotesValue = '';
            }
        }
        this.taxpayerNotesValue = event.target.value.trim();

    }
    onUploadFileClick(event) {
        this.isSingleRequest = false;
        var dataId = event.currentTarget.getAttribute("data-id");
        this.isModalOpen = true;
        this.idToBeUplodated = '';
        if (dataId == 'Single Request') {
            this.isSingleRequest = true;
        } else {
            this.isSingleRequest = false;
            this.idToBeUplodated = dataId;
        }
    }
    closeModal() {
        this.isModalOpen = false;
        this.attachmentTypeValue = '';
        this.isSingleRequest = false;
        this.isShowToNote = false;
        this.enableToUploadButton = true;
        this.isNoteRequire = true;
    }
}