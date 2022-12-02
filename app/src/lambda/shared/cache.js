/**
 * @class Cache
 * @summary: Basic cache to be shared across invocations of the lambda handler. This will save time
 * In only needing to get items out of the cache as needed vs every invocation saving time and cost
 */
 module.exports = class Cache {
    /**
     * 
     * @param {number} refreshTime - Time in ms for how long before an item in cache is considered too old to use
     */
    constructor(refreshTime, secretsManager) {
      this.cache = {};
      this.refreshTime = refreshTime;
      this.secretsManager = secretsManager;
    }
  
    /**
     * @summary - Retrieves an item out of aws secrets manager if the key is too old or not in the cache.
     * @param {string} key - Name of the secret in AWS secrets manager to pull 
     * @returns Promise<String> - Promise containing the secret even if the value is resolved
     */
    getSecret(key) {
      if (!this.cache[key] || this.cache[key].time + this.refreshTime > new Date().valueOf()) {
        this.cache[key] = {
          time: new Date().valueOf(),
          value: this.secretsManager.getSecretValue({SecretId: key}).promise().then(secret => {
            if ('SecretString' in secret) {
              return secret.SecretString;
            }
            let buff = Buffer.from(secret.SecretBinary, 'base64');
            return buff.toString('ascii');
          })
        };
      }
      return this.cache[key].value;
    }
  
    /**
     * @summary - Manually clears an item from the cache
     * @param {string} key - Key of the cache item to clear
     */
    clearCacheItem(key) {
      if (this.cache[key])
        delete this.cache[key];
    }
  
    /**
     * @summary - Resets the entire cache
     */
    clearCache() {
      delete this.cache;
      this.cache = {};
    }
  }
  