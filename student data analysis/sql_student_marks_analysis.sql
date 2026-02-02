use stu12;

select * from student_list; -- roll_number , student_name , class , section , schol
select * from question_paper_code;-- paper_code , class , subject
select * from correct_answer; -- question_paper_code , question_no , correct_option
select * from student_response;-- rol_number , question_paper_code, question_number
 -- option_marked
 
 
 -- creating a temp table
 -- ################################################################
 
WITH temp1
     AS (SELECT roll_number,
                sr.question_paper_code,
                sr.question_number,
                option_marked,
                correct_option
         FROM   student_response AS sr
                JOIN correct_answer AS ca
                  ON sr.question_paper_code = ca.question_paper_code
                     AND sr.question_number = ca.question_number),
     temp2
     AS (SELECT *,
                CASE
                  WHEN option_marked = correct_option THEN 'correct'
                  WHEN option_marked = 'e' THEN 'yet_to_learn'
                  WHEN option_marked != correct_option THEN 'incorrect'
                END AS 'status'
         FROM   temp1),
     temp3
     AS (SELECT *
         FROM   temp2 AS t2
                JOIN question_paper_code AS qc
                  ON t2.question_paper_code = qc.paper_code),
     temp4
     AS (SELECT roll_number,
                subject,
                status,
                Count(status) AS 'cnt'
         FROM   temp3
         GROUP  BY roll_number,
                   subject,
                   status),
     temp5
     AS (SELECT *,
                Concat(subject, '_', status) AS 'merged_cols'
         FROM   temp4),
     temp6
     AS (SELECT roll_number,
                Sum(CASE
                      WHEN merged_cols = 'Science_incorrect' THEN cnt
                      ELSE 0
                    END) AS science_incorrect,
                Sum(CASE
                      WHEN merged_cols = 'Science_yet_to_learn' THEN cnt
                      ELSE 0
                    END) AS science_yet_to_learn,
                Sum(CASE
                      WHEN merged_cols = 'Science_correct' THEN cnt
                      ELSE 0
                    END) AS science_correct,
                Sum(CASE
                      WHEN merged_cols = 'Math_correct' THEN cnt
                      ELSE 0
                    END) AS math_correct,
                Sum(CASE
                      WHEN merged_cols = 'Math_incorrect' THEN cnt
                      ELSE 0
                    END) AS math_incorrect,
                Sum(CASE
                      WHEN merged_cols = 'Math_yet_to_learn' THEN cnt
                      ELSE 0
                    END) AS Math_yet_to_learn
         FROM   temp5
         GROUP  BY roll_number),
     temp7
     AS (SELECT roll_number,
                math_correct
                AS
                   'math_score',
                science_correct
                AS
                   'science_score',
                science_incorrect,
                science_yet_to_learn,
                science_correct,
                math_correct,
                math_incorrect,
                math_yet_to_learn,
                Round(( math_correct / ( math_correct + math_incorrect
                                         + math_yet_to_learn ) ) * 100, 2)
                AS
                   'math_%',
                Round(( science_correct / ( science_correct + science_incorrect
                                            + science_yet_to_learn ) ) * 100, 2)
                AS
                   'sci_%'
         FROM   temp6)
            
	
SELECT * from student_list as sl 
join temp7 as t7 on sl.roll_number=t7.roll_number


                  
                  

 
 -- ##################################################################
 
 SELECT 
  department,
  SUM(CASE WHEN month = 'Jan' THEN sales ELSE 0 END) AS Jan_Sales,
  SUM(CASE WHEN month = 'Feb' THEN sales ELSE 0 END) AS Feb_Sales
FROM 
  sales_data
GROUP BY 
  department;

 
 
 
 
 select * from temp1
 