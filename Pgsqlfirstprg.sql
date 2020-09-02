CREATE TABLE accounts (
	user_id serial PRIMARY KEY,
	username CHAR ( 50 ) UNIQUE NOT NULL,
	email VARCHAR ( 255 ) UNIQUE NOT NULL,
	cust_id int,
	
	created_on TIMESTAMP,
	a BIT(3), b BIT VARYING(5),
        last_login TIMESTAMP 
);


	
insert into accounts(username,email,cust_id, a, b)
values('Bob2','bob22@dsg.com',1000,'001','01');

CREATE TABLE Fortrigger(
   triggerID INT NOT NULL,
   Trigger_email varchar(255)  NOT NULL
);

CREATE OR REPLACE FUNCTION Trigger_function() RETURNS TRIGGER AS $example_table$
   BEGIN
      INSERT INTO Fortrigger(triggerID, trigger_email) VALUES (new.user_id, new.email);
      RETURN NEW;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER example_trigger AFTER INSERT ON ACCOUNTS
FOR EACH ROW EXECUTE PROCEDURE Trigger_function();

insert into accounts(username,email,cust_id, a, b)
values('Bob3','bob33@dsg.com',1000,'101','01');

UPDATE accounts
SET created_on = '12/12/12',
    last_login = '10/10/10'
WHERE user_id = 6;

select * from accounts;

select * from Fortrigger;