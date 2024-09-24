import { LightningElement, api } from "lwc";

export default class PreviewFileModal extends LightningElement {
  @api url;
  @api fileExtension;
  @api fileName;
  showFrame = false;
  showModal = false;
  loadpdf(){
    // console.log('abds==>',this.template.querySelector('iframe'));
    // if(this.template.querySelector('iframe')){
    //     console.log('abds=dd=>',this.template.querySelector('iframe').contents().this.template.querySelector("span#title"));
    //     //find("#toolbarViewerRight").hide()
    // this.template.querySelector('iframe').contents().this.template.querySelector("#title").hide()
    //}
    
  }
  @api show() {
    console.log("###showFrame : " + this.fileExtension);
    if (this.fileExtension === "pdf" || this.fileExtension === "doc" || this.fileExtension === "docx") 
    {
      this.showFrame = true;
    }
    else this.showFrame = false;
    this.showModal = true;
  }
  closeModal() {
    this.showModal = false;
    this.dispatchEvent(new CustomEvent('close', { detail: {} }));
  }
}