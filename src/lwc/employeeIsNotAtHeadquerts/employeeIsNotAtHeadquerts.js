import { LightningElement, wire } from 'lwc';
import employeeIsAtHeadquerts from '@salesforce/apex/TimeRecordControlController.employeeIsAtHeadquerts';

export default class EmployeeIsNotAtHeadquerts extends LightningElement {

    // geolocationObject; Parámetro que pasamos a apex controller
    geolocationObject;

    @wire(employeeIsAtHeadquerts, { geolocationObject: '$geolocationObject' })// Nombre método ápex
    strResult; // Ésto es lo que devuelve el controller apex. Meter aquí un @track
    
    connectedCallback(){
        this.getLocation().then(res => {
            this.geolocationObject = res.coords;
        })   
    }
    
    getLocation(){
        return new Promise((resolve) => {
            navigator.geolocation.getCurrentPosition(position => {
                resolve(position);
            });
        })
    }

}