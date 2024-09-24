import { LightningElement, api, track } from 'lwc';
import miTreasDocketRequest from '@salesforce/apex/miTreasDocketRequestController.miTreasDocketRequest';
import createDocketRequest from '@salesforce/apex/miTreasDocketRequestController.createDocketRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from "lightning/refresh";

const columns = [   
	{label: 'Assessment Number', fieldName: 'AssessmentNumber', type: 'Text',initialWidth:50},
	{label: 'Intent Date', fieldName: 'IntentDate', type: 'text',initialWidth:50},
	{label: 'Tax Type', fieldName: 'TaxType', type: 'Text',initialWidth:50},
	{label: 'TaxPeriod StartDate', fieldName: 'TaxPeriodStartDate', type: 'text',initialWidth:80},
    {label: 'TaxPeriod EndDate', fieldName: 'TaxPeriodEndDate', type: 'text',initialWidth:80},
	{label: 'Account Name', fieldName: 'AccountName', type: 'text',initialWidth:80},
    {label: 'BP Number', fieldName: 'SAPAccountNumber', type: 'text', initialWidth:80},
	{label: 'Identification Number', fieldName: 'IdentificationNumber', type: 'Text',initialWidth:80},
    {label: 'Identification Type', fieldName: 'IdentificationType', type: 'text',initialWidth:80},
    {label: 'Project Code', fieldName: 'ProjectCode', type: 'Text',initialWidth:80},
    {label: 'Original TaxAmount', fieldName: 'OriginalTaxAmount', type: 'text',initialWidth:80},
    {label: 'Original PenaltyAmount', fieldName: 'OriginalPenaltyAmount', type: 'Text',initialWidth:80},
    {label: 'Original InterestAmount', fieldName: 'OriginalInterestAmount', type: 'text',initialWidth:80},
    {label: 'FinalAssessmentDate', fieldName: 'FinalAssessmentDate', type: 'text',initialWidth:80},
    {label: 'HearingHoldIndicator', fieldName: 'HearingHoldIndicator', type: 'text',initialWidth:80},
    {label: 'System Date', fieldName: 'SystemDate', type: 'text',initialWidth:80},
    {label: 'PrimarySecondaryAccount', fieldName: 'PrimarySecondaryAccount', type: 'text',initialWidth:80},
    {label: 'FTI Flag', fieldName: 'FTIFlag', type: 'text',initialWidth:80}, 
];

export default class MiTreasDocRequestLWC extends LightningElement {

    recordsToDisplay = [];
    @track columns = columns;
    @track error; 
    @api recordId;
    totalRecords = 0; //Total no.of records
    pageSize = 12; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    recordsToDisplayPagination = []; //Records to be displayed on the page
    selectedRecords = [];
    //selectedData = [];
    //currentlySelectedData = [];
    @track isDatatableVisible = true;

    get isCDRenabled(){
        return !this.selectedRecords || this.selectedRecords.length === 0;
    }
    get isFirst(){
        return this.pageNumber === 1;
    }

    get isPrevious(){
        return this.pageNumber === 1;
    }

    get isNext(){
        return this.pageNumber === this.totalPages;
    }

    get isLast(){
        return this.pageNumber === this.totalPages;
    }

    fetchMitreasData() {
 
		// fetch MiTreas records from Apex method.
		miTreasDocketRequest({
            docketId: this.recordId
            }).then((result) => {
                if (result != null && result.length > 0) {
                    console.log('RESULT--> ' + JSON.stringify(result));
                    this.totalRecords = result.length; // update total records count   
                    this.recordsToDisplayPagination = result;              
                    this.totalPages = Math.ceil(this.totalRecords / this.pageSize);   
                    this.pageNumber = 1;
                    this.paginationHelper(); // call helper menthod to update pagination logic 
                }else if(result == null){

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'No Corresponding Account found in S4 Collection System.',
                            variant: 'error',
                            mode: 'sticky',
                        })
    
                    );
                    
                }
            })
            .catch((error) => {
                console.log('error while fetch records from MiTreas--> ' + JSON.stringify(error));

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky',
                    })

                );
            });
        
       
   }

   handleRowSelection(event){
    //var selectedRows = event.detail.selectedRows;
    this.selectedRecords = event.detail.selectedRows;
/*
    selectedData = [];
    currentlySelectedData = [];

    switch (event.detail.config.action) {
        case 'selectAllRows':
            for (let i = 0; i < event.detail.selectedRows.length; i++) {
                this.selectedData.push(event.detail.selectedRows[i]);
                this.currentlySelectedData.push(event.detail.selectedRows[i]);
            }
            break;
        case 'deselectAllRows':
            this.currentlySelectedData = [];
            break;
        case 'rowSelect':
            this.selectedData.push(event.detail.config.value);
            break;
        case 'rowDeselect':
            index = currentlySelectedData.indexOf(event.detail.config.value);
            if (index !== -1) {
                array.splice(index, 1);
            }
            break;
        default:
            break;
    }

    console.log('selected records', this.selectedData );
    console.log('currently selected records', this.currentlySelectedData);
    */
    //this.selectedRecords = selectedRows;
   // for ( let i = 0; i < selectedRows.length; i++ ) {

       // this.selectedRecords.push(selectedRows[i]);

   // }
    //this.selectedRecords = selectedRows;
    console.log('selected records', this.selectedRecords );
    console.log(
        'selectedRows are ',
        JSON.stringify( this.selectedRecords )
    );
       //this.selectedRecords = event.detail;
       //console.log('event selected records check', this.selectedRecords );
     
   }

   createDocketRequestCDR(event){
       console.log('Create Docket Request Button clicked');
       console.log('selected records check', this.selectedRecords );
    //if(this.selectedRows.length > 0){
            console.log('Docket Id', this.recordId);
            console.log('Selected Records', this.selectedRecords);
            
          
        createDocketRequest({docketId: this.recordId, selectionList: JSON.stringify( this.selectedRecords )})
            .then(() => {
                console.log('Docket Request Created Successfully');
                this.isDatatableVisible = false;
                //Handle success
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Docket Request Created Successfully',
                        variant: 'success',
                    })
                    );

             console.log('Record Id ==> '+ this.recordId);		
             this.selectedRecords = []; 
             this.template.querySelector('lightning-datatable').selectedRows=[];
             
             this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) =>{
                console.error('Error while creating Docket:',error);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky',
                    })

                );
            });
    //}
   }

   // JS function to handel pagination logic 
 paginationHelper() {

    const startIndex = (this.pageNumber - 1) * this.pageSize;
    const endIndex = Math.min(startIndex + this.pageSize, this.totalRecords);
    this.recordsToDisplay = this.recordsToDisplayPagination.slice(startIndex, endIndex);
 }
    
   previousPage() {

    console.log('selected records', this.selectedRecords );
       if(this.selectedRecords.length>0){
        this.dispatchEvent(
            new ShowToastEvent({
                message: 'Please create docket request for selected records before moving to another page.',
                variant: 'error',
                mode: 'sticky',
            })

            );
            }

    if(this.selectedRecords.length === 0){
    if(this.pageNumber > 1){
     this.pageNumber -= 1;
     this.paginationHelper();
    }
    }
 }

 nextPage() {

    console.log('selected records', this.selectedRecords );
       if(this.selectedRecords.length>0){
        this.dispatchEvent(
            new ShowToastEvent({
                message: 'Please create docket request for selected records before moving to another page.',
                variant: 'error',
                mode: 'sticky',
            })

            );
            } 

    if(this.selectedRecords.length === 0){
     if(this.pageNumber < this.totalPages){
     this.pageNumber += 1;
     this.paginationHelper();
     }
   }
 }

 firstPage() {

    console.log('selected records', this.selectedRecords );
        if(this.selectedRecords.length>0){
        this.dispatchEvent(
            new ShowToastEvent({
                message: 'Please create docket request for selected records before moving to another page.',
                variant: 'error',
                mode: 'sticky',
            })

            );
            }

     if(this.selectedRecords.length === 0){
     this.pageNumber = 1;
     this.paginationHelper();
     }
 }

 lastPage() {

    console.log('selected records', this.selectedRecords );
        if(this.selectedRecords.length>0){
        this.dispatchEvent(
            new ShowToastEvent({
                message: 'Please create docket request for selected records before moving to another page.',
                variant: 'error',
                mode: 'sticky',
            })

            );
            }

    if(this.selectedRecords.length === 0){
     this.pageNumber = this.totalPages;
     this.paginationHelper();
    }
 }
 
 


}