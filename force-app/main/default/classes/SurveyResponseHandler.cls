public without sharing class SurveyResponseHandler {
    public static Boolean IsTriggerActive = true;
    public enum TriggerOperation {IS_INSERT, IS_UPDATE, IS_DELETE}
    @testVisible
    private Map<Id, Survey_Response__c> oldMap {get; set;}
    private Map<Id, Survey_Response__c> newMap {get; set;}
    private List<Survey_Response__c> oldList {get; set;}
    private List<Survey_Response__c> newList {get; set;}
    private TriggerOperation operation {get; set;}
    private Map<Id, Case> ParentCases;
    
    private List<Survey_Question_Assignment__c> ParentSurveyQuestionAssignments;
    private List<Survey_Answer__c> ChildAnswers;
    private List<Survey_Answer__c> ChildAnswersOrdered;
    private List<Survey_Response__c> ResponsesToUpdate;
    
    public boolean runFromAnswers = false;
    
    public SurveyResponseHandler (Map<Id, Survey_Response__c> oldMap, Map<Id, Survey_Response__c> newMap,
                                      List<Survey_Response__c> oldList, List<Survey_Response__c> newList)
    {
        this.oldMap = oldMap;
        this.newMap = newMap;
        this.oldList = oldList;
        this.newList = newList;
        
        if (oldList == null) {
            this.operation = TriggerOperation.IS_INSERT;
        }
        else {
            this.operation = TriggerOperation.IS_UPDATE;
        }
        
        ResponsesToUpdate = new List<Survey_Response__c>();
    }
    
    public void bulkAfter() {
        if (this.operation == TriggerOperation.IS_DELETE) {
            return;
        }
        
        Set<Id> case_ids = new Set<Id>();
        Set<Id> survey_response_ids = new Set<Id>();
        Set<Id> survey_ids = new Set<Id>();
        
        for (Survey_Response__c sr : newList) {
            if(sr.Case__c != null) {
                case_ids.add(sr.Case__c);
            }
            survey_response_ids.add(sr.Id);
            survey_ids.add(sr.Survey__c);
        }
        
        if (case_ids.size() > 0) {
            ParentCases = new Map<Id, Case>([SELECT Id, AccountId, CSAT_Survey_Response__c
                                                  , CSAT__c, Has_Detailed_CSAT__c
                                               FROM Case
                                              WHERE Id IN: case_ids
                                            ]);
        }
        
        ParentSurveyQuestionAssignments = [SELECT Id, Survey__c, Order__c, Survey_Question__c
                                             FROM Survey_Question_Assignment__c
                                            WHERE Survey__c in :survey_ids
                                            ORDER BY Order__c
                                          ];
        
        ChildAnswers = [SELECT Id, Response__c, Detail_Response__c, Question_Prompt__c, Question_Detail_Prompt__c
                             , Survey_Response__c, Survey_Question__c, Survey_Response__r.Case__c
                             , (SELECT Id, Response__c, Detail_Response__c, Question_Prompt__c, Question_Detail_Prompt__c
                                     , Survey_Response__c, Survey_Question__c, Survey_Response__r.Case__c
                                  FROM Follow_Ups__r
                                 ORDER BY Survey_Question__r.Followup_Order__c
                               )
                          FROM Survey_Answer__c
                         WHERE Survey_Response__c in :survey_response_ids
                       ];
        
        ChildAnswersOrdered = new List<Survey_Answer__c>();
        for (Survey_Question_Assignment__c sqa : ParentSurveyQuestionAssignments)
        {
            for (Survey_Response__c sr : newList)
            {
                for (Survey_Answer__c sa : ChildAnswers)
                {
                    if (sr.Id == sa.Survey_Response__c && sa.Survey_Question__c == sqa.Survey_Question__c)
                    {
                        ChildAnswersOrdered.add(sa);
                    }
                }
            }
        }
    }
    
    public void afterInsert(Survey_Response__c so) {
        collateToParent(so);
    }
    
    public void afterUpdate(Survey_Response__c oldSo, Survey_Response__c so) {
        collateToParent(so);
    }
    
    public void postProcessing() {
        if (ParentCases != null) {
            update ParentCases.values();
        }
    }
    
    private void collateToParent(Survey_Response__c so) {
        
        string collatedResponse = '';
        
        collatedResponse += 
              '<b>' + so.CSAT__c + ' CSAT Left on ' 
            + so.CreatedDate.format('MM/dd/yyyy hh:mm aaa z')
            + '</b><br>'
            + ( so.Downgrade_Explanation__c != null && so.Downgrade_Explanation__c != ''
              ? '<div style="margin-left: 40px;"><b>Downgrade Explanation</b></div>'
              + '<div style="margin-left: 80px;">' + so.Downgrade_Explanation__c + '</b></div>'
              : ''
              )
            + ( so.Upgrade_Explanation__c != null && so.Upgrade_Explanation__c != ''
              ? '<div style="margin-left: 40px;"><b>Upgrade Explanation</b></div>'
              + '<div style="margin-left: 80px;">' + so.Upgrade_Explanation__c + '</b></div>'
              : ''
              )
            ;
        for (Survey_Answer__c sa : ChildAnswersOrdered) {
            if (sa.Survey_Response__c == so.Id)
            {
                collatedResponse += getAnswerCollation(sa, 1);
                
                for (Survey_Answer__c fu : sa.Follow_Ups__r) {
                    collatedResponse += getAnswerCollation(fu, 3);
                }
            }
        }
        
        if (!runFromAnswers && ParentCases != null) {
            Case parent_case = ParentCases.get(so.Case__c);
            
            if (parent_case == null) {
                return;
            }
    
            parent_case.Has_Detailed_CSAT__c = so.Has_Detailed_Responses__c;
            parent_case.CSAT__c = so.CSAT__c;
            parent_case.CSAT_Survey_Response__c = collatedResponse;
            
            ParentCases.put(parent_case.Id, parent_case);
        } else if (runFromAnswers) {
            so.Collated_Responses__c = collatedResponse;
        }
    }
    
    private string getAnswerCollation(Survey_Answer__c sa, integer indent) {
        string ind0 = string.valueOf((indent - 1) * 40);
        string ind1 = string.valueOf(indent * 40);
        string ind2 = string.valueOf((indent + 1) * 40);
        return ( 
            (sa.Response__c != null && sa.Response__c != '')
             ||
            (sa.Detail_Response__c != null && sa.Detail_Response__c != '')
            ? '<div style="margin-left: ' + ind0 + 'px;"><b>' + sa.Question_Prompt__c + '</b></div>'
            + ( sa.Response__c != null && sa.Response__c != ''
              ? '<div style="margin-left: ' + ind1 + 'px;">' + sa.Response__c + '</div>'
              : ''
              )
            : ''
            )
            +
            ( sa.Detail_Response__c != null && sa.Detail_Response__c != ''
              &&
              sa.Question_Detail_Prompt__c != null && sa.Question_Detail_Prompt__c != ''
            ? '<div style="margin-left: ' + ind1 + 'px;"><b>' + sa.Question_Detail_Prompt__c + '</b></div>'
            + '<div style="margin-left: ' + ind2 + 'px;">' + sa.Detail_Response__c + '</div>'
            : ''
            )
            +
            ( sa.Detail_Response__c != null && sa.Detail_Response__c != ''
              &&
              (sa.Question_Detail_Prompt__c == null || sa.Question_Detail_Prompt__c == '')
            ? '<div style="margin-left: ' + ind1 + 'px;">' + sa.Detail_Response__c + '</div>'
            : ''
            )
            +
            ( sa.Follow_Ups__r.size() > 0
              &&
              sa.Question_Detail_Prompt__c != null && sa.Question_Detail_Prompt__c != ''
            ? '<div style="margin-left: ' + ind1 + 'px;"><b>' + sa.Question_Detail_Prompt__c + '</b></div>'
            : ''
            );
    } 
}