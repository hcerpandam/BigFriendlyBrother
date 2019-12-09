/**
 * @file        EnergyLeadDigitalSendCCImplementation.apxc
 * @author      Héctor Cervera
 * @date        09/12/2019
 * @description Visualforce controller for retrieve fraud Records from BFBSafe
 */

public Class ControllerGetFraudRecords {
    
    public ApexPages.StandardSetController setCon;

    public ControllerGetFraudRecords(ApexPages.StandardSetController controller) {
        setCon = controller;
    }

    public void retrieveRecords(){  
        List <TimeRecordControl__c> lstRecords = CalloutsManagement.doGet50KFirstContentious();
        insert lstRecords;
    }
}