public class BillingCalloutService {
    //Implement business and callout logic methods here
    public static void callBillingService(Map<Id, Project__c> projectsMap) {
        List<Project__c> projectToBill = new List<Project__c>();

        for(Id projectId : projectsMap.keySet()) {
            if(projectsMap.get(projectId).Status__c == 'Billable') {
                projectToBill.add(projectsMap.get(projectId));
            }
        }

        if(!projectToBill.isEmpty()) {
            generateInvoiceCallout(projectToBill.get(0).ProjectRef__c, projectToBill.get(0).Billable_Amount__c);
        }

    }

    @future(callout=true)
    public static void generateInvoiceCallout(String projectRef, Decimal BillingAmount) {
        BillingServiceProxy.project projectToBill = new BillingServiceProxy.project();
        projectToBill.username = ServiceCredentials__c.getValues('BillingServiceCredential').Username__c;
        projectToBill.password = ServiceCredentials__c.getValues('BillingServiceCredential').Password__c;
        projectToBill.projectid = projectRef;
        projectToBill.billAmount = BillingAmount;

        BillingServiceProxy.InvoicesPortSoap11 billProjectIns = new BillingServiceProxy.InvoicesPortSoap11();
        String status = billProjectIns.billProject(projectToBill);

        if(status == 'ok') {
            upsert new Project__c(ProjectRef__c = projectRef, Status__c = 'Billed') ProjectRef__c;
        } else {
            System.debug('Unfortunately: ' + status);
        }
    }
}