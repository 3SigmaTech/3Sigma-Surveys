global virtual class SurveyBase {
    protected final Case myCase {
        get;
        set;
    }
    protected final Survey__c mySurvey {
        get;
        set;
    }
    protected final Survey_Response__c myResponse {
        get;
        set;
    }

    public string myObjectType {
        get;
        set;
    }
    public Survey_Settings__c settings {
        get;
        set;
    }
    global string srId {
        get;
        set;
    }
    global string sId {
        get;
        set;
    }
    global string cId {
        get;
        set;
    }
    global string zId {
        get;
        set;
    }
    global string csat {
        get;
        set;
    }
    global boolean isEmail {
        get;
        set;
    }

    public class surveyException extends Exception {}

    public class LoadResponseInput {
        public string srId {
            get;
            set;
        }
        public string sId {
            get;
            set;
        }
        public string cId {
            get;
            set;
        }
        public string zId {
            get;
            set;
        }
        public string csat {
            get;
            set;
        }

        public LoadResponseInput() {
            srId = null;
            sId = null;
            cId = null;
            zId = null;
            csat = 'Neutral';
        }
    }

    public class SurveyResponse {
        public LoadResponseInput inputs {
            get;
            set;
        }

        public Survey__c survey {
            get;
            set;
        }
        public Survey_Response__c response {
            get;
            set;
        }
        public Contact respondent {
            get;
            set;
        }
        public List <SurveyEntry> entries {
            get;
            set;
        }
        public boolean RequiresExplanation {
            get;
            set;
        }

        public string title {
            get {
                return survey.Survey_Title__c;
            }
        }
        public string instructions {
            get {
                return (survey.Instructions__c != null ? survey.Instructions__c : '')
                    .replace('{!Contact.First_Name}', this.firstname != null ? this.firstname : '')
                    .replace('{!Contact.Last_Name}', this.lastname != null ? this.lastname : '')
                    .replace('{!Contact.Email}', this.email != null ? this.email : '');
            }
        }
        public string positiveDisplay {
            get {
                return (survey.Positive_Display__c != null ? survey.Positive_Display__c : '')
                    .replace('{!Contact.First_Name}', this.firstname != null ? this.firstname : '')
                    .replace('{!Contact.Last_Name}', this.lastname != null ? this.lastname : '')
                    .replace('{!Contact.Email}', this.email != null ? this.email : '');
            }
        }
        public string negativeDisplay {
            get {
                return (survey.Negative_Display__c != null ? survey.Negative_Display__c : '')
                    .replace('{!Contact.First_Name}', this.firstname != null ? this.firstname : '')
                    .replace('{!Contact.Last_Name}', this.lastname != null ? this.lastname : '')
                    .replace('{!Contact.Email}', this.email != null ? this.email : '');
            }
        }
        public string neutralDisplay {
            get {
                return (survey.Neutral_Display__c != null ? survey.Neutral_Display__c : '')
                    .replace('{!Contact.First_Name}', this.firstname != null ? this.firstname : '')
                    .replace('{!Contact.Last_Name}', this.lastname != null ? this.lastname : '')
                    .replace('{!Contact.Email}', this.email != null ? this.email : '');
            }
        }
        public string footnotes {
            get {
                return (survey.Footnotes__c != null ? survey.Footnotes__c : '')
                    .replace('{!Contact.First_Name}', this.firstname != null ? this.firstname : '')
                    .replace('{!Contact.Last_Name}', this.lastname != null ? this.lastname : '')
                    .replace('{!Contact.Email}', this.email != null ? this.email : '');
            }
        }
        public string downgradePrompt {
            get {
                return (survey.Downgrade_Explanation_Prompt__c != null ? survey.Downgrade_Explanation_Prompt__c : '')
                    .replace('{!Contact.First_Name}', this.firstname != null ? this.firstname : '')
                    .replace('{!Contact.Last_Name}', this.lastname != null ? this.lastname : '')
                    .replace('{!Contact.Email}', this.email != null ? this.email : '')
                    .replace('{!Old.CSAT}', this.csat != null ? this.csat : '')
                    .replace('{!New.CSAT}', this.inputs.csat != null ? this.inputs.csat : '');
            }
        }
        public string upgradePrompt {
            get {
                return (survey.Upgrade_Explanation_Prompt__c != null ? survey.Upgrade_Explanation_Prompt__c : '')
                    .replace('{!Contact.First_Name}', this.firstname != null ? this.firstname : '')
                    .replace('{!Contact.Last_Name}', this.lastname != null ? this.lastname : '')
                    .replace('{!Contact.Email}', this.email != null ? this.email : '')
                    .replace('{!Old.CSAT}', this.csat != null ? this.csat : '')
                    .replace('{!New.CSAT}', this.inputs.csat != null ? this.inputs.csat : '');
            }
        }
        public boolean RequiresUpgradeExplanation {
            get {
                return survey.Requires_Upgrade_Explanation__c;
            }
        }
        public boolean RequiresDowngradeExplanation {
            get {
                return survey.Requires_Downgrade_Explanation__c;
            }
        }
        public string downgradeExplanation {
            get {
                return response.Downgrade_Explanation__c == null ? null : response.Downgrade_Explanation__c.replace('\n', '<br/>');
            }
        }
        public string upgradeExplanation {
            get {
                return response.Upgrade_Explanation__c == null ? null : response.Upgrade_Explanation__c.replace('\n', '<br/>');
            }
        }
        public string logo {
            get {
                return survey.Logo__c;
            }
        }
        public string color {
            get {
                return survey.Primary_Color__c;
            }
        }
        public string postscreen {
            get {
                return survey.Post_Submission_Display__c;
            }
        }
        public string csat {
            get {
                return response.CSAT__c;
            }
        }
        public string firstname {
            get {
                return respondent.FirstName;
            }
        }
        public string lastname {
            get {
                return respondent.LastName;
            }
        }
        public string email {
            get {
                return respondent.Email;
            }
        }

        public SurveyResponse(LoadResponseInput passedInputs) {
            inputs = passedInputs;
            RequiresExplanation = false;
        }
    }

    public class SubmitResponseInput {
        public string Id {
            get;
            set;
        }
        public String response {
            get;
            set;
        }
        public String detailresponse {
            get;
            set;
        }

        public SubmitResponseInput() {
            Id = null;
            response = null;
            detailresponse = null;
        }
    }

    public class SubmitReasonInput {
        public string Id {
            get;
            set;
        }
        public String response {
            get;
            set;
        }
        public String direction {
            get;
            set;
        }
        public String csat {
            get;
            set;
        }

        public SubmitReasonInput() {
            Id = null;
            response = null;
            direction = null;
            csat = null;
        }
    }

    public class SubmitResponseResult {
        public string Id {
            get;
            set;
        }
        public boolean success {
            get;
            set;
        }
        public boolean reload {
            get;
            set;
        }
        public string error {
            get;
            set;
        }

        public SubmitResponseResult() {
            Id = null;
            success = false;
            reload = false;
            error = 'Invalid inputs';
        }
    }

    public static Set <String> getValidCSATs() {
        Set <String> rv = new Set <String> ();
        Schema.DescribeFieldResult fieldResult = Survey_Response__c.CSAT__c.getDescribe();
        List <Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry val: ple) {
            rv.add(val.getLabel());
        }
        return rv;
    }

    public static Survey__c getSurvey(LoadResponseInput inputs) {
        Survey__c s = new Survey__c();

        if (inputs.sId != null) {
            s = [SELECT Id, Instructions__c, Logo__c, Primary_Color__c, Notes__c, Post_Submission_Display__c, Survey_Title__c, Positive_Display__c, Negative_Display__c, Neutral_Display__c, Footnotes__c, Requires_Downgrade_Explanation__c, Requires_Upgrade_Explanation__c, Downgrade_Explanation_Prompt__c, Upgrade_Explanation_Prompt__c
                FROM Survey__c
                WHERE Id =: inputs.sId
            ];
        }
        return s;
    }

    public static Survey_Response__c getSurveyResponse(LoadResponseInput inputs) {
        Survey_Response__c sr = null;

        if (inputs.srId != null) {
            try {
                sr = [SELECT Id, Contact__c, Survey__c, Case__c, CSAT__c, Downgrade_Explanation__c, Upgrade_Explanation__c
                    FROM Survey_Response__c
                    WHERE Id =: inputs.srId
                ];
                inputs.sId = sr.Survey__c;
                inputs.cId = sr.Contact__c;
                inputs.zId = sr.Case__c;
            } catch (Exception e) {}

        } else if (inputs.sId != null && inputs.cId != null) {
            try {
                sr = [SELECT Id, Contact__c, Survey__c, CSAT__c
                    FROM Survey_Response__c
                    WHERE Contact__c =: inputs.cId
                    AND Survey__c =: inputs.sId
                    AND Case__c =: inputs.zId
                ];
                inputs.srId = sr.Id;
            } catch (Exception e) {}
        }

        if (sr == null) {
            sr = new Survey_Response__c();
            sr.Survey__c = inputs.sId;
            sr.Contact__c = inputs.cId;
            sr.Case__c = inputs.zId;
            sr.CSAT__c = inputs.csat;
            insert sr;
            system.debug('Survey Response Inserted with ID : ' + sr.Id);
            inputs.srId = sr.Id;
        }

        return sr;
    }

    public static Contact getContact(LoadResponseInput inputs) {
        Contact C = new Contact();

        if (inputs.cId != null) {
            c = [SELECT Id, FirstName, LastName, Email
                FROM Contact
                WHERE Id =: inputs.cId
            ];
        }
        return c;
    }

    public static List <Survey_Question_Assignment__c> getAssignments(LoadResponseInput inputs) {
        List <Survey_Question_Assignment__c> qas = new List <Survey_Question_Assignment__c> ();

        if (inputs.sId != null) {
            qas = [SELECT Id, Order__c, Survey__c, Survey_Question__c, Require_More_Detail__c, Require_Response__c, When_To_Display__c
                FROM Survey_Question_Assignment__c
                WHERE Survey__c =: inputs.sId
                ORDER BY Order__c, CreatedDate
            ];
        }
        return qas;
    }

    public static List <Survey_Question__c> getQuestions(List <Survey_Question_Assignment__c> qas) {
        List <Survey_Question__c> qs = [SELECT Id, Prompt__c, More_Info_Prompt__c, Question_Type__c, Picklist_Options__c, Answers_That_Request_More_Info__c, Binary_Label_A__c, Binary_Label_B__c
                                             , Range_Minimum__c, Range_Maximum__c, Range_Step__c
                                             , ( SELECT Id, Prompt__c, More_Info_Prompt__c, Question_Type__c, Picklist_Options__c, Answers_That_Request_More_Info__c, Binary_Label_A__c, Binary_Label_B__c
                                                      , Range_Minimum__c, Range_Maximum__c, Range_Step__c
                                                   FROM Follow_Ups__r
                                                  ORDER BY Followup_Order__c
                                               )
                                          FROM Survey_Question__c
                                         WHERE Id IN (SELECT Survey_Question__c
                                                        FROM Survey_Question_Assignment__c
                                                       WHERE Id IN: qas
                                                     )
        ];
        return qs;
    }

    public static List <Survey_Answer__c> getAnswers(List <Survey_Question__c> qs, Id srId) {
        List <Survey_Answer__c> ans = [SELECT Id, Response__c, Detail_Response__c, Survey_Question__c, Survey_Response__c
                                            , ( SELECT Id, Response__c, Detail_Response__c, Survey_Question__c, Survey_Response__c
                                                  FROM Follow_Ups__r
                                                 ORDER BY Survey_Question__r.Followup_Order__c
                                              )
                                         FROM Survey_Answer__c
                                        WHERE Survey_Question__c IN: qs
                                          AND Survey_Response__c =: srId
                                      ];
        return ans;
    }

    public static Survey_Answer__c getAnswer(Id aId) {
        Survey_Answer__c a = [SELECT Id, Response__c, Detail_Response__c, Survey_Question__c, Survey_Response__c
                                   , ( SELECT Id, Response__c, Detail_Response__c, Survey_Question__c, Survey_Response__c
                                         FROM Follow_Ups__r
                                        ORDER BY Survey_Question__r.Followup_Order__c
                                     )
                                FROM Survey_Answer__c
                               WHERE Id =: aId
                             ];
        return a;
    }

    public static Survey_Question__c findQuestion(List <Survey_Question__c> qs, Id qId) {
        for (Survey_Question__c q: qs) {
            if (q.Id == qId) {
                return q;
            }
        }
        return null;
    }

    public static Survey_Answer__c findAnswer(List <Survey_Answer__c> ans, Survey_Question__c q, Id srId) {
        for (Survey_Answer__c a: ans) {
            if (a.Survey_Question__c == q.Id) {
                
                if (q.Follow_Ups__r != null && a.Follow_Ups__r.size() < q.Follow_Ups__r.size()) {
                    
                    List<Survey_Answer__c> follow_ups = new List<Survey_Answer__c> ();
                    
                    for (Survey_Question__c fuq : q.Follow_Ups__r) {
                        boolean gotit = false;
                        
                        for (Survey_Answer__c fua : a.Follow_Ups__r) {
                            if (fuq.Id == fua.Survey_Question__c) {
                                gotit = true;
                                break;
                            }
                        }
                        
                        if (!gotit) {
                            Survey_Answer__c fua = new Survey_Answer__c();
                            fua.Survey_Question__c = fuq.Id;
                            fua.Survey_Response__c = srId;
                            fua.Follows_Up__c = a.Id;
                            follow_ups.add(fua);
                        }
                    }
                    insert follow_ups;
                    a = getAnswer(a.Id);
                }

                return a;
            }
        }
        Survey_Answer__c a = new Survey_Answer__c();
        a.Survey_Question__c = q.Id;
        a.Survey_Response__c = srId;
        insert a;
        system.debug('Survey Answer Inserted with ID : ' + a.Id);

        if (q.Follow_Ups__r != null && q.Follow_Ups__r.size()> 0) {
            List <Survey_Answer__c> follow_ups = new List <Survey_Answer__c> ();

            for (Survey_Question__c fuq: q.Follow_Ups__r) {
                Survey_Answer__c fua = new Survey_Answer__c();
                fua.Survey_Question__c = fuq.Id;
                fua.Survey_Response__c = srId;
                fua.Follows_Up__c = a.Id;
                follow_ups.add(fua);
            }
            insert follow_ups;
            a = getAnswer(a.Id);
        }

        return a;
    }

    public static List <SurveyEntry> getEntries(LoadResponseInput inputs) {
        List <SurveyEntry> SEs = new List <SurveyEntry> ();

        List <Survey_Question_Assignment__c> qas = getAssignments(inputs);
        List <Survey_Question__c> qs = getQuestions(qas);
        List <Survey_Answer__c> ans = getAnswers(qs, inputs.srId);

        for (Survey_Question_Assignment__c qa: qas) {
            Survey_Question__c q = findQuestion(qs, qa.Survey_Question__c);
            Survey_Answer__c a = findAnswer(ans, q, inputs.srId);
            SurveyEntry se = new SurveyEntry(q, qa, a);
            SEs.add(se);
        }
        return SEs;
    }
}