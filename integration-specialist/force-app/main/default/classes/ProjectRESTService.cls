@RestResource(urlMapping='/project/*')
global with sharing class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId,
        Date StartDate, Date EndDate, Double Amount, String Status) {
            // System.debug(ProjectRef);
            // System.debug(ProjectName);
            // System.debug(OpportunityId);
            // System.debug(StartDate);
            // System.debug(EndDate);
            // System.debug(Amount);
            // System.debug(Status);

            Project__c newProject = new Project__c();
            newProject.Name = ProjectName;
            newProject.Opportunity__c = OpportunityId;
            newProject.Start_Date__c = StartDate;
            newProject.End_Date__c = EndDate;
            newProject.Billable_Amount__c = Amount;
            newProject.Status__c = Status;
            newProject.ProjectRef__c = ProjectRef;

            Savepoint sp = Database.setSavepoint();
            
            try {
                update new Opportunity(Id = OpportunityId, DeliveryInstallationStatus__c = 'In progress');
                upsert newProject ProjectRef__c;
                return 'OK';
            } catch (Exception exc) {
                Database.rollback(sp);
                return exc.getMessage();
            }
    }
}