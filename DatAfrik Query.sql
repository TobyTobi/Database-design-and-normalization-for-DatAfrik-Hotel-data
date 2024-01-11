/*
The database has been created graphically using the "New Database" tool. The original data table can be found here:
https://datafrik.co/#/datasets
 */

-- View the data table
SELECT * FROM Hotel


/*
Now, the data table has to be normalized to reduce data redundancy and improve performance. To do this, 6 relations will be created to
contain information on:

- Customers
- Bookings
- Hotels
- Banks
- Payment
- Payment modes
*/


-- Customers table
CREATE TABLE Customers (
	CustomerId NVARCHAR(255) PRIMARY KEY,
	Age INT,
	Gender NVARCHAR(255),
	Origin_Country NVARCHAR(255),
	State NVARCHAR(255),
	Location NVARCHAR(255)
	);


-- Bookings table
CREATE TABLE Bookings (
	BookingId NVARCHAR(255) PRIMARY KEY,
	CustomerId NVARCHAR(255),
	Booking_Date DATE,
	Booking_Time TIME,
	HotelId FLOAT,
	Number_of_people INT,
	Check_in_date DATE,
	Check_out_date DATE,
	Rooms INT,
	Number_of_days INT,
	PaymentId INT,
	Destination_Country NVARCHAR(255),
	Destination_City NVARCHAR(255),
	);

-- Hotels table
CREATE TABLE Hotels (
	HotelId INT IDENTITY(10000, 10) PRIMARY KEY,
	Hotel_name NVARCHAR(255),
	Rating FLOAT
	);


-- Banks table
CREATE TABLE Banks (
	BankId INT IDENTITY(100, 1) PRIMARY KEY,
	Bank_name NVARCHAR(255)
	);


-- Payments table
CREATE TABLE Payments (
	PaymentId INT IDENTITY(100000, 1) PRIMARY KEY,
	BookingId NVARCHAR(255),
	BankId INT,
	ModeId INT,
	Booking_Price FLOAT,
	Discount FLOAT,
	GST FLOAT,
	Profit_margin FLOAT
	);


-- Payment_modes table
CREATE TABLE Payment_Modes (
	ModeId INT IDENTITY(10, 1) PRIMARY KEY,
	Mode NVARCHAR(255)
	);


-- For Customers table
INSERT INTO Customers (
	CustomerId,
	Age,
	Gender,
	Origin_Country,
	State,
	Location
	)
SELECT [Customer ID],
	Age,
	Gender,
	[Origin Country],
	State,
	Location
FROM Hotel;


-- For Bookings Table
INSERT INTO Bookings (
    BookingId,
    CustomerId,
    Booking_Date,
    Booking_Time,
    Number_of_people,
    Check_in_date,
    Check_out_date,
    Rooms,
    Number_of_days
)
SELECT
    [Booking ID],
    [Customer ID],
    [Date of Booking],
    Time,
    [No# Of People],
    [Check-in date],
    [Check-Out Date],
    Rooms,
    DATEDIFF(dd, [Check-in date], [Check-Out Date]) +
	DATEDIFF(mm, [Check-in date], [Check-Out Date]) * 30 +
	DATEDIFF(yy, [Check-in date], [Check-Out Date]) * 365
FROM
    Hotel;


-- For Hotels Table
INSERT INTO Hotels (
	Hotel_name,
	Rating
	)
SELECT
    MAX([Hotel Name]),
    ROUND(AVG([Hotel Rating]), 2)
FROM
    Hotel
GROUP BY
    [Hotel Name];


/*
Now that the HotelIds have been created, insert the HotelIds to the original table
*/


-- For Banks Table
INSERT INTO Banks (
	Bank_Name
	)
SELECT DISTINCT [Bank Name]
FROM Hotel;


-- Insert BankId values into Hotel table
UPDATE Hotel
SET Hotel.BankId = Banks.BankId
FROM Banks
WHERE Banks.Bank_name = Hotel.[Bank Name];


-- For Payment_Modes Table
INSERT INTO Payment_Modes (
	Mode
	)
SELECT DISTINCT [Payment Mode]
FROM Hotel;


-- Create new columns called ModeId
ALTER TABLE Hotel
ADD ModeId INT


-- Insert ModeId values into Hotel table
UPDATE Hotel
SET Hotel.ModeId = Payment_Modes.ModeId
FROM Payment_Modes
WHERE Payment_Modes.Mode = Hotel.[Payment Mode];

-- For Payments Table
INSERT INTO Payments (
	BookingId
	)
SELECT
    BookingId
FROM
	Bookings;

-- Insert data into Payments table
UPDATE Payments
SET Payments.ModeId = Hotel.ModeId,
	Payments.BankId = Hotel.BankId,
	Payments.Booking_Price = Hotel.[Booking Price(SGD)],
	Payments.Discount = Hotel.Discount,
	Payments.GST = Hotel.GST,
	Payments.Profit_margin = Hotel.[Profit Margin]
FROM Hotel
WHERE Payments.BookingId = Hotel.[Booking ID];


-- Create HotelId Column for Hotel table
ALTER TABLE Hotel
ADD HotelId INT


-- Set the values of HotelId from Hotels table
UPDATE Hotel
SET Hotel.HotelId = Hotels.HotelId
FROM Hotels
WHERE Hotels.Hotel_name = Hotel.[Hotel Name];


-- For the second batch for Bookings
UPDATE B
SET B.HotelId = H.HotelId,
    B.PaymentId = P.PaymentId,
    B.Destination_city = H.[Destination City],
    B.Destination_Country = H.[Destination Country]
FROM Bookings B
JOIN Hotel H ON B.BookingId = H.[Booking ID]
JOIN Payments P ON B.BookingId = P.BookingId;


/*
The tables have been created and populated with data from the original table. The equivalent database diagram has now been 
created to show the relationships between tables.

Analysis can now begin to answer the business questions
*/


-- I noticed a negative age value in the Customers table
SELECT MIN(Age) AS Youngest,
	MAX(Age) AS Oldest
FROM Customers;


/* There is a negative age value, hence, rows with negative age values have to be dropped. The entries have to be dropped in
related tables as well  */

DELETE FROM Bookings
WHERE CustomerId IN (SELECT CustomerId FROM Customers WHERE Age < 0);

DELETE FROM Customers
WHERE Age < 0

-- View the tables
SELECT * FROM Banks
SELECT * FROM Bookings
SELECT * FROM Customers
SELECT * FROM Hotels
SELECT * FROM Payment_Modes
SELECT * FROM Payments
