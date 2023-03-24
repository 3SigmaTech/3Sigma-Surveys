public class SurveyEntry
{
    public Survey_Question__c question {get; set;}
    public Survey_Question_Assignment__c assignment {get; set;}
    public Survey_Answer__c answer {get; set;}
    
    public string prompt {
        get
        {
            return question.Prompt__c;
        }
    }
    public string detailprompt {
        get
        {
            return question.More_Info_Prompt__c;
        }
    }
    public string type {
        get
        {
            return question.Question_Type__c;
        }
    }
    public List<string> options {
        get
        {
           List<string> retval = new List<string>();
           if (question.Picklist_Options__c != null)
           {
               retval = question.Picklist_Options__c.split('\\n');
           }
           for (integer ndx = 0; ndx < retval.size(); ndx++)
           {
               retval.set(ndx, retval.get(ndx).trim());
           }
           return retval;
        }
    }
    public string answers_request_detail {
        get
        {
            return question.Answers_That_Request_More_Info__c;
        }
    }
    public string first_label {
        get
        {
            return question.Binary_Label_A__c;
        }
    }
    public string second_label {
        get
        {
            return question.Binary_Label_B__c;
        }
    }
    public decimal min_value {
        get
        {
            return (question.Range_Minimum__c == null ? 1 : question.Range_Minimum__c);
        }
    }
    public decimal max_value {
        get
        {
            return (question.Range_Maximum__c == null ? 10 : question.Range_Maximum__c);
        }
    }
    public decimal step {
        get
        {
            return (question.Range_Step__c == null ? 1 : question.Range_Step__c);
        }
    }
    public list<decimal> values {
        get
        {
            List<decimal> retval = new List<decimal>();
            decimal ndx = min_value;
            while (ndx <= max_value)
            {
                retval.add(ndx);
                ndx += step;
            }
            return retval;
        }
    }
    public boolean require_response {
        get
        {
            return (assignment == null ? null : assignment.Require_Response__c);
        }
    }
    public boolean require_detailresponse {
        get
        {
            return (assignment == null ? null : assignment.Require_More_Detail__c);
        }
    }
    public string display {
        get
        {
            return (assignment == null ? null : assignment.When_To_Display__c);
        }
    }
    public List<string> responses {
        get
        {
            return (answer.Response__c == null ? new List<string>{''} : answer.Response__c.split(';'));
        }
    }
    public boolean hasResponse(string resp) {
        return responses.contains(resp);
    }
    public string response {
        get
        {
            return answer.Response__c;
        }
    }
    public string detailresponse {
        get
        {
            return answer.Detail_Response__c;
        }
    }
    
    private List<SurveyEntry> pvt_followups = new List<SurveyEntry>();
    public List<SurveyEntry> followups {
        get
        {
            return pvt_followups;
        }
    }
    
    public SurveyEntry() { }
    public SurveyEntry(Survey_Question__c q, Survey_Question_Assignment__c qa, Survey_Answer__c a)
    {
        this.question = q;
        this.assignment = qa;
        this.answer = a;
        
        for (Survey_Answer__c fa : a.Follow_Ups__r)
        {
            for (Survey_Question__c fq : q.Follow_Ups__r)
            {
                if (fq.Id == fa.Survey_Question__c) {
                    this.pvt_followups.add(new SurveyEntry(fq, null, fa));
                    break;
                }
            }
        }
    }
}