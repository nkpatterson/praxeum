﻿using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Options;

namespace Praxeum.Data.Helpers
{
    public abstract class AzureCosmosDbRepository 
    {
        protected readonly IOptions<AzureCosmosDbOptions> _azureCosmosDbOptions;
        private static CosmosClient _cosmosClient;
        protected readonly CosmosDatabase _cosmosDatabase;

        public AzureCosmosDbRepository(
            IOptions<AzureCosmosDbOptions> azureCosmosDbOptions)
        {
            _azureCosmosDbOptions =
                azureCosmosDbOptions;

            if (_cosmosClient == null)
            {
                _cosmosClient =
                    new CosmosClient(
                        _azureCosmosDbOptions.Value.ConnectionString);
            }
            
            _cosmosDatabase = _cosmosClient.Databases[_azureCosmosDbOptions.Value.DatabaseId];
        }
    }
}
