const mysql = require('promise-mysql');
const builder = require('xmlbuilder');
const db_config = {
  host   : process.env['endpoint'],
  user   : process.env['user'],
  password : process.env['password'],
  database : process.env['db']
};
const table = process.env['table'];
const pool = mysql.createPool(db_config);
 
exports.handler = async (event) => {
  let response = {};
  let connection;
  try {
    connection = await (await pool).getConnection();
    console.log("Connected");
  } catch (e) {
    console.log(e);
    response = formatError(e);
    return response;
  }
  console.log("Starting query ...");
  try {
    const sql = buildSql(event);
    const results = await connection.query(sql);
    const xml = buildXml(results);
    response = formatResponse(xml);
  } catch (e) {
    console.log(e);
    response = formatError(e);
  } finally {
    await connection.release();
    console.log("Connection released");
    return response;
  }
 
};
 
function buildSql (event) {
  let conditions = new Array();
  if (event.queryStringParameters && event.queryStringParameters.query) {
    const query = event.queryStringParameters.query;
    conditions.push(`display LIKE '%${query}%'`);
  }
  if (event.queryStringParameters && event.queryStringParameters.parent) {
    const parentItemId = event.queryStringParameters.parent;
    conditions.push(`value LIKE '${parentItemId}%'`);
  }
  let sql = `SELECT * FROM ${table}`;
  const condNum = conditions.length;
  if (condNum >= 1) {
    sql += ` WHERE ${conditions[0]}`;
    if (condNum == 2) {
      sql += ` AND ${conditions[1]}`;
    }
  } else if (event.multiValueQueryStringParameters && event.multiValueQueryStringParameters.values) {
    const values = event.multiValueQueryStringParameters.values;
    let valuesStr = `'${values[0]}'`;
    for (let i = 1; i < values.length; i++) {
      valuesStr += `, '${values[i]}'`;
    }
    sql += ` WHERE value IN (${valuesStr})`;
  }
  sql += ';';
  return sql;
}
 
function buildXml (results) {
  const resultsNum = results.length;
  let root = builder.create('items');
  for (let i = 0; i < resultsNum; i++) {
    let item = root.ele('item');
    item.att('value', results[i].value);
    item.att('display', results[i].display);
  }
  const xml = root.end({ pretty: true});
  return xml;
}
 
function formatResponse (body) {
  const response = {
    "statusCode": 200,
    "headers": {
      "Content-Type": "text/plain; charset=utf-8"
    },
    "isBase64Encoded": false,
    "body": body,
  };
  return response;
}
 
function formatError (error) {
  const response = {
    "statusCode": error.statusCode,
    "headers": {
      "Content-Type": "text/plain",
      "x-amzn-ErrorType": error.code
    },
    "isBase64Encoded": false,
    "body": error.code + ": " + error.message
  };
  return response;
}
