WITH BALANCES AS (
  SELECT 
    T.FROM AS ACC, 
    T.TDATE, 
    -T.AMOUNT AS BALANCE, 
    ROW_NUMBER() OVER (PARTITION BY T.FROM ORDER BY TDATE) AS RN
  FROM TRANSFERS T
  UNION ALL
  SELECT 
    T2.TO AS ACC, 
    T2.TDATE, 
    T2.AMOUNT AS BALANCE, 
    ROW_NUMBER() OVER (PARTITION BY T2.TO ORDER BY TDATE) AS RN
  FROM TRANSFERS T2
),
PERIODS AS (
  SELECT 
    ACC,
    TDATE AS DT_FROM,
    LEAD(TDATE, 1, '3000-01-01') OVER (PARTITION BY ACC ORDER BY TDATE) AS DT_TO,
    SUM(BALANCE) OVER (PARTITION BY ACC ORDER BY TDATE, RN) AS BALANCE
  FROM BALANCES
)
SELECT ACC,
TO_CHAR(DT_FROM, 'DD.MM.YYYY'),
TO_CHAR(DT_TO, 'DD.MM.YYYY'),
BALANCE
FROM PERIODS
WHERE DT_FROM < DT_TO
ORDER BY ACC, DT_FROM;