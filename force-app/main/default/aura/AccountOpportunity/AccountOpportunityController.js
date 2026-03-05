({
    search : function(component, event, helper) {
        let acctName = component.get("v.acctName")
        if(!acctName) {
            component.set("v.error", "Account Name is required.");
            return;
        }
        component.set("v.error", "");
        let action = component.get("c.fetchAccountAndOpportunities");
        action.setParams({ acctName: acctName });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let res = response.getReturnValue();
                component.set("v.account", res.account);
                component.set("v.opportunities", res.opportunities);
            } else {
                component.set("v.error", "Account not found or query error.");
                component.set("v.account", null);
                component.set("v.opportunities", null);
            }
        });
        $A.enqueueAction(action);
    }
})