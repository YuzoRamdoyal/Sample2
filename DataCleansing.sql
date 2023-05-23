-- Remove leading and trailing spaces from a column
UPDATE CUSTOMER_CARDS_TMP
SET 
id = LTRIM(RTRIM(id)),
first_name = LTRIM(RTRIM(first_name)),
last_name = LTRIM(RTRIM(last_name)),
email = LTRIM(RTRIM(email)),
gender = LTRIM(RTRIM(gender)),
ip_address = LTRIM(RTRIM(ip_address)),
card_number = LTRIM(RTRIM(card_number)),
credit_limit = LTRIM(RTRIM(credit_limit)),
card_currency = LTRIM(RTRIM(card_currency)),
gender = REPLACE(gender, ' ', ''),
email = REPLACE(email, ' ', '');


UPDATE CUSTOMER_CARDS_TMP
SET gender = CASE 
    WHEN gender = 'F' THEN 'Female'
    WHEN gender = 'M' THEN 'Male'
    ELSE gender
END;
