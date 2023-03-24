global class SurveyEmailController extends SurveyBase
{
    global SurveyEmailController(ApexPages.StandardController stdC) { }
    
    public Id caseId {get; set;}
    public Id surveyId {get; set;}
    public Id responseId {get; set;}
         
    private Case pvt_surveyCase;     
    public Case surveyCase
    {
        get
        {
            if (caseId == null) { return null; }
            return [SELECT Id, Subject, Description, ContactId
                      FROM Case
                     WHERE Id = :caseId
                     LIMIT 1
                   ];
        }
    }
    
    private Survey__c pvt_survey;     
    public Survey__c survey
    {
        get
        {
            if (surveyId == null) { return null; }
            return [SELECT Notes__c, Logo__c, Primary_Color__c, Survey_Title__c
                         , Downgrade_Explanation_Prompt__c, Upgrade_Explanation_Prompt__c
                         , Requires_Downgrade_Explanation__c, Requires_Upgrade_Explanation__c
                         , Instructions__c, Footnotes__c, Post_Submission_Display__c
                         , Negative_Display__c, Neutral_Display__c, Positive_Display__c
                      FROM Survey__c
                     WHERE Id = :surveyId
                     LIMIT 1
                   ];
        }
    }
    
    private Survey_Response__c pvt_surveyResponse;     
    public Survey_Response__c surveyResponse
    {
        get
        {
            if (responseId == null) { return null; }
            return [SELECT Id, Case__c, Contact__c, Survey__c, CSAT__c
                         , Downgrade_Explanation__c, Upgrade_Explanation__c, Survey_Response_URL__c
                         , Survey__r.Notes__c, Survey__r.Logo__c, Survey__r.Primary_Color__c, Survey__r.Survey_Title__c
                         , Survey__r.Downgrade_Explanation_Prompt__c, Survey__r.Upgrade_Explanation_Prompt__c
                         , Survey__r.Requires_Downgrade_Explanation__c, Survey__r.Requires_Upgrade_Explanation__c
                         , Survey__r.Instructions__c, Survey__r.Footnotes__c, Survey__r.Post_Submission_Display__c
                         , Survey__r.Negative_Display__c, Survey__r.Neutral_Display__c, Survey__r.Positive_Display__c
                         , ( SELECT Id, Question_Type__c, Question_Prompt__c, Response__c
                                  , Question_Detail_Prompt__c, Detail_Response__c
                               FROM Survey_Answers__r
                           )
                      FROM Survey_Response__c
                     WHERE Id = :responseId
                     LIMIT 1
                   ];
        }
    }
    
    public PageReference SendSurvey() { return null; }
    public PageReference ResendSurveyResponse() { return null; }
    public PageReference ResendSurvey() { return null; }
    
    
  /*
  public void SendEmail(Id who, Id what, Id template, Id orgEmail, string subject, string body)
  {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    if (template != null)
    {
        message = Messaging.renderStoredEmailTemplate(template, who, what);
    }
    else
    {
        message.setTargetObjectId(who);
        message.setWhatId(what);
        if (body != '') { message.setHtmlBody(body); }
    }
    if (subject != '') { message.setSubject(subject); }
    
    if (orgEmail != null)
    {
      message.setOrgWideEmailAddressId(orgEmail);
    }
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
    Messaging.SendEmailResult[] results = null;
    
    //try
    //{
        results = Messaging.sendEmail(messages);
    //}
    //catch (DMLException e)
    //{
    //    system.debug('Email failed');
    //}

    if (results[0].success)
    {
        System.debug('The email was sent successfully.');
    }
    else
    {
        System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }
  */
}