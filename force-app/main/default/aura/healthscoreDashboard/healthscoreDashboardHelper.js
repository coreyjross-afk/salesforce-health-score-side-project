({
    loadAccounts : function(component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getAccounts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accounts", response.getReturnValue());
                component.set("v.isLoading", false);
            } else {
                console.error("Failed to load accounts");
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    }
})