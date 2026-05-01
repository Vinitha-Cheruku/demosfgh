public with sharing class AccountClass {
	@AuraEnabled(cacheable = true)
    public static Integer GetAccounts() {
		List<Account> AccountList = [Select id from Account];
		return AccountList.size();
    }
}