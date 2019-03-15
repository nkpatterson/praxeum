Data Repository Details
=======================

Cosmos DB
---------
You will need to create a Database in the Cosmos DB account. You can call it whatever you want but make sure to update the AzureCosmosDbOptions:DatabaseId app setting in both the web app and function app to reflect the name.

You will also need to manually create 5 Cosmos DB Collections within the account, as follows.

| Collection Name       | Partition Key |
| ----------------------| --------------|
| leaderboards          | /id           |
| contestlearners       | /contestId    |
| contests              | /id           |
| learners              | /id           |
| courses               | /id           |

Storage Account
---------------
All storage containers objects (queues, tables, etc.) are created automatically from the application. No need to manually create anything.

