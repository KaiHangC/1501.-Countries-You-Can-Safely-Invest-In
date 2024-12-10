# 1501.-Countries-You-Can-Safely-Invest-In
This is my answer for Leetcode question 1501. Countries You Can Safely Invest In
# Intuition
<!-- Describe your first thoughts on how to solve this problem. -->
This question is going to be easier when break it down.
Base on the infomation is provide and the question discription. we need to find out the global call duration average by sum all the call duration and divide by total call.
To get country call duration average, we need to get sum of each country call duration and divide by how many call each country has.
The final step just to campare them. 

# Approach
<!-- Describe your approach to solving the problem. -->
The first step is to get global call duration average
```MySQL
SELECT (SUM(duration)/ COUNT(*)) AS avg_call 
FROM Calls 
```
| avg_call |
| -------- |
| 55.7     |

The second step is to get the call duration of each country, but before we do that, there is a issue. 
The calls table has two columns that has the id of the person, caller and callee.
To combine that we need to use UNION ALL.
```MySQL
SELECT caller_id AS id, duration
FROM Calls
UNION ALL 
SELECT callee_id AS id, duration
FROM Calls
```   
| id | duration |
| -- | -------- |
| 1  | 33       |
| 2  | 4        |
| 1  | 59       |
| 3  | 102      |
| 3  | 330      |
| 12 | 5        |
| 7  | 13       |
| 7  | 3        |
| 9  | 1        |
| 1  | 7        |
| 9  | 33       |
| 9  | 4        |
| 2  | 59       |
| 12 | 102      |
| 12 | 330      |
| 3  | 5        |
| 9  | 13       |
| 1  | 3        |
| 7  | 1        |
| 7  | 7        |

Don't forget we also need to have person's phone_number to get country code. So, we need to join on id and use SUBSTRING() to get the country code

Now, we have all the infomation we need from calls table and person table all we need to do sum up all the duration and divide by total call with GROUP BY

```MySQL
SELECT SUBSTRING(p.phone_number,1,3) AS code, (SUM(i.duration) * 1.0 / COUNT(*)) AS avg_call
FROM info i
LEFT JOIN Person p ON p.id = i.id
GROUP BY SUBSTRING(p.phone_number,1,3)
```
| code  | avg_call  |
| ----- | --------- |
| "212" | 27.5      |
| "051" | 145.66667 |
| "972" | 9.375     |

The last step is to compare the global average call and country average call with CASE WHEN and filter out null value with WHERE /condition/ IS NOT NULL
Get the country name by join on country code
```MySQL
SELECT 
    CASE WHEN c1.avg_call > (SELECT * FROM global_avg_call) THEN c2.name END AS country
FROM code_avg_call c1 
LEFT JOIN Country c2 ON c1.code = c2.country_code 
WHERE CASE WHEN c1.avg_call > (SELECT * FROM global_avg_call) THEN c2.name END IS NOT NULL
```
Finally combine all info together with CTEs(Common Table Expressions)
# Code
```mysql []
# Write your MySQL query statement below
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
```
