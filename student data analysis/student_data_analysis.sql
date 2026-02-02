create database student_data
use student_data;
select * from correct_answer
select * from student_response
select  * from student_list
select * from question_paper_code

-- ##############################################################
create view result as
WITH temp1 AS (
    SELECT sr.roll_number,
           sr.question_paper_code,
           sr.question_number,
           sr.option_marked,
           ca.correct_option
    FROM student_response AS sr
    JOIN correct_answer AS ca
      ON sr.question_paper_code = ca.question_paper_code
     AND sr.question_number = ca.question_number
),

temp2 AS (
    SELECT *,
           CASE
               WHEN option_marked = correct_option THEN 'correct'
               WHEN option_marked = 'e'          THEN 'yet_to_learn'
               ELSE 'incorrect'
           END AS status
    FROM temp1
),

temp3 AS (
    SELECT *
    FROM temp2 t2
    JOIN question_paper_code qc
      ON t2.question_paper_code = qc.paper_code
),

temp4 AS (
    SELECT 
        roll_number,
        status,
        subject,
        COUNT(*) AS count
    FROM temp3
    GROUP BY roll_number, status, subject
),

temp5 AS (
    SELECT
        roll_number,
        CONCAT(status, '_', subject) AS subject_status,
        count
    FROM temp4
),

temp6 AS (
    SELECT
        roll_number,
        SUM(CASE WHEN subject_status = 'incorrect_Science'     THEN count END) AS incorrect_Science,
        SUM(CASE WHEN subject_status = 'yet_to_learn_Science'  THEN count END) AS yet_to_learn_Science,
        SUM(CASE WHEN subject_status = 'correct_Science'       THEN count END) AS correct_Science,
        SUM(CASE WHEN subject_status = 'yet_to_learn_Math'     THEN count END) AS yet_to_learn_Math,
        SUM(CASE WHEN subject_status = 'incorrect_Math'        THEN count END) AS incorrect_Math,
        SUM(CASE WHEN subject_status = 'correct_Math'          THEN count END) AS correct_Math
    FROM temp5
    GROUP BY roll_number
),

temp7 AS (
    SELECT
        t6.roll_number,
        sl.student_name,
        sl.class,
        sl.section,
        t6.incorrect_Science,
        t6.yet_to_learn_Science,
        t6.correct_Science,
        t6.yet_to_learn_Math,
        t6.correct_Math,
        t6.incorrect_Math,
        t6.correct_Science AS science_obtain_mark,
        t6.correct_Math    AS math_obtain_mark,
        (t6.correct_Science /
            (t6.correct_Science + t6.yet_to_learn_Science + t6.incorrect_Science)
        ) * 100 AS science_percentage,
        (t6.correct_Math /
            (t6.correct_Math + t6.yet_to_learn_Math + t6.incorrect_Math)
        ) * 100 AS math_percentage
    FROM temp6 t6
    JOIN student_list sl
      ON t6.roll_number = sl.roll_number
)

SELECT *
FROM temp7;

-- views:A SQL View is a virtual table created from the result of a SELECT query.
select * from result
