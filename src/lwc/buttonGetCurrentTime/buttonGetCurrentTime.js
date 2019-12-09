/* eslint-disable no-console */

import { LightningElement, track  } from 'lwc';

export default class ButtonGetCurrentTime extends LightningElement {

    // currTime: Param for the apex controller
    @track
    currTime = {currTime: {}};

    connectedCallback(){
        this.currTime = Date.now;
        console.log("TCL: ButtonGetCurrentTime -> connectedCallback -> this.currTime", this.currTime)
    }

    handleClick(){
        this.getTimeNow().then(res => {
            this.currTime = res.value;
            console.log("TCL: ButtonGetCurrentTime -> handleClick -> this.currTime", this.currTime)
        })   
    }
  
    getTimeNow(i){
        i.value = new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit', second:'2-digit'});
        console.log("TCL: ButtonGetCurrentTime -> getTimeNow -> i.value", i.value)
    }
    
}
  
