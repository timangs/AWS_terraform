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