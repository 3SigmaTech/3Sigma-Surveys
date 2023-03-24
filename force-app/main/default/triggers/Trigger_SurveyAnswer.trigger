trigger Trigger_SurveyAnswer on Survey_Answer__c (after update) {
    
    
    List<Id> response_ids = new List<Id>();
    
    for (Survey_Answer__c sa : Trigger.new) {
        response_ids.add(sa.Survey_Response__c);
    }
    
    List<Survey_Response__c> responses = [SELECT Id, Case__c, Contact__c, Survey__c, Survey_Name__c
                                               , Collated_Responses__c, CSAT__c
                                               , Downgrade_Explanation__c, Has_Detailed_Responses__c
                                               , Survey_Response_URL__c, Upgrade_Explanation__c
                                               , CreatedDate
                                            FROM Survey_Response__c
                                           WHERE Id in :response_ids
                                         ];
    
    SurveyResponseHandler srh = new SurveyResponseHandler(null, null, null, responses);
    
    srh.runFromAnswers = true;
    srh.bulkAfter();
    
    for (Survey_Response__c sr : responses) {
        srh.afterInsert(sr);
    }
    
    for (Survey_Answer__c sa : Trigger.new) {
        for (Survey_Response__c sr : responses) {
            if (sa.Survey_Response__c == sr.Id) {
                if (sa.Response__c != null && sa.Response__c != '') {
                    sr.Has_Detailed_Responses__c = true;
                    break;
                }
            }
        }
    }
    
    // Update all responses to trigger collation on related cases
    update responses;
    
}