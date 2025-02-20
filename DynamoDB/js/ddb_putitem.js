// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');
// Set the region 
AWS.config.update({region: 'ap-northeast-2'});
// Create the DynamoDB service objectvar
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
var params = {TableName: 'CUSTOMER_LIST',
  Item: {'CUSTOMER_ID': {N: '001'},
    'CUSTOMER_NAME': {S: 'Richard Roe'}
  }
};
// Call DynamoDB to add the item to the table
ddb.putItem(params, function(err, data) {if(err) {console.log("Error", err);
  } else{console.log("Success", data);
  }
});