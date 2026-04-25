
CREATE TABLE sales_analytics.categories (
	category_id serial4 NOT NULL,
	category_name text NOT NULL,
	parent_category_id int4 NULL,
	CONSTRAINT categories_pkey PRIMARY KEY (category_id),
	CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category_id) REFERENCES sales_analytics.categories(category_id)
);

CREATE TABLE sales_analytics.channels (
	channel_id serial4 NOT NULL,
	channel_name text NOT NULL,
	CONSTRAINT channels_channel_name_key UNIQUE (channel_name),
	CONSTRAINT channels_pkey PRIMARY KEY (channel_id)
);

CREATE TABLE sales_analytics.customers (
	customer_id serial4 NOT NULL,
	first_name text NOT NULL,
	last_name text NOT NULL,
	email text NOT NULL,
	country text NULL,
	city text NULL,
	signup_date date DEFAULT CURRENT_DATE NOT NULL,
	CONSTRAINT customers_email_key UNIQUE (email),
	CONSTRAINT customers_pkey PRIMARY KEY (customer_id)
);


CREATE TABLE sales_analytics.order_items (
	order_item_id serial4 NOT NULL,
	order_id int4 NOT NULL,
	product_id int4 NOT NULL,
	quantity int4 NOT NULL,
	price numeric(10, 2) NOT NULL,
	CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id),
	CONSTRAINT order_items_price_check CHECK ((price >= (0)::numeric)),
	CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);
CREATE INDEX idx_order_items_product ON sales_analytics.order_items USING btree (product_id);

ALTER TABLE sales_analytics.order_items ADD CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES sales_analytics.orders(order_id);
ALTER TABLE sales_analytics.order_items ADD CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES sales_analytics.products(product_id);


CREATE TABLE sales_analytics.orders (
	order_id serial4 NOT NULL,
	customer_id int4 NOT NULL,
	order_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	status text DEFAULT 'created'::text NOT NULL,
	channel_id int4 NULL,
	region_id int4 NULL,
	CONSTRAINT orders_pkey PRIMARY KEY (order_id)
);



ALTER TABLE sales_analytics.orders ADD CONSTRAINT fk_orders_channel FOREIGN KEY (channel_id) REFERENCES sales_analytics.channels(channel_id);
ALTER TABLE sales_analytics.orders ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES sales_analytics.customers(customer_id);
ALTER TABLE sales_analytics.orders ADD CONSTRAINT fk_orders_region FOREIGN KEY (region_id) REFERENCES sales_analytics.regions(region_id);


CREATE TABLE sales_analytics.payments (
	payment_id serial4 NOT NULL,
	order_id int4 NOT NULL,
	payment_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	amount numeric(10, 2) NOT NULL,
	payment_method text NOT NULL,
	status text DEFAULT 'pending'::text NOT NULL,
	CONSTRAINT payments_amount_check CHECK ((amount >= (0)::numeric)),
	CONSTRAINT payments_pkey PRIMARY KEY (payment_id)
);



ALTER TABLE sales_analytics.payments ADD CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES sales_analytics.orders(order_id);


CREATE TABLE sales_analytics.product_reviews (
	review_id serial4 NOT NULL,
	product_id int4 NOT NULL,
	customer_id int4 NOT NULL,
	rating int4 NOT NULL,
	review_text text NULL,
	review_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT product_reviews_pkey PRIMARY KEY (review_id),
	CONSTRAINT product_reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);



ALTER TABLE sales_analytics.product_reviews ADD CONSTRAINT fk_reviews_customer FOREIGN KEY (customer_id) REFERENCES sales_analytics.customers(customer_id);
ALTER TABLE sales_analytics.product_reviews ADD CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES sales_analytics.products(product_id);


CREATE TABLE sales_analytics.products (
	product_id serial4 NOT NULL,
	product_name text NOT NULL,
	category_id int4 NOT NULL,
	price numeric(10, 2) NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT products_pkey PRIMARY KEY (product_id),
	CONSTRAINT products_price_check CHECK ((price >= (0)::numeric))
);



ALTER TABLE sales_analytics.products ADD CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES sales_analytics.categories(category_id);


CREATE TABLE sales_analytics.regions (
	region_id serial4 NOT NULL,
	country text NOT NULL,
	city text NOT NULL,
	CONSTRAINT regions_pkey PRIMARY KEY (region_id)
);


CREATE TABLE sales_analytics."returns" (
	return_id serial4 NOT NULL,
	order_item_id int4 NOT NULL,
	return_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	return_quantity int4 NOT NULL,
	return_amount numeric(10, 2) NOT NULL,
	CONSTRAINT returns_pkey PRIMARY KEY (return_id),
	CONSTRAINT returns_return_amount_check CHECK ((return_amount >= (0)::numeric)),
	CONSTRAINT returns_return_quantity_check CHECK ((return_quantity > 0))
);


ALTER TABLE sales_analytics."returns" ADD CONSTRAINT fk_returns_order_item FOREIGN KEY (order_item_id) REFERENCES sales_analytics.order_items(order_item_id);
