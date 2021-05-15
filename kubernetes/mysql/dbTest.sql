ALTER USER 'root'@'localhost' IDENTIFIED BY 'password' PASSWORD EXPIRE NEVER;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
ALTER USER 'root'@'%' IDENTIFIED BY 'password' PASSWORD EXPIRE NEVER;
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'password';

CREATE DATABASE IF NOT EXISTS test;

CREATE TABLE IF NOT EXISTS test.people (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60),
	surname VARCHAR(60)
);

INSERT INTO test.people (id, name, surname) VALUES (1, 'nico', 'vinci');
INSERT INTO test.people (name, surname) VALUES ('marcello', 'meschini');
