CREATE PROCEDURE dbo.sp_Load_Data_Archive @sp_EXTRACTED_DATE DATE
AS
BEGIN
    /*=============================================
    -- Author: Yudhaveer V Ramdoyal     
    -- Created date: 23/05/2023 
    -- Description: This Stored Procedure is executed in 3 blocks.
    -- Block 1 ......
    
    Execute dbo.sp_Load_Data_Archive'2023-01-02'
    
    -- =============================================*/
    
    DROP TABLE IF EXISTS [#Temp1];
    DROP TABLE IF EXISTS [#Temp2];
    
    
    --Block 1 Removing Duplicates and converting to the proper data type
    SELECT DISTINCT 
        CAST([ID] AS NUMERIC(18, 0)) AS [ID],
        CAST([FIRST_NAME] AS NVARCHAR(50)) AS [FIRST_NAME],
        CAST([LAST_NAME] AS NVARCHAR(50)) AS [LAST_NAME],
        CAST([EMAIL] AS NVARCHAR(50)) AS [EMAIL],
        CAST([GENDER] AS NVARCHAR(50)) AS [GENDER],
        CAST([CARD_NUMBER] AS NVARCHAR(50)) AS [CARD_NUMBER],
        CAST([BALANCE] AS FLOAT) AS [BALANCE],
        CAST([CREDIT_LIMIT] AS FLOAT) AS [CREDIT_LIMIT],
        CAST([CARD_CURRENCY] AS NVARCHAR(3)) AS [CARD_CURRENCY],
        CAST([EXTRACTED_DATE] AS DATE) AS [EXTRACTED_DATE],
		DT_START,
		DT_END
    INTO #Temp1
    FROM [BankOne].[dbo].[CUSTOMER_CARDS_ARCHIVE] 
    WHERE [EXTRACTED_DATE] = @sp_EXTRACTED_DATE;
    
    
    --Block 2 Cleansing Data and removing white spaces
    SELECT 
        LTRIM(RTRIM([ID])) AS [ID],
        LTRIM(RTRIM([FIRST_NAME])) AS [FIRST_NAME],
        LTRIM(RTRIM([LAST_NAME])) AS [LAST_NAME],
        LTRIM(RTRIM([EMAIL])) AS [EMAIL],
        CASE 
            WHEN UPPER([GENDER]) LIKE '%FE%' THEN 'Female'
            WHEN UPPER([GENDER]) NOT LIKE '%FE%' THEN 'Male'
            ELSE [GENDER]
        END AS [GENDER],
        LTRIM(RTRIM([CARD_NUMBER])) AS [CARD_NUMBER],
        LTRIM(RTRIM([BALANCE])) AS [BALANCE],
        LTRIM(RTRIM([CREDIT_LIMIT])) AS [CREDIT_LIMIT],
        LTRIM(RTRIM([CARD_CURRENCY])) AS [CARD_CURRENCY],
        [EXTRACTED_DATE],
		DT_START,
		DT_END
    INTO #Temp2
    FROM #Temp1;
    
    
    --Block 3 Change Tracking
    BEGIN
        MERGE INTO #temp2 AS t0
        USING (
            SELECT *
            FROM (
                SELECT
                    ID,
                    FIRST_NAME,
                    LAST_NAME,
                    EMAIL,
                    GENDER,
                    CARD_NUMBER,
                    BALANCE,
                    CREDIT_LIMIT,
                    CARD_CURRENCY
                FROM
                    CUSTOMER_CARDS
                WHERE CAST(DT_END AS NVARCHAR(10)) = '9999-12-31'
            ) v
            WHERE EXISTS (
                SELECT 1
                FROM #temp2 t1
                WHERE 
                    v.ID = t1.ID AND 
                    (
                        ((v.FIRST_NAME <> t1.FIRST_NAME) OR ((v.FIRST_NAME IS NULL AND t1.FIRST_NAME IS NOT NULL) OR (v.FIRST_NAME IS NOT NULL AND t1.FIRST_NAME IS NULL))) OR
                        ((v.LAST_NAME <> t1.LAST_NAME) OR ((v.LAST_NAME IS NULL AND t1.LAST_NAME IS NOT NULL) OR (v.LAST_NAME IS NOT NULL AND t1.LAST_NAME IS NULL))) OR
                        ((v.EMAIL <> t1.EMAIL) OR ((v.EMAIL IS NULL AND t1.EMAIL IS NOT NULL) OR (v.EMAIL IS NOT NULL AND t1.EMAIL IS NULL))) OR
                        ((v.GENDER <> t1.GENDER) OR ((v.GENDER IS NULL AND t1.GENDER IS NOT NULL) OR (v.GENDER IS NOT NULL AND t1.GENDER IS NULL))) OR
                        ((v.CARD_NUMBER <> t1.CARD_NUMBER) OR ((v.CARD_NUMBER IS NULL AND t1.CARD_NUMBER IS NOT NULL) OR (v.CARD_NUMBER IS NOT NULL AND t1.CARD_NUMBER IS NULL))) OR
                        ((v.BALANCE <> t1.BALANCE) OR ((v.BALANCE IS NULL AND t1.BALANCE IS NOT NULL) OR (v.BALANCE IS NOT NULL AND t1.BALANCE IS NULL))) OR
                        ((v.CREDIT_LIMIT <> t1.CREDIT_LIMIT) OR ((v.CREDIT_LIMIT IS NULL AND t1.CREDIT_LIMIT IS NOT NULL) OR (v.CREDIT_LIMIT IS NOT NULL AND t1.CREDIT_LIMIT IS NULL))) OR
                        ((v.CARD_CURRENCY <> t1.CARD_CURRENCY) OR ((v.CARD_CURRENCY IS NULL AND t1.CARD_CURRENCY IS NOT NULL) OR (v.CARD_CURRENCY IS NOT NULL AND t1.CARD_CURRENCY IS NULL)))
                    )
            )
        ) AS t1
        ON (t0.ID = t1.ID)
        WHEN MATCHED THEN
            UPDATE
            SET
                t0.FIRST_NAME = t1.FIRST_NAME,
                t0.LAST_NAME = t1.LAST_NAME,
                t0.EMAIL = t1.EMAIL,
                t0.GENDER = t1.GENDER,
                t0.CARD_NUMBER = t1.CARD_NUMBER,
                t0.BALANCE = t1.BALANCE,
                t0.CREDIT_LIMIT = t1.CREDIT_LIMIT,
                t0.CARD_CURRENCY = t1.CARD_CURRENCY,
                t0.DT_END = @sp_EXTRACTED_DATE
        WHEN NOT MATCHED THEN
            INSERT
                (
                    ID,
                    FIRST_NAME,
                    LAST_NAME,
                    EMAIL,
                    GENDER,
                    CARD_NUMBER,
                    BALANCE,
                    CREDIT_LIMIT,
                    CARD_CURRENCY,
                    DT_START,
                    DT_END
                )
            VALUES
                (
                    t1.ID,
                    t1.FIRST_NAME,
                    t1.LAST_NAME,
                    t1.EMAIL,
                    t1.GENDER,
                    t1.CARD_NUMBER,
                    t1.BALANCE,
                    t1.CREDIT_LIMIT,
                    t1.CARD_CURRENCY,
                    @sp_EXTRACTED_DATE,
                    '9999-12-31'
                );
    END;
END;


Execute dbo.sp_Load_Data_Archive'2023-01-02';

SELECT * FROM [dbo].[CUSTOMER_CARDS]