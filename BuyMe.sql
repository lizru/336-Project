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
    
CREATE TABLE item (
	item_id int primary key,
    title varchar(50),
    item_description TEXT,
    item_condition varchar(25),
	date_posted DATE,
    sub_category_id int,
    make varchar(50),
    model varchar(50),
    year int,
    mileage int,
    color varchar(30),
    FOREIGN KEY (sub_category_id) REFERENCES sub_category(sub_category_id)
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
    is_autobid boolean DEFAULT false,
    autobid_limit float,
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

CREATE TABLE question (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(100),
    question_text TEXT,
    date_posted DATETIME,
    status VARCHAR(20) DEFAULT 'open',
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

CREATE TABLE reply (
    reply_id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT,
    rep_id INT,
    reply_text TEXT,
    date_replied DATETIME,
    FOREIGN KEY (question_id) REFERENCES question(question_id),
    FOREIGN KEY (rep_id) REFERENCES customer_representative(rep_id)
);

CREATE TABLE bid_alert (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    auction_id INT,
    item_id INT,
    alert_type VARCHAR(20),
    message TEXT,
    new_bid_amount DECIMAL(10,2),
    date_created DATETIME,
    is_read BOOLEAN DEFAULT false,
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (auction_id, item_id) REFERENCES auction(auction_id, item_id)
);

INSERT INTO admin (admin_id, admin_name, admin_password, email)
VALUES (1, 'Jaiveer', 'root', 'jaiveer.singh2913@gmail.com');

INSERT INTO customer_representative (rep_id, rep_name, email, rep_password)
VALUES (1, 'James Booth', 'james.booth@gmail.com', 'password');

INSERT INTO category (category_id, cat_name, cat_description)
VALUES (1, 'Vehicles', 'All types of vehicles');

INSERT INTO sub_category (sub_category_id, category_id, sub_name, sub_description)
VALUES 
(1, 1, 'Cars', 'Passenger cars and sedans'),
(2, 1, 'Trucks', 'Pickup trucks'),
(3, 1, 'Motorcycles', 'Motorcycles and scooters');

INSERT INTO user (user_id, username, user_password, email, full_name, address, phone_num, user_role)
VALUES 
(1, 'seller1', 'pass123', 'seller1@example.com', 'John Seller', '123 Main St', '5551234567', 'seller'),
(2, 'buyer1', 'pass123', 'buyer1@example.com', 'Jane Buyer', '456 Oak Ave', '5559876543', 'buyer'),
(3, 'seller2', 'pass123', 'seller2@example.com', 'Mike Dealer', '789 Market St', '5551112222', 'seller'),
(4, 'buyer2', 'pass123', 'buyer2@example.com', 'Sarah Smith', '321 Pine Rd', '5553334444', 'buyer'),
(5, 'seller3', 'pass123', 'seller3@example.com', 'Auto Sales LLC', '555 Commerce Dr', '5555556666', 'seller'),
(6, 'buyer3', 'pass123', 'buyer3@example.com', 'Tom Johnson', '654 Maple Ave', '5557778888', 'buyer'),
(7, 'buyer4', 'pass123', 'buyer4@example.com', 'Lisa Brown', '987 Cedar Ln', '5559990000', 'buyer'),
(8, 'seller4', 'pass123', 'seller4@example.com', 'Premium Motors', '111 Auto Plaza', '5552223333', 'seller'),
(9, 'buyer5', 'pass123', 'buyer5@example.com', 'David Wilson', '222 Oak St', '5554445555', 'buyer'),
(10, 'seller5', 'pass123', 'seller5@example.com', 'Best Vehicles Co', '333 Trade Way', '5556667777', 'seller'),
(11, 'buyer6', 'pass123', 'buyer6@example.com', 'Emily Davis', '444 Birch Ct', '5558889999', 'buyer'),
(12, 'buyer7', 'pass123', 'buyer7@example.com', 'Chris Martinez', '555 Willow Dr', '5551231234', 'buyer'),
(13, 'seller6', 'pass123', 'seller6@example.com', 'Elite Autos', '666 Main Blvd', '5554564567', 'seller'),
(14, 'buyer8', 'pass123', 'buyer8@example.com', 'Amanda Garcia', '777 Elm Ave', '5557897890', 'buyer'),
(15, 'buyer9', 'pass123', 'buyer9@example.com', 'Robert Lee', '888 Park Pl', '5550120123', 'buyer');

INSERT INTO item (item_id, title, item_description, item_condition, date_posted, sub_category_id, make, model, year, mileage, color)
VALUES 
(1, '2020 Toyota Camry', 'Excellent condition, one owner, well maintained', 'Like New', CURDATE(), 1, 'Toyota', 'Camry', 2020, 35000, 'Silver'),
(2, '2018 Ford F-150', 'Heavy duty truck, towing package included', 'Used', CURDATE(), 2, 'Ford', 'F-150', 2018, 62000, 'Black'),
(3, '2021 Honda Civic', 'Sport model, low miles, like new', 'Like New', CURDATE(), 1, 'Honda', 'Civic', 2021, 18000, 'Blue'),
(4, '2019 Chevrolet Silverado', 'Work truck, bed liner installed', 'Used', CURDATE(), 2, 'Chevrolet', 'Silverado', 2019, 45000, 'White'),
(5, '2022 Yamaha YZF-R1', 'Sport bike, barely used, mint condition', 'Like New', CURDATE(), 3, 'Yamaha', 'YZF-R1', 2022, 2500, 'Red'),
(6, '2017 BMW 3 Series', 'Luxury sedan, loaded with features', 'Used', CURDATE(), 1, 'BMW', '3 Series', 2017, 48000, 'Black'),
(7, '2020 Toyota Tacoma', 'Off-road package, excellent condition', 'Like New', CURDATE(), 2, 'Toyota', 'Tacoma', 2020, 28000, 'Gray'),
(8, '2023 Honda CBR600RR', 'Nearly new sport bike, garage kept', 'Like New', CURDATE(), 3, 'Honda', 'CBR600RR', 2023, 1200, 'Blue'),
(9, '2019 Chevrolet Malibu', 'Family sedan, great gas mileage', 'Used', CURDATE(), 1, 'Chevrolet', 'Malibu', 2019, 38000, 'White'),
(10, '2021 Ford Ranger', 'Mid-size truck, perfect for daily use', 'Like New', CURDATE(), 2, 'Ford', 'Ranger', 2021, 22000, 'Red'),
(11, '2020 Kawasaki Ninja 650', 'Great beginner sport bike', 'Used', CURDATE(), 3, 'Kawasaki', 'Ninja 650', 2020, 8500, 'Green'),
(12, '2018 Honda Accord', 'Reliable sedan, well maintained', 'Used', CURDATE(), 1, 'Honda', 'Accord', 2018, 52000, 'Silver');

INSERT INTO auction (auction_id, item_id, start_price, min_price, increment, start_time, end_time, auction_status)
VALUES 
(1, 1, 15000.00, 18000.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(2, 2, 12000.00, 14000.00, 150.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(3, 3, 18000.00, 20000.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(4, 4, 16000.00, 18500.00, 200.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(5, 5, 8000.00, 9500.00, 50.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(6, 6, 14000.00, 16000.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(7, 7, 22000.00, 24000.00, 150.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(8, 8, 9000.00, 10500.00, 75.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(9, 9, 13000.00, 15000.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(10, 10, 19000.00, 21000.00, 150.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(11, 11, 5500.00, 6500.00, 50.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active'),
(12, 12, 12500.00, 14500.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 10 MINUTE), 'active');

INSERT INTO sells (user_id, item_id)
VALUES 
(1, 1),
(1, 2),
(3, 3),
(3, 4),
(5, 5),
(5, 6),
(8, 7),
(8, 8),
(10, 9),
(10, 10),
(13, 11),
(13, 12);

INSERT INTO bid (bid_id, auction_id, item_id, user_id, amount, time, is_autobid, autobid_limit)
VALUES 
(1, 1, 1, 2, 15100.00, DATE_SUB(NOW(), INTERVAL 8 MINUTE), false, NULL),
(2, 1, 1, 4, 15200.00, DATE_SUB(NOW(), INTERVAL 7 MINUTE), false, NULL),
(3, 1, 1, 2, 15300.00, DATE_SUB(NOW(), INTERVAL 6 MINUTE), false, NULL),
(4, 1, 1, 6, 16000.00, DATE_SUB(NOW(), INTERVAL 5 MINUTE), false, NULL),
(5, 1, 1, 2, 18100.00, DATE_SUB(NOW(), INTERVAL 3 MINUTE), false, NULL),
(6, 2, 2, 4, 12150.00, DATE_SUB(NOW(), INTERVAL 7 MINUTE), false, NULL),
(7, 2, 2, 6, 14150.00, DATE_SUB(NOW(), INTERVAL 4 MINUTE), false, NULL),
(8, 3, 3, 9, 18100.00, DATE_SUB(NOW(), INTERVAL 8 MINUTE), false, NULL),
(9, 3, 3, 11, 18200.00, DATE_SUB(NOW(), INTERVAL 6 MINUTE), false, NULL),
(10, 3, 3, 9, 19500.00, DATE_SUB(NOW(), INTERVAL 4 MINUTE), false, NULL),
(11, 4, 4, 7, 16200.00, DATE_SUB(NOW(), INTERVAL 7 MINUTE), false, NULL),
(12, 4, 4, 12, 18600.00, DATE_SUB(NOW(), INTERVAL 3 MINUTE), false, NULL),
(13, 5, 5, 14, 8050.00, DATE_SUB(NOW(), INTERVAL 8 MINUTE), false, NULL),
(14, 5, 5, 15, 8100.00, DATE_SUB(NOW(), INTERVAL 7 MINUTE), false, NULL),
(15, 5, 5, 14, 9600.00, DATE_SUB(NOW(), INTERVAL 2 MINUTE), false, NULL),
(16, 7, 7, 4, 22150.00, DATE_SUB(NOW(), INTERVAL 8 MINUTE), false, NULL),
(17, 7, 7, 9, 22300.00, DATE_SUB(NOW(), INTERVAL 7 MINUTE), false, NULL),
(18, 7, 7, 4, 24150.00, DATE_SUB(NOW(), INTERVAL 2 MINUTE), false, NULL),
(19, 8, 8, 15, 9075.00, DATE_SUB(NOW(), INTERVAL 6 MINUTE), false, NULL),
(20, 8, 8, 11, 9150.00, DATE_SUB(NOW(), INTERVAL 5 MINUTE), false, NULL),
(21, 8, 8, 15, 10575.00, DATE_SUB(NOW(), INTERVAL 1 MINUTE), false, NULL),
(22, 9, 9, 11, 13100.00, DATE_SUB(NOW(), INTERVAL 7 MINUTE), false, NULL),
(23, 9, 9, 14, 13200.00, DATE_SUB(NOW(), INTERVAL 6 MINUTE), false, NULL),
(24, 9, 9, 11, 15100.00, DATE_SUB(NOW(), INTERVAL 3 MINUTE), false, NULL),
(25, 10, 10, 7, 19150.00, DATE_SUB(NOW(), INTERVAL 8 MINUTE), false, NULL),
(26, 10, 10, 12, 19300.00, DATE_SUB(NOW(), INTERVAL 7 MINUTE), false, NULL),
(27, 10, 10, 7, 21150.00, DATE_SUB(NOW(), INTERVAL 2 MINUTE), false, NULL),
(28, 11, 11, 9, 5550.00, DATE_SUB(NOW(), INTERVAL 7 MINUTE), false, NULL),
(29, 11, 11, 15, 5600.00, DATE_SUB(NOW(), INTERVAL 6 MINUTE), false, NULL),
(30, 11, 11, 9, 6550.00, DATE_SUB(NOW(), INTERVAL 4 MINUTE), false, NULL),
(31, 12, 12, 6, 12600.00, DATE_SUB(NOW(), INTERVAL 8 MINUTE), false, NULL),
(32, 12, 12, 11, 12700.00, DATE_SUB(NOW(), INTERVAL 6 MINUTE), false, NULL),
(33, 12, 12, 6, 14200.00, DATE_SUB(NOW(), INTERVAL 5 MINUTE), false, NULL);