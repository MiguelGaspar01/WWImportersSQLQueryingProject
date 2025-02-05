**Schema**
```sql

CREATE TABLE [Dimension].[City] (
    [City Key] INT PRIMARY KEY,
    [WWI City ID] INT NOT NULL,
    [City] NVARCHAR(50) NOT NULL,
    [State Province] NVARCHAR(50) NOT NULL,
    [Country] NVARCHAR(60) NOT NULL,
    [Continent] NVARCHAR(30) NOT NULL,
    [Sales Territory] NVARCHAR(50) NOT NULL,
    [Region] NVARCHAR(30) NOT NULL,
    [Subregion] NVARCHAR(30) NOT NULL,
    [Location] GEOGRAPHY NULL,
    [Latest Recorded Population] BIGINT NOT NULL,
    [Valid From] DATETIME2(7) NOT NULL,
    [Valid To] DATETIME2(7) NOT NULL,
    [Lineage Key] INT NOT NULL
);

CREATE TABLE [Dimension].[Customer] (
    [Customer Key] INT PRIMARY KEY,
    [WWI Customer ID] INT NOT NULL,
    [Customer] NVARCHAR(100) NOT NULL,
    [Bill To Customer] NVARCHAR(100) NOT NULL,
    [Category] NVARCHAR(50) NOT NULL,
    [Buying Group] NVARCHAR(50) NOT NULL,
    [Primary Contact] NVARCHAR(50) NOT NULL,
    [Postal Code] NVARCHAR(10) NOT NULL,
    [Valid From] DATETIME2(7) NOT NULL,
    [Valid To] DATETIME2(7) NOT NULL,
    [Lineage Key] INT NOT NULL
);

CREATE TABLE [Dimension].[Date] (
    [Date] DATE PRIMARY KEY,
    [Day Number] INT NOT NULL,
    [Day] NVARCHAR(10) NOT NULL,
    [Month] NVARCHAR(10) NOT NULL,
    [Short Month] NVARCHAR(3) NOT NULL,
    [Calendar Month Number] INT NOT NULL,
    [Calendar Year] INT NOT NULL,
    [Fiscal Year] INT NOT NULL,
    [ISO Week Number] INT NOT NULL
);

CREATE TABLE [Dimension].[Employee] (
    [Employee Key] INT PRIMARY KEY,
    [WWI Employee ID] INT NOT NULL,
    [Employee] NVARCHAR(50) NOT NULL,
    [Preferred Name] NVARCHAR(50) NOT NULL,
    [Is Salesperson] BIT NOT NULL,
    [Photo] VARBINARY(MAX) NULL,
    [Valid From] DATETIME2(7) NOT NULL,
    [Valid To] DATETIME2(7) NOT NULL,
    [Lineage Key] INT NOT NULL
);


CREATE TABLE [Dimension].[Stock Item] (
    [Stock Item Key] INT PRIMARY KEY,
    [WWI Stock Item ID] INT NOT NULL,
    [Stock Item] NVARCHAR(100) NOT NULL,
    [Color] NVARCHAR(20) NOT NULL,
    [Selling Package] NVARCHAR(50) NOT NULL,
    [Buying Package] NVARCHAR(50) NOT NULL,
    [Brand] NVARCHAR(50) NOT NULL,
    [Size] NVARCHAR(20) NOT NULL,
    [Lead Time Days] INT NOT NULL,
    [Quantity Per Outer] INT NOT NULL,
    [Tax Rate] DECIMAL(18, 3) NOT NULL,
    [Unit Price] DECIMAL(18, 2) NOT NULL,
    [Recommended Retail Price] DECIMAL(18, 2) NULL,
    [Typical Weight Per Unit] DECIMAL(18, 3) NOT NULL,
    [Photo] VARBINARY(MAX) NULL,
    [Valid From] DATETIME2(7) NOT NULL,
    [Valid To] DATETIME2(7) NOT NULL,
    [Lineage Key] INT NOT NULL
);

CREATE TABLE [Fact].[Order] (
    [Order Key] BIGINT IDENTITY(1,1) PRIMARY KEY,
    [City Key] INT NOT NULL,
    [Customer Key] INT NOT NULL,
    [Stock Item Key] INT NOT NULL,
    [Order Date Key] DATE NOT NULL,
    [Salesperson Key] INT NOT NULL,
    [Quantity] INT NOT NULL,
    [Unit Price] DECIMAL(18, 2) NOT NULL,
    [Tax Rate] DECIMAL(18, 3) NOT NULL,
    [Total Excluding Tax] DECIMAL(18, 2) NOT NULL,
    [Tax Amount] DECIMAL(18, 2) NOT NULL,
    [Total Including Tax] DECIMAL(18, 2) NOT NULL,
    CONSTRAINT FK_Order_City FOREIGN KEY ([City Key]) REFERENCES [Dimension].[City]([City Key]),
    CONSTRAINT FK_Order_Customer FOREIGN KEY ([Customer Key]) REFERENCES [Dimension].[Customer]([Customer Key]),
    CONSTRAINT FK_Order_StockItem FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item]([Stock Item Key]),
    CONSTRAINT FK_Order_Employee FOREIGN KEY ([Salesperson Key]) REFERENCES [Dimension].[Employee]([Employee Key])
);


CREATE TABLE [Fact].[Sale] (
    [Sale Key] BIGINT IDENTITY(1,1) PRIMARY KEY,
    [City Key] INT NOT NULL,
    [Customer Key] INT NOT NULL,
    [Stock Item Key] INT NOT NULL,
    [Invoice Date Key] DATE NOT NULL,
    [Salesperson Key] INT NOT NULL,
    [Quantity] INT NOT NULL,
    [Unit Price] DECIMAL(18, 2) NOT NULL,
    [Tax Rate] DECIMAL(18, 3) NOT NULL,
    [Total Excluding Tax] DECIMAL(18, 2) NOT NULL,
    [Tax Amount] DECIMAL(18, 2) NOT NULL,
    [Profit] DECIMAL(18, 2) NOT NULL,
    [Total Including Tax] DECIMAL(18, 2) NOT NULL,
    CONSTRAINT FK_Sale_City FOREIGN KEY ([City Key]) REFERENCES [Dimension].[City]([City Key]),
    CONSTRAINT FK_Sale_Customer FOREIGN KEY ([Customer Key]) REFERENCES [Dimension].[Customer]([Customer Key]),
    CONSTRAINT FK_Sale_StockItem FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item]([Stock Item Key]),
    CONSTRAINT FK_Sale_Employee FOREIGN KEY ([Salesperson Key]) REFERENCES [Dimension].[Employee]([Employee Key])
);


CREATE TABLE [Fact].[Purchase] (
    [Purchase Key] BIGINT IDENTITY(1,1) PRIMARY KEY,
    [Date Key] DATE NOT NULL,
    [Supplier Key] INT NOT NULL,
    [Stock Item Key] INT NOT NULL,
    [Ordered Quantity] INT NOT NULL,
    [Received Quantity] INT NOT NULL,
    CONSTRAINT FK_Purchase_Supplier FOREIGN KEY ([Supplier Key]) REFERENCES [Dimension].[Supplier]([Supplier Key]),
    CONSTRAINT FK_Purchase_StockItem FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item]([Stock Item Key])
);

CREATE TABLE [Fact].[Stock Holding] (
    [Stock Holding Key] BIGINT IDENTITY(1,1) PRIMARY KEY,
    [Stock Item Key] INT NOT NULL,
    [Quantity On Hand] INT NOT NULL,
    [Last Cost Price] DECIMAL(18, 2) NOT NULL,
    [Reorder Level] INT NOT NULL,
    CONSTRAINT FK_StockHolding_StockItem FOREIGN KEY ([Stock Item Key]) REFERENCES [Dimension].[Stock Item]([Stock Item Key])
);

CREATE TABLE [Fact].[Transaction] (
    [Transaction Key] BIGINT IDENTITY(1,1) PRIMARY KEY,
    [Date Key] DATE NOT NULL,
    [Customer Key] INT NULL,
    [Supplier Key] INT NULL,
    [Total Excluding Tax] DECIMAL(18, 2) NOT NULL,
    [Tax Amount] DECIMAL(18, 2) NOT NULL,
    [Total Including Tax] DECIMAL(18, 2) NOT NULL,
    CONSTRAINT FK_Transaction_Customer FOREIGN KEY ([Customer Key]) REFERENCES [Dimension].[Customer]([Customer Key]),
    CONSTRAINT FK_Transaction_Supplier FOREIGN KEY ([Supplier Key]) REFERENCES [Dimension].[Supplier]([Supplier Key])
);
