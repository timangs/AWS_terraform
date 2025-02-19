USE sqlDB;
CREATE TABLE userTBL
( 
userID CHAR(8) NOT NULL PRIMARY KEY,
name NVARCHAR(10) NOT NULL,
birthYear INT NOT NULL,
email CHAR(30),
mobile CHAR(20),
mDate DATE
);

userTBL (userID, name, birthYear, email, mobile, mDate) VALUES (?, ?, ?, ?, ?, ?)";

INSERT INTO userTBL VALUES ('LSG', '1승기', 1987, 'test1@co.com', '0111111111', '2008-8-8');
INSERT INTO userTBL VALUES ('KBS', '2범수', 1979, 'test2@co.com', '0112222222', '2012-4-4');
INSERT INTO userTBL VALUES ('KKH', '3경호', 1971, 'test3@co.com', '0193333333', '2007-7-7');
INSERT INTO userTBL VALUES ('JYP', '4용필', 1950, 'test4@co.com', '0114444444', '2009-4-4');