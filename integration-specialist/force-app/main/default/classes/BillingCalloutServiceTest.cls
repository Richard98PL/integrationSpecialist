@isTest
private class BillingCalloutServiceTest {

  @TestSetup
  static void makeData(){
    ServiceCredentials__c cred = new ServiceCredentials__c();
    cred.Name = 'BillingServiceCredential';
    cred.Username__c = 'name';
    cred.Password__c = 'pass';
    insert cred;

    Opportunity oppo = new Opportunity();
    oppo.Name = 'Super Project';
    oppo.StageName = 'Prospecting';
    oppo.CloseDate = Date.newInstance(2022, 10, 10);
    insert oppo;

    Project__c proj = new Project__c();
    proj.Name = 'New Project';
    proj.Opportunity__c = oppo.Id;
    proj.Status__c = 'Running';
    proj.Billable_Amount__c = 1500;
    proj.ProjectRef__c = 'abc';
    insert proj;
  }

  @IsTest
  private static void positiveCalloutTest() {
    Project__c proj = [SELECT Id, Status__c FROM Project__c];

    Test.startTest();

    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
    update new Project__c(Id = proj.Id, Status__c = 'Billable');

    Test.stopTest();

    System.assertEquals('Billed', [SELECT Id, Status__c FROM Project__c].Status__c);
  }

  @IsTest
  private static void negativeCalloutTest() {
    Project__c proj = [SELECT Id, Status__c FROM Project__c];

    Test.startTest();

    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
    update new Project__c(Id = proj.Id, Status__c = 'Billable');

    Test.stopTest();

    System.assertEquals('Billable', [SELECT Id, Status__c FROM Project__c].Status__c);
  }
}