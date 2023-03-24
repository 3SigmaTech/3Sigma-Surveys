global class SurveyController extends SurveyBase
{
  public integer allowableBlanks {get; set;}
  public SurveyController getMyController() {
      return this;
  }
    
  global SurveyController(ApexPages.StandardController stdC)
  {
    settings = Survey_Settings__c.getInstance(Userinfo.getUserId());
    allowableBlanks = 0;
    try
    {
      myCase = [SELECT Id, Subject, Description, ContactId
                  FROM Case
                 WHERE Id =: stdC.getId()
                 LIMIT 1
               ];
      
      myObjectType = 'case';
    }
    catch(Exception e){}
    try
    {
        myResponse = (Survey_Response__c)stdC.getRecord();
        myObjectType = 'response';
    }
    catch(Exception e){}
    try
    {
        mySurvey = (Survey__c)stdC.getRecord();
        myObjectType = 'survey';
    }
    catch(Exception e){}
  }
  global SurveyController() 
  {
    allowableBlanks = 0;
    try
    {
        this.sId = ApexPages.CurrentPage().getParameters().get('sId');
        this.cId = ApexPages.CurrentPage().getParameters().get('cId');
        this.zId = ApexPages.CurrentPage().getParameters().get('zId');
        this.srId = ApexPages.CurrentPage().getParameters().get('srId');
        this.csat = ApexPages.CurrentPage().getParameters().get('csat');
    }
    catch (Exception e) { }
  }


  global PageReference PreLoadResponseDetail()
  {
    LoadResponseInput inputs = new LoadResponseInput();
    inputs.sId = this.sId;
    inputs.cId = this.cId;
    inputs.zId = this.zId;
    inputs.srId = this.srId;
    inputs.csat = this.csat;
    
    Set<string> vC = getValidCSATs();
    if (!vC.contains(inputs.csat))
    {
        inputs.csat = null;
    }
    
    pvt_ResponseDetails = this.LoadResponseDetailInner(inputs);
    return null; 
  }
  
  @RemoteAction
  global static string LoadResponseDetail(string input)
  {
    LoadResponseInput inputs = (LoadResponseInput)JSON.deserialize(input, LoadResponseInput.class);
    
    SurveyController con = new SurveyController();
    
    return JSON.serialize(con.LoadResponseDetailInner(inputs));
  }

  private SurveyResponse pvt_ResponseDetails;
  public SurveyResponse ResponseDetails
  {
      get
      {
        if (pvt_ResponseDetails == null)
        {
          LoadResponseInput inputs = new LoadResponseInput();
          inputs.srId = srId;
          inputs.sId = sId;
          inputs.cId = cId;
          inputs.zId = zId;
          inputs.csat = csat;
                    
          Set<string> vC = getValidCSATs();
          if (!vC.contains(inputs.csat))
          {
              inputs.csat = null;
          }
            
          
          pvt_ResponseDetails = LoadResponseDetailInner(inputs);
        }
        return pvt_ResponseDetails;
      }
  }

  private SurveyResponse LoadResponseDetailInner(LoadResponseInput inputs)
  {
    SurveyResponse rv = new SurveyResponse(inputs);
    
    if (inputs.sId == '') { inputs.sId = null; }
    if (inputs.cId == '') { inputs.cId = null; }
    if (inputs.zId == '') { inputs.zId = null; }
    if (inputs.srId == '') { inputs.srId = null; }
    if (inputs.csat == '') { inputs.csat = null; }
    
    if ( (inputs.sId == null || inputs.cId == null) && (inputs.srId == null) )
    {
        return rv;
    }
    
    if (inputs.sId != null && inputs.cId != null && inputs.srId == null)
    {
        try
        {
            Survey_Response__c mySR = [SELECT Id, Survey__c, Contact__c, Case__c
                                         FROM Survey_Response__c 
                                        WHERE Survey__c = :inputs.sId 
                                          AND Contact__c = :inputs.cId
                                          AND Case__c = :inputs.zId
                                      ];
            inputs.srId = mySR.Id;
        }
        catch (Exception e) { }
    }
    Survey_Response__c mySR = getSurveyResponse(inputs);
    
    inputs.sId = mySR.Survey__c;
    inputs.cId = mySR.Contact__c;
    inputs.zId = mySR.Case__c;
    
    Contact myC = getContact(inputs);
    Survey__c myS = getSurvey(inputs);
    
    List<SurveyEntry> myEs = getEntries(inputs);
    
    if (inputs.csat != null && mySR.CSAT__c != inputs.csat)
    {
        boolean downgraded =  (mySR.CSAT__c == 'Positive' && (inputs.csat == 'Neutral' || inputs.csat == 'Negative'))
                               ||
                              (mySR.CSAT__c == 'Neutral' && inputs.csat == 'Negative');
        boolean upgraded = (mySR.CSAT__c == 'Negative' && (inputs.csat == 'Neutral' || inputs.csat == 'Positive'))
                            ||
                           (mySR.CSAT__c == 'Neutral' && inputs.csat == 'Positive');
                               
        
        if (
            (downgraded && myS.Requires_Downgrade_Explanation__c)
            ||
            (upgraded && myS.Requires_Upgrade_Explanation__c)
           )
        {
            rv.RequiresExplanation = true;
        }
        else
        {
            mySR.CSAT__c = inputs.csat;
            update mySR;
        }
    }
    
    rv.Survey = myS;
    rv.Respondent = myC;
    rv.Response = mySR;
    rv.Entries = myEs;
    
    return rv;
  }
  
  @RemoteAction
  global static String markSurveyResponce(string input){
      SubmitResponseResult rv = new SubmitResponseResult();
      SubmitReasonInput inputs = (SubmitReasonInput)JSON.deserialize(input, SubmitReasonInput.class);
      rv.Id = inputs.Id;
        
      LoadResponseInput lri = new LoadResponseInput();
      lri.srId = inputs.Id;
        
      Survey_Response__c mySR = SurveyBase.getSurveyResponse(lri);
      mySR.x3st_surveys__Survey_Is_Completed__c = true;
      List<Survey_Answer__c> answers = [SELECT Id, Response__c, Survey_Question__c, Survey_Response__r.Survey__c FROM Survey_Answer__c WHERE Survey_Response__c =: mySR.Id];
      Boolean all_answers_ready = true;
      for (Survey_Answer__c answ: answers){
          if (String.isBlank(answ.Response__c)){
              all_answers_ready = false;
          }
      }
      
          update mySR;
          rv.success = true;
          rv.reload = false;
      
      return JSON.serialize(rv);
  }

  @RemoteAction
  global static String SubmitReason(string input)
  {
    SubmitResponseResult rv = new SubmitResponseResult();
    
    try
    {
        SurveyController con = new SurveyController();
        SubmitReasonInput inputs = (SubmitReasonInput)JSON.deserialize(input, SubmitReasonInput.class);
        rv.Id = inputs.Id;
        
        LoadResponseInput lri = new LoadResponseInput();
        lri.srId = inputs.Id;
        
        Survey_Response__c mySR = SurveyBase.getSurveyResponse(lri);
        
        string myReason = null;
        if (inputs.Direction == 'Downgrade')
        {
            myReason = mySR.Downgrade_Explanation__c;
        }
        else if (inputs.Direction == 'Upgrade')
        {
            myReason = mySR.Upgrade_Explanation__c;
        }
        
        Boolean needsUpdate = false;
        if (inputs.Response != null && inputs.Response != '' && inputs.Response != myReason)
        {
            if (inputs.Direction == 'Downgrade')
            {
                mySR.Downgrade_Explanation__c = inputs.Response;
            }
            else if (inputs.Direction == 'Upgrade')
            {
                mySR.Upgrade_Explanation__c = inputs.Response;
            }
            mySR.CSAT__c = inputs.csat;
            needsUpdate = true;
        }
        update mySR;
        rv.success = true;
        rv.reload = true;
    }
    catch (Exception e)
    {
        rv.success = false;
        rv.error = e.getMessage();
    }
    return JSON.serialize(rv);
  }

  @RemoteAction
  global static String SubmitResponse(string input)
  {
    SubmitResponseResult rv = new SubmitResponseResult();
    
    try
    {
        SurveyController con = new SurveyController();
        SubmitResponseInput inputs = (SubmitResponseInput)JSON.deserialize(input, SubmitResponseInput.class);
        rv.Id = inputs.Id;
        
        Survey_Answer__c myA = SurveyBase.getAnswer(Id.valueOf(inputs.Id));
        
        Boolean needsUpdate = false;
        if (inputs.Response != null && inputs.Response != '' && inputs.Response != myA.Response__c)
        {
            myA.Response__c = inputs.Response;
            needsUpdate = true;
        }
        
        if (inputs.DetailResponse != null && inputs.DetailResponse != '' && inputs.DetailResponse != myA.Detail_Response__c)
        {
            myA.Detail_Response__c = inputs.DetailResponse;
            needsUpdate = true;
        }
        update myA;
        rv.success = true;
    }
    catch (Exception e)
    {
        rv.success = false;
        rv.error = e.getMessage();
    }
    return JSON.serialize(rv);
  }
}