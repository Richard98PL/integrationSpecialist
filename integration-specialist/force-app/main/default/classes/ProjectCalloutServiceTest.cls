@isTest
private class ProjectCalloutServiceTest {
  @TestSetup
  static void makeData(){
    ServiceTokens__c st = new ServiceTokens__c();
    st.Name = 'ProjectServiceToken';
    st.Token__c = 'example_token';
    insert st;

    Account acc = new Account();
    acc.Name = 'Allegro';
    insert acc;

    Opportunity oppo = new Opportunity();
    oppo.Name = 'Super Project';
    oppo.Type = 'New Project';
    oppo.Amount = 15000;
    oppo.StageName = 'Prospecting';
    oppo.CloseDate = Date.newInstance(2022, 10, 10);
    oppo.AccountId = acc.Id;
    insert oppo;
  }

  @IsTest
  private static void positiveCalloutTest() {
    Opportunity opp = [SELECT Id, StageName FROM Opportunity];

    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
    update new Opportunity(Id = opp.Id, StageName = 'Closed Won');

    Test.stopTest();

    System.assertEquals('Submitted Project', [SELECT Id, StageName FROM Opportunity].StageName);
  }

  @IsTest
  private static void negativeCalloutTest() {
    Opportunity opp = [SELECT Id, StageName FROM Opportunity];

    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
    update new Opportunity(Id = opp.Id, StageName = 'Closed Won');

    Test.stopTest();

    System.assertEquals('Resubmit Project', [SELECT Id, StageName FROM Opportunity].StageName);
  }
}