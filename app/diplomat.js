module.exports = {
	getServiceInstance: (name) => {
		const address = {
			host: '',
			port: '',
			username: '',
			secret: '',
		};
		if( name == (process.env.DB_SCHEMA_REGISTRY || 'db-schema_registry') ) {
			address.host = process.env.DB_SCHEMA_REGISTRY || 'onepick.store.mysql';
			address.port = process.env.DB_SCHEMA_REGISTRY_PORT || '3306';
			address.username = process.env.DB_SCHEMA_REGISTRY_USERNAME || 'onepick';
			address.secret = process.env.DB_SCHEMA_REGISTRY_PASSWORD || '0neP!ck';
			console.log('Will login into mysql' + JSON.stringify(address));
			return address;
		}
		if( name == process.env.REDIS_SCHEMA_REGISTRY || 'schema-registry-redis' ) {
			address.host = process.env.REDIS_SCHEMA_REGISTRY || 'onepick.store.redis';
			address.port = process.env.REDIS_SCHEMA_REGISTRY_PORT || '6379';
			console.log('Will login into redis' + JSON.stringify(address));
			return address;
		}

		throw new Error(`undefined service ${name} networkaddress`);
	},
};
