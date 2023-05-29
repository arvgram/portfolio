DROP TABLE IF EXISTS raw_materials_warehouse;
CREATE TABLE raw_materials_warehouse (
	ingredient_name 	TEXT,
	amount_stored 		INT,
	last_delivery		DATETIME,


	PRIMARY KEY 		(ingredient_name),
	FOREIGN KEY 		(ingredient_name) REFERENCES ingredients(ingredient_name)
);

DROP TABLE IF EXISTS ingredients;
CREATE TABLE ingredients (
    ingredient_name 		TEXT,
    unit 			TEXT,


    PRIMARY KEY 		(ingredient_name)
);

DROP TABLE IF EXISTS ingredient_list;
CREATE TABLE ingredient_list (
    cookie_name 		TEXT,
    ingredient_name 		TEXT,
    amount 			INT,

    PRIMARY KEY (cookie_name, ingredient_name),
    FOREIGN KEY (cookie_name) REFERENCES recipes(cookie_name),
    FOREIGN KEY (ingredient_name) REFERENCES ingredients(ingredient_name)
);

DROP TABLE IF EXISTS recipes;
CREATE TABLE recipes (
    cookie_name 	TEXT,
    
    PRIMARY KEY (cookie_name)
);

DROP TABLE IF EXISTS pallets;
CREATE TABLE pallets (
    pallet_id 		TEXT DEFAULT (lower(hex(randomblob(16)))),
    cookie_name 	TEXT,
    production_date 	DATE,
    status 		INT,
    delivery_id 	TEXT,
    
    PRIMARY KEY (pallet_id),
    FOREIGN KEY (cookie_name) REFERENCES recipes(cookie_name),
    FOREIGN KEY (delivery_id) REFERENCES deliveries(delivery_id)
);

DROP TABLE IF EXISTS deliveries;
CREATE TABLE deliveries (
    delivery_id 	TEXT,
    delivery_date 	DATE,
    delivery_time 	TIME,
    customer_name 	TEXT,

    PRIMARY KEY (delivery_id),
    FOREIGN KEY (customer_name) REFERENCES customer(customer_name)
);

DROP TABLE IF EXISTS delivery_specs;
CREATE TABLE delivery_specs (
    cookie_name 	TEXT,
    delivery_id 	TEXT,
    nbr_of_pallets 	INT,

    PRIMARY KEY (cookie_name, delivery_id),
    FOREIGN KEY (cookie_name) REFERENCES recipes(cookie_name),
    FOREIGN KEY (delivery_id) REFERENCES deliveries(delivery_id)
);

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_name 	TEXT,
    customer_address 	TEXT,

    PRIMARY KEY (customer_name)	
);

DROP TRIGGER IF EXISTS consume_ingredients;
CREATE TRIGGER consume_ingredients
BEFORE INSERT ON pallets
BEGIN
	UPDATE raw_materials_warehouse
	SET amount_stored = amount_stored-54*(
		SELECT amount
		FROM ingredient_list
		WHERE ingredient_list.cookie_name = NEW.cookie_name
			AND raw_materials_warehouse.ingredient_name = ingredient_list.ingredient_name		
			
	)
	WHERE ingredient_name IN (
		SELECT ingredient_name
		FROM ingredient_list
		WHERE ingredient_list.cookie_name = NEW.cookie_name
	);
END;


DROP TRIGGER IF EXISTS sufficient_amount;
CREATE TRIGGER sufficient_amount
BEFORE UPDATE ON raw_materials_warehouse
WHEN NEW.amount_stored < 0
BEGIN 
	SELECT RAISE(ROLLBACK, "Not enough ingredients");
END;




