@RestResource(urlMapping='/cgcloud/account/*')
global with sharing class CGCloudProcess {

    // =========================
    // WRAPPER CLASS
    // =========================
    global class AccountRequest {
        public String name;
        public String accountNumber;
        public String accountTemplateId;
        public String email;
        public String firstName;
        public String lastName;
        public String mobile;
    }

    // =========================
    // CREATE ACCOUNT (POST)
    // =========================
    @HttpPost
    global static void createAccount() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {

            AccountRequest ar = (AccountRequest) JSON.deserialize(
                req.requestBody.toString(),
                AccountRequest.class
            );

            if(String.isBlank(ar.name) ||
               String.isBlank(ar.accountNumber) ||
               String.isBlank(ar.accountTemplateId)) {

                res.statusCode = 400;
                res.responseBody = Blob.valueOf(
                    'Name, Account Number and Account Template are required.'
                );
                return;
            }

            Account acc = new Account();
            acc.Name = ar.name;
            acc.cgcloud__Account_Number__c = ar.accountNumber;
            acc.cgcloud__Account_Template__c = ar.accountTemplateId;

            if(ar.email != null)
                acc.cgcloud__Account_Email__c = ar.email;

            insert acc;

            // OPTIONAL CONTACT CREATION
            if(ar.firstName != null || ar.lastName != null){

                Contact con = new Contact();
                con.FirstName = ar.firstName;
                con.LastName = ar.lastName;
                con.MobilePhone = ar.mobile;
                con.AccountId = acc.Id;

                insert con;
            }

            res.statusCode = 201;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String, String>{
                    'message' => 'Retail Store Created Successfully',
                    'accountId' => acc.Id
                })
            );

        } catch (Exception e) {

            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }


    // =========================
    // UPDATE ACCOUNT (PATCH)
    // =========================
    @HttpPatch
    global static void updateAccount() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {

            String accId = req.requestURI.substring(
                req.requestURI.lastIndexOf('/') + 1
            );

            Account acc = [
                SELECT Id, Name, cgcloud__Account_Number__c,
                       cgcloud__Account_Template__c,
                       cgcloud__Account_Email__c
                FROM Account
                WHERE Id = :accId
                LIMIT 1
            ];

            AccountRequest ar = (AccountRequest) JSON.deserialize(
                req.requestBody.toString(),
                AccountRequest.class
            );

            if(ar.name != null)
                acc.Name = ar.name;

            if(ar.accountNumber != null)
                acc.cgcloud__Account_Number__c = ar.accountNumber;

            if(ar.accountTemplateId != null)
                acc.cgcloud__Account_Template__c = ar.accountTemplateId;

            if(ar.email != null)
                acc.cgcloud__Account_Email__c = ar.email;

            update acc;

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String,String>{
                    'message' => 'Account Updated Successfully'
                })
            );

        } catch (QueryException q) {

            res.statusCode = 404;
            res.responseBody = Blob.valueOf('Account not found');

        } catch (Exception e) {

            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }


    // =========================
    // DELETE ACCOUNT
    // =========================
    @HttpDelete
    global static void deleteAccount() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {

            String accId = req.requestURI.substring(
                req.requestURI.lastIndexOf('/') + 1
            );

            Account acc = [
                SELECT Id
                FROM Account
                WHERE Id = :accId
                LIMIT 1
            ];

            delete acc;

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String,String>{
                    'message' => 'Account Deleted Successfully'
                })
            );

        } catch (QueryException q) {

            res.statusCode = 404;
            res.responseBody = Blob.valueOf('Account not found');

        } catch (Exception e) {

            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
        }
    }
}