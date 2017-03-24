# db_connector
The db_connectors provides two tools for database connection: connection_pool_manager and db_manager.
The connection_pool_manager provides a java tool for pool connection and the db_manager provides a tool in Jolie for database management  
# db_manager
Jolie Tool for the database management.  
## 1. Introduction  
The db_manager tool has the goal of providing the jolie services in order to simplify the management operations of a database from an already pre-existing.  
## 2. Folder Structure 
The structure of the tool folder is the following:  
* lib 
* config  
* public  
* client
* db_services
* main_table_generator.ol 
### Lib Folder  
The lib folder contains the driver of the database necessary to connect with them
### Config Folder
The config folder contains the location to use in main_table_generatorr.ol, the default location is ``` socket://localhost:9100 ``` and the configuration file for createDbService.
### Public Folder 
The public folder contains two subfolder: interfaces and types; with the interfaces and the types necessary to ```main_table_generator.ol```.  
Inside the subfolder inteface there is ```TableGeneratorInterface.iol```, that implement the interface and the type request for createDbService, createService4Table and createType.The service createDbService sn the only used by user to create the operations services for database.  
The subfolder types contains all the types necessary to the services of ```main_table_generator.ol```.
### Client Folder
This folder conatins the jolie file createDatabaseService.ol used to call the service createDbService of ```main_table_generator.ol```. 
### Server Folder 
The creation of the services is done by the ```main_table_generator.ol```. This file implement the services **createDbService**, **createService4Table**, **createType**.
The tool is divided in two parts:
* **Automatic part**  
  create specific service for the management database operation(INSERT, UPDATE, DELETE and SELECT)
* **Custom part**  
  allows the user to create personalized services.  
### Db_services Folder
This folder contains the handler services for the database. 

## 3. Creation of the database services
The creation of a services for the database is simply, the file createDatabaseService.ol inside folder client give a template for the user to implement the database services.The connection information are passed with the type of the request defined inside the
TableGeneratorInterface.ol.  
```
/*TableGeneratorInterface.iol*/

type CreateDbServiceRequest: void {
  .host: string
  .driver: string
  .port: int
  .database: string
  .username: string
  .password: string
  .table_schema?: string     //used only if driver=postgresql
}
``` 
We examine in details the fields of the request type: 
* **host** The reference host where data are extracted(localhost) 
* **driver** The driver of the database 
* **port** The port where the user would be connect 
* **username** Username to log into the database  
* **password** Password to log into the database  
For the creation of services for the database, the user must first start the server and then the client. Then, the folder of services for the database are created.	
### 3.1 How to create a service for database	
**STEP 1**	
	
Run the main_table_generator.ol	
	
**STEP 2**	
	
Initialize the configuration information of CreateDbServiceRequest of file createDbService.ol inside the folder client.	
	
**STEP 3**	
	
Run the createDbService.ol	
```
/*The configuration information of the type CreateDbServiceRequest*/

with( request ) {
    .host = "localhost";
    .driver = "postgresql";
    .port = 5432;
    .database = "store";
    .table_schema = "public";
    .username = "postgres";
    .password = "postgres"
  };
``` 

## 4. Using the services for the database
To understand how use the services for the database, we introduce the folder structure: 
* automatic_service: contains all the services for the database operation(INSERT, SELECT, UPDATE, DELETE)
* custom_service: contains the customizable part by the user
* lib: contains the database driver
* config.ini: this file configure the information to connect with the database
* locations.iol: this file contains a variable constant with the location of the service
* main_"nameDB".iol: this is the core of the tools where custom and automatic part are called
### 4.1 Automatic service
This part of code contains all the operation services for the database.The implementation of services are inside the jolie file main_automatic_"nameDB".ol.The operation are the following: 
* create 
* update  
* remove 
* get 
  
**CREATE**  
The operation is used to insert a row in a table inside the database.To use this operation, it's important understand the type of the request.We show an example of table 'user' of database 'store'. 
```
type createuserRequest:void {
	.CodiceFiscale:string
	.Nome?:string
	.Cognome?:string
	.Email?:string
}
``` 
The request type contains the fields of table user.The primary key or generally NOT NULL value don't have the question mark, beacuse they must write to insert the row in a table.  
**UPDATE**  
This operation is used to change one or more rows in a table.The request type does not have only the fields of table, but also has the filter field.  
```
type updateuserRequest:void {
	.CodiceFiscale?:string
	.Nome?:string
	.Cognome?:string
	.Email?:string
	.filter*:FilterType
}
``` 
**REMOVE**  
The remove operation eliminates the rows inside the table, this operation has only filter field.
```
type updateuserRequest:void {
	.CodiceFiscale?:string
	.Nome?:string
	.Cognome?:string
	.Email?:string
	.filter*:FilterType
}
```	
**GET**	
	
The get operation is used to get the rows with the condition of filter field.	
```
type getuserRequest:void {
	.filter*:FilterType
}
``` 
**FILTER**
```
/*storeDatabaseCommonType.iol*/

type ExpressionFilterType: void {
      .eq?: bool
      .gt?: bool
      .lt?: bool
      .gteq?: bool
      .lteq?: bool
      .noteq?: bool
    }

    type FilterType: void {
      //.parentesis: bool
      .column_name: string
      .column_value: any
      .expression: ExpressionFilterType
      .and_operator?:  bool
      .or_operator?: bool
    }
``` 
The filter field is important to define the where part of our query. First of all we examine the FilterType: 
* column_name: name of the column of the expression
* column_value: value of the column
* expression: the operator used to check the value, this is an ExpressionFilterType 
* and_operator: we define this field only if we want to concatenate another expression, in this case an AND operator  
* or_operator: we define this field only if we want to concatenate another expression, in this case an OR operator	
	
The ExpressionFilterType define the operator:	
* eq: "="	
* gt: ">"	
* lt: "<"	
* gteq: ">="	
* lteq: "<="	
* noteq: "!="	
	
**EXAMPLE**	
	
The where clause "WHERE categoria = 'Farina' AND quantita >= 12", can be described:	
```
getprodottoRequest.filter.column_name = "categoria";
getprodottoRequest.filter.column_value = "Farina";
getprodottoRequest.filter.expression.eq = true;
getprodottoRequest.filter.and_operator = true;
getprodottoRequest.filter[1].column_name = "quantita";
getprodottoRequest.filter[1].column_value = 12;
getprodottoRequest.filter[1].expression.gteq = true;
``` 
### 4.2 Custom Service  
The custom service allows the user to create custom operation and interface.The custom service provide the user files to define the operation (main_custom_"nameDB".ol) and where define the interface and custom type(custom_interface_"nameDB".iol). 	
### 4.3 How to use the operations of tool
*EXAMPLE* with store database	
1. **Create a jolie file and import the interfaces "includes.iol" and "locations.iol"**	
```
include "../db_services/store_handler_service/automatic_service/public/interfaces/includes.iol"
include "../db_services/store_handler_service/locations.iol"
``` 
2. **Create the outputPort for calling the operation**	
```
outputPort Test {
  Location: store
  Protocol: sodep
  Interfaces: userInterface, ordineInterface, prodottoInterface
}
```	
3. **Initialize the main writing the type of request and calling the operation**	

```
createuserRequest.CodiceFiscale = "1";
createuserRequest.Nome = "NameUser";
createuserRequest.Cognome = "SurnameUser";
createuserRequest.Email = "user@mail.com";
createuser@Test(createuserRequest)();
```	
4. **Run the main_store.ol; the server embed the automatic service and custom service**	
5. **Run the jolie file created in the client folder**
