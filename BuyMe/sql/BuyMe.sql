DROP DATABASE IF EXISTS BuyMe;
CREATE DATABASE BuyMe;
USE BuyMe;

CREATE TABLE admin (
	admin_id int primary key,
    admin_name varchar(50),
    admin_password varchar(25),
    email varchar(50)
);
    
CREATE TABLE report (
	report_id int primary key,
	date_gened DATE,
    total_earnings float,
    best_selling_item varchar(50),
    best_selling_user varchar(50)
);
    
CREATE TABLE customer_representative (
	rep_id int primary key,
    rep_name varchar(50),
    email varchar(50),
    rep_password varchar(25)
);
        
CREATE TABLE user (
	user_id int primary key,
    username varchar(25),
    user_password varchar(25),
    email varchar(50),
    full_name varchar(50),
    address varchar(50),
    phone_num char(10),
    user_role varchar(25)
);
    
CREATE TABLE alert (
	alert_id int,
	user_id int,
    keyword varchar(10),
    min_price float,
    max_price float,
    primary key (user_id, alert_id),
    foreign key (user_id) references user(user_id)
);
    
CREATE TABLE item (
	item_id int primary key,
    title varchar(50),
    item_description TEXT,
    item_condition varchar(25),
	date_posted DATE
);
    
CREATE TABLE auction (
	auction_id int,
    item_id int,
    start_price float,
    min_price float,
    increment float,
    start_time DATETIME,
    end_time DATETIME,
    auction_status varchar(10),
    primary key (auction_id, item_id),
    foreign key (item_id) references item(item_id)
);
    
CREATE TABLE bid (
	bid_id int,
    auction_id int,
    item_id int,
    user_id int,
    amount float,
    time DATETIME,
    primary key (user_id, item_id, auction_id, bid_id),
    foreign key (user_id) references user(user_id),
    foreign key (auction_id, item_id) references auction(auction_id, item_id)
);
    
CREATE TABLE generates (
	admin_id int,
    report_id int,
    primary key (admin_id, report_id),
    foreign key (admin_id) references admin(admin_id),
    foreign key (report_id) references report(report_id)
);
    
CREATE TABLE creates (
	admin_id int,
    rep_id int,
    primary key (admin_id, rep_id),
    foreign key (admin_id) references admin(admin_id),
    foreign key (rep_id) references customer_representative(rep_id)
);
    
CREATE TABLE assists (
	rep_id int,
    user_id int,
    primary key (rep_id, user_id),
    foreign key (rep_id) references customer_representative(rep_id),
    foreign key (user_id) references user(user_id)
);
    
CREATE TABLE buys (
	user_id int,
    item_id int primary key,
    foreign key (user_id) references user(user_id),
    foreign key (item_id) references item(item_id)
);
    
CREATE TABLE sells (
	user_id int,
    item_id int,
    primary key (item_id),
    foreign key (user_id) references user(user_id),
    foreign key (item_id) references item(item_id)
);
    
CREATE TABLE category (
	category_id int primary key,
    cat_name varchar(50),
    cat_description TEXT
);
    
CREATE TABLE sub_category (
	sub_category_id int primary key,
    category_id int,
    sub_name VARCHAR(50),
    sub_description TEXT,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

INSERT INTO admin (admin_id, admin_name, admin_password, email)
VALUES (1, 'Jaiveer', 'root', 'jaiveer.singh2913@gmail.com');
