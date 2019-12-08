// pubsubContactList.js
import { LightningElement, wire } from 'lwc';
import employeeCanWork from '@salesforce/apex/TimeRecordControlController.employeeCanWork';

export default class EmployeeCanNotWork extends LightningElement {

    // searchKey; Partámetro que ppasamos a apex controller

    //@wire(employeeCanWork, { searchKey: '$searchKey' })
    @wire(employeeCanWork)
    boolcanWork; // Ésto es lo que devuelve el controller apex

}