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

INSERT INTO admin (admin_id, admin_name, admin_password, email)
VALUES (1, 'Jaiveer', 'root', 'jaiveer.singh2913@gmail.com');

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

INSERT INTO item (item_id, title, item_description, item_condition, date_posted, sub_category_id)
VALUES 
(1, '2020 Toyota Camry', 'Make: Toyota | Model: Camry | Year: 2020 | Mileage: 35000 | Color: Silver | Excellent condition, one owner, well maintained', 'Like New', CURDATE(), 1),
(2, '2018 Ford F-150', 'Make: Ford | Model: F-150 | Year: 2018 | Mileage: 62000 | Color: Black | Heavy duty truck, towing package included', 'Used', CURDATE(), 2),
(3, '2021 Honda Civic', 'Make: Honda | Model: Civic | Year: 2021 | Mileage: 18000 | Color: Blue | Sport model, low miles, like new', 'Like New', CURDATE(), 1),
(4, '2019 Chevrolet Silverado', 'Make: Chevrolet | Model: Silverado | Year: 2019 | Mileage: 45000 | Color: White | Work truck, bed liner installed', 'Used', CURDATE(), 2),
(5, '2022 Yamaha YZF-R1', 'Make: Yamaha | Model: YZF-R1 | Year: 2022 | Mileage: 2500 | Color: Red | Sport bike, barely used, mint condition', 'Like New', CURDATE(), 3),
(6, '2017 BMW 3 Series', 'Make: BMW | Model: 3 Series | Year: 2017 | Mileage: 48000 | Color: Black | Luxury sedan, loaded with features', 'Used', CURDATE(), 1),
(7, '2020 Toyota Tacoma', 'Make: Toyota | Model: Tacoma | Year: 2020 | Mileage: 28000 | Color: Gray | Off-road package, excellent condition', 'Like New', CURDATE(), 2),
(8, '2023 Honda CBR600RR', 'Make: Honda | Model: CBR600RR | Year: 2023 | Mileage: 1200 | Color: Blue | Nearly new sport bike, garage kept', 'Like New', CURDATE(), 3),
(9, '2019 Chevrolet Malibu', 'Make: Chevrolet | Model: Malibu | Year: 2019 | Mileage: 38000 | Color: White | Family sedan, great gas mileage', 'Used', CURDATE(), 1),
(10, '2021 Ford Ranger', 'Make: Ford | Model: Ranger | Year: 2021 | Mileage: 22000 | Color: Red | Mid-size truck, perfect for daily use', 'Like New', CURDATE(), 2),
(11, '2020 Kawasaki Ninja 650', 'Make: Kawasaki | Model: Ninja 650 | Year: 2020 | Mileage: 8500 | Color: Green | Great beginner sport bike', 'Used', CURDATE(), 3),
(12, '2018 Honda Accord', 'Make: Honda | Model: Accord | Year: 2018 | Mileage: 52000 | Color: Silver | Reliable sedan, well maintained', 'Used', CURDATE(), 1);

INSERT INTO auction (auction_id, item_id, start_price, min_price, increment, start_time, end_time, auction_status)
VALUES 
(1, 1, 15000.00, 18000.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(2, 2, 12000.00, 14000.00, 150.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(3, 3, 18000.00, 20000.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(4, 4, 16000.00, 18500.00, 200.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(5, 5, 8000.00, 9500.00, 50.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(6, 6, 14000.00, 16000.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(7, 7, 22000.00, 24000.00, 150.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(8, 8, 9000.00, 10500.00, 75.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(9, 9, 13000.00, 15000.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(10, 10, 19000.00, 21000.00, 150.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(11, 11, 5500.00, 6500.00, 50.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active'),
(12, 12, 12500.00, 14500.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'active');

INSERT INTO sells (user_id, item_id)
VALUES 
(1, 1),   -- seller1: Toyota Camry
(1, 2),   -- seller1: Ford F-150
(3, 3),   -- seller2: Honda Civic
(3, 4),   -- seller2: Chevy Silverado
(5, 5),   -- seller3: Yamaha motorcycle
(5, 6),   -- seller3: BMW 3 Series
(8, 7),   -- seller4: Toyota Tacoma
(8, 8),   -- seller4: Honda CBR
(10, 9),  -- seller5: Chevy Malibu
(10, 10), -- seller5: Ford Ranger
(13, 11), -- seller6: Kawasaki Ninja
(13, 12); -- seller6: Honda Accord