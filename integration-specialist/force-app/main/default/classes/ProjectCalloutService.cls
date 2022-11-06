public class ProjectCalloutService {
    //Complete the implementation for business and callout logic
    @InvocableMethod(label='Post Opportunity To PMS')
	public static void postOpportunityToPMS(List<Id> OpportunityIds){
        System.enqueueJob(new QueueablePMSCall(OpportunityIds));
    }
    
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {
        public List<Id> oppoIds;
        public String oppoJson;

        public QueueablePMSCall(List<Id> OpportunityIds) {
            oppoIds = OpportunityIds;
        }

        public void execute(QueueableContext context) {
            oppoJson = createJson(oppoIds);
            postNewProject(oppoJson, oppoIds);
        }

        public String createJson(List<Id> OpportunityIds) {
            Opportunity oppo = [SELECT Id, Name, Account.Name, CloseDate, Amount 
                                FROM Opportunity
                                WHERE Id = :OpportunityIds.get(0)];
    
            OpportunityWrapper oppoWrap = new OpportunityWrapper();
            oppoWrap.opportunityId = oppo.Id;
            oppoWrap.opportunityName = oppo.Name;
            oppoWrap.accountName = oppo.Account.Name;
            oppoWrap.closeDate = String.valueOf(oppo.CloseDate);
            oppoWrap.amount = oppo.Amount;
    
            return JSON.serialize(oppoWrap);
        }  

        public HttpResponse postNewProject(String oppoJson, List<Id> oppoIds) {
            // ServiceTokens__c serviceToken = ServiceTokens__c.getValues('ProjectServiceToken');
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
    
            request.setEndpoint('callout:ProjectService');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Token', ServiceTokens__c.getInstance('ProjectServiceToken').Token__c);

            request.setBody(oppoJson);
    
            HttpResponse response = http.send(request);
    
            if(response.getStatusCode() == 201) {
                System.debug(response.getBody());
                update new Opportunity(Id = oppoIds.get(0), StageName = 'Submitted Project');
            } else {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug(response.getBody());
                System.debug(response);
                update new Opportunity(Id = oppoIds.get(0), StageName = 'Resubmit Project');
            }
    
            return response;
        }
    }

    public class OpportunityWrapper {
        public String opportunityId;
        public String opportunityName;
        public String accountName;
        public String closeDate;
        public Decimal amount;
    }
}

//ID jobID = System.enqueueJob(new AsyncExecutionExample());