// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');
// Set the region 
AWS.config.update({region: 'ap-northeast-2'});
// Create the DynamoDB service object
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
var params = {TableName: 'CUSTOMER_LIST',  
  Key: {
    'CUSTOMER_ID': {N: '001'},
          'CUSTOMER_NAME': {S: 'Richard Roe'}
  }
};
// Call DynamoDB to delete the item from the table
ddb.deleteItem(params, function(err, data) {if(err) {console.log("Error", err);
  } else{console.log("Success", data);
  }
});
