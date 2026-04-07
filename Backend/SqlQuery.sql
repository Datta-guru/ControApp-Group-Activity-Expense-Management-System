CREATE DATABASE contro_app;
USE contro_app;
CREATE TABLE users (
 id INT AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(100),
 email VARCHAR(100) UNIQUE,
 password_hash TEXT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE user_upi (
 id INT AUTO_INCREMENT PRIMARY KEY,
 user_id INT,
 upi_id VARCHAR(100),
 upi_name VARCHAR(100),
 FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE TABLE members (
 id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100),
 phone VARCHAR(20) UNIQUE
);
CREATE TABLE contro (
 id INT AUTO_INCREMENT PRIMARY KEY,
 user_id INT,
 contro_name VARCHAR(100),
 amount INT,
 upi_id INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(id),
 FOREIGN KEY (upi_id) REFERENCES user_upi(id)
);
CREATE TABLE contro_members (
 id INT AUTO_INCREMENT PRIMARY KEY,
 contro_id INT,
 member_id INT,
 status VARCHAR(20) DEFAULT 'Pending',
 FOREIGN KEY (contro_id) REFERENCES contro(id),
 FOREIGN KEY (member_id) REFERENCES members(id)
);
CREATE TABLE payments (
 id INT AUTO_INCREMENT PRIMARY KEY,
 contro_member_id INT,
 amount INT,
 transaction_id VARCHAR(100),
 screenshot_path TEXT,
 verified BOOLEAN,
 FOREIGN KEY (contro_member_id) REFERENCES contro_members(id)
);