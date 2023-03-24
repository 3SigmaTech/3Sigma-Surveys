trigger Trigger_SurveyResponse on Survey_Response__c (after insert, after update) {

    SurveyResponseHandler handler = new SurveyResponseHandler(Trigger.oldMap, Trigger.newMap, Trigger.old, Trigger.new);
    
    if (Trigger.isBefore){
        /*
        handler.bulkBefore();
        if (Trigger.isDelete){
            for (Survey_Response__c so : Trigger.old){
                handler.beforeDelete(so);
            }
        } else if (Trigger.isInsert){
            for (Survey_Response__c so : Trigger.new){
                handler.beforeInsert(so);
            }
        } else if (Trigger.isUpdate){
            for (Survey_Response__c so : Trigger.old){
                handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
            }
        }
        */
    } else {
        handler.bulkAfter();
        /*
        if (Trigger.isDelete){
            for (Survey_Response__c so : Trigger.old){
                handler.afterDelete(so);
            }
        } else
        */
        if (Trigger.isInsert){
            for (Survey_Response__c so : Trigger.new){
                handler.afterInsert(so);
            }
        } else if (Trigger.isUpdate){
            for (Survey_Response__c so : Trigger.old){
                handler.afterUpdate(so, Trigger.newMap.get(so.Id));
            }
        }
        handler.postProcessing();
    }

}