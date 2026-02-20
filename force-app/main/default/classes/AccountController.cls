public with sharing class AccountController {
  public static void createRelatedRecord(List<Account> accounts) {
    for (Account account : accounts) {
      if (
        (account?.AccountNumber.length() == 14 &&
        !Utils.validaCNPJ(account.AccountNumber)) ||
        !Utils.validaCPF(account.AccountNumber)
      ) {
        account.addError('Número do cliente é inválido');

        
      }
    }

    List<Account> partnerAccounts = new List<Account>();
    List<Account> finalCostumerAccounts = new List<Account>();

    for (Account account : accounts) {
      if (account.RecordTypeId == AccountSelector.PARCEIRO_RECORD_TYPE_ID) {
        partnerAccounts.add(account);
      }

      if (
        account.RecordTypeId == AccountSelector.CONSUMIDOR_FINAL_RECORD_TYPE_ID
      ) {
        finalCostumerAccounts.add(account);
      }
    }

    if (!partnerAccounts.isEmpty()) {
      List<Opportunity> opps = new List<Opportunity>();

      for (Account account : partnerAccounts) {
        Opportunity opp = new Opportunity();
        opp.Name = account.Name + ' - opp Parceiro';
        opp.CloseDate = Date.today().addDays(30);
        opp.StageName = 'Qualification';
        opp.AccountId = account.Id;
        opps.add(opp);
      }

      insert opps;
    }

    if (!finalCostumerAccounts.isEmpty()) {
      List<Task> tasks = new List<Task>();

      for (Account account : finalCostumerAccounts) {
        Task task = new Task();
        task.Subject = 'Consumidor Final';
        task.WhatId = account.Id;
        task.Status = 'Not Started';
        task.Priority = 'Normal';
        tasks.add(task);
      }

      insert tasks;
    }
  }
}