public with sharing class TriggerDispatcher {
    public Static void run(TriggerInterface handler,System.TriggerOperation opprationType) {
        switch on opprationType {
            
            when BEFORE_INSERT {
                handler.beforeInser(Trigger.new);
            }
            when AFTER_INSERT {
                handler.afterInser(Trigger.new, Trigger.newMap);
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when AFTER_UPDATE {
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            when BEFORE_DELETE {
                handler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_DELETE {
                handler.afterDelete(Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                handler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
    }
}