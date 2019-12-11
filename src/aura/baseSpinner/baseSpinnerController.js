({
	// Check if employee can work today
    doInit: function(component) {
        // Create the action
        var action = component.get("c.employeeMustWork");
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.employeeMustWork", response.getReturnValue());
            }else {
                console.log('Fail in callback to get EmployeeMustWork');
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})