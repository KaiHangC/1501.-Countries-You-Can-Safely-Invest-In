WITH global_avg_call AS(
    SELECT (SUM(duration)/ COUNT(*)) AS avg_call FROM Calls 
),info AS (
    SELECT caller_id AS id, duration
    FROM Calls
    UNION ALL 
    SELECT callee_id AS id, duration
    FROM Calls
),code_avg_call AS(
    SELECT SUBSTRING(p.phone_number,1,3) AS code, (SUM(i.duration) * 1.0 / COUNT(*)) AS avg_call
    FROM info i
    LEFT JOIN Person p ON p.id = i.id
    GROUP BY SUBSTRING(p.phone_number,1,3)
)
SELECT 
    CASE WHEN c1.avg_call > (SELECT * FROM global_avg_call) THEN c2.name END AS country
FROM code_avg_call c1 
LEFT JOIN Country c2 ON c1.code = c2.country_code 
WHERE CASE WHEN c1.avg_call > (SELECT * FROM global_avg_call) THEN c2.name END IS NOT NULL
