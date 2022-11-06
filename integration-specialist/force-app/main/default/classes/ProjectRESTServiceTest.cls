@isTest
private class ProjectRESTServiceTest {

  @IsTest
  private static void positivePostProjectDataTest() {
    Opportunity oppo = new Opportunity();
    oppo.Name = 'Super Project';
    oppo.StageName = 'Prospecting';
    oppo.CloseDate = Date.newInstance(2022, 10, 10);
    insert oppo;

    String ProjectRef = '12345';
    String ProjectName = 'New Project';
    String OpportunityId = oppo.Id;
    Date StartDate = Date.newInstance(2022, 10, 10);
    Date EndDate = Date.newInstance(2022, 11, 10);
    Double Amount = 15000;
    String Status = 'Running';

    Test.startTest();
    
    String requestStatus = ProjectRESTService.postProjectData(ProjectRef, ProjectName, OpportunityId, StartDate, EndDate, Amount, Status);
    
    System.assertEquals('In progress', [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity].DeliveryInstallationStatus__c);
    System.assertEquals(1, [SELECT Id FROM Project__c].size());
    System.assertEquals('OK', requestStatus);

    Test.stopTest();
  }

  @IsTest
  private static void negativePostProjectDataTest() {
    String ProjectRef2 = '12345';
    String ProjectName2 = 'New Project';
    String OpportunityId2 = '0067Q00000C6x0dQAD';
    Date StartDate2 = Date.newInstance(2022, 10, 10);
    Date EndDate2 = Date.newInstance(2022, 11, 10);
    Double Amount2 = 15000;
    String Status2 = 'Running';

    Test.startTest();
    
    String requestStatus2 = ProjectRESTService.postProjectData(ProjectRef2, ProjectName2, OpportunityId2, StartDate2, EndDate2, Amount2, Status2);

    System.assertEquals(0, [SELECT Id FROM Opportunity].size());
    System.assertEquals(0, [SELECT Id FROM Project__c].size());
    System.assertNotEquals('OK', requestStatus2);

    Test.stopTest();
  }
}