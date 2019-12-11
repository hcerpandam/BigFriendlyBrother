({
    doInit : function(component, event, helper) {
        alert('Entra en doInit employeeCanWork');
        if(navigator.geoLocation){
			console.log('Geolocation achieved');                                                  
        }
        
        navigator.geoLocation.getCurrentPosition(function(position){
             this.decLatitude=component.set("v.latitude",position.coords.latitude);
             this.decLongitude=component.set("v.longitude", position.coords.longitude);
             console.log("Latitude is:"+this.latitude);
             console.log("Longitude is:" +this.longitude);
        });
    },
    employeeIsAtHeadquarters : function(component, event, callback) {
        alert('Entra en employeeIsAtHeadquarters employeeCanWork');
      var action = component.get("c.doInit");
      	action.setParams({ 
           "decLatitude": this.decLatitude,
           "decLongitude": this.decLongitude
        });
        if (callback) {
           action.setCallback(this, callback);
        }
        $A.enqueueAction(action); 
    }
})