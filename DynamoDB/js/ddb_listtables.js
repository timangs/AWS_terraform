// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');
// Set the region 
AWS.config.update({region: 'ap-northeast-2'});
// Create the DynamoDB service object
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
// Call DynamoDB to retrieve the list of tables
ddb.listTables({Limit: 10}, function(err, data) {if(err) {console.log("Error", err.code);
  } else{console.log("Table names are ", data.TableNames);
  }
});
