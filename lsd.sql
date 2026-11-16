create database employee_performances;
use employee_performances;
create table employee_master
(
   employee_id varchar(50) primary key,
   employee_name varchar(100),
   department varchar(50),
   job_title varchar(100),
   level varchar(20),
   experience_years decimal(4,1),
   location varchar(100),
   employment_type varchar(50),
   manager_id varchar(50),
   joining_date date
);
create table quarterly_performance
(
   Employee_ID VARCHAR(50),
    Year INT,
    Quarter VARCHAR(10),
    Tasks_Assigned INT,
    Tasks_Completed INT,
    Tasks_Completed_On_Time INT,
    Production_Defects INT,
    Reopened_Items INT,
    Attendance_Percent DECIMAL(5, 2),
    Training_Hours DECIMAL(5, 2),
    Goals_Set INT,
    Goals_Achieved INT,
    Peer_Feedback_Rating_1_5 DECIMAL(3, 2),
    Manager_Rating_1_5 DECIMAL(3, 2),
    Stakeholder_Satisfaction_1_5 DECIMAL(3, 2),
    Overtime_Hours DECIMAL(5, 2),
    Task_Completion_Rate_Percent DECIMAL(5, 2),
    On_Time_Rate_Percent DECIMAL(5, 2),
    Goal_Achievement_Rate_Percent DECIMAL(5, 2),
    FOREIGN KEY (Employee_ID) REFERENCES employee_master(Employee_ID)
);
select department,count(*) as total_employees from employee_master group by department order by total_employees desc;
select level,round(avg(experience_years),2) as average_experience from employee_master group by level order by average_experience desc;
select e.employee_id,e.employee_name,round(avg(q.manager_rating_1_5),2) as average_manager_rating from employee_master e join quarterly_performance q on e.employee_id=q.employee_id group by e.employee_id,e.employee_name order by average_manager_rating desc limit 10;
select e.department,round(avg(q.task_completion_rate_percent),2) as avg_completion_rate,round(avg(q.attendance_percent),2) as avg_attendancce from employee_master e join quarterly_performance q on e.employee_id=q.employee_id where q.year=2025 group by e.department order by avg_completion_rate desc;
select distinct e.employee_id,e.employee_name,e.department,q.year,q.quarter,q.manager_rating_1_5,q.attendance_percent from employee_master e join quarterly_performance q on e.employee_id=q.employee_id where q.manager_rating_1_5>=4.5 and q.attendance_percent>=95.0 order by q.year desc, q.quarter desc;
select e.department,sum(q.training_hours) as total_training_hours,sum(q.production_defects) as total_production_defects from employee_master e join quarterly_performance q on e.employee_id=q.employee_id group by e.department order by total_training_hours,total_production_defects;
select department,count(employee_id) as total_employees,round(avg(experience_years),2) as avg_experience_years from employee_master group by department order by avg_experience_years desc;
select e.employee_id,e.employee_name,e.department,q.year,q.quarter,q.manager_rating_1_5,q.task_completion_rate_percent from employee_master e join quarterly_performance q on e.employee_id=q.employee_id order by q.year desc,q.quarter desc,q.manager_rating_1_5 desc;
select e.department,round(avg(q.manager_rating_1_5),2) as avg_manager_rating,round(avg(q.on_time_rate_percent),2) as average_on_time from employee_master e join quarterly_performance q on e.employee_id=q.employee_id where q.year=(select max(year) from quarterly_performance) and q.quarter='Q4' group by e.department order by avg_manager_rating desc;
select q.year,q.quarter,e.employee_name,e.department,q.manager_rating_1_5,dense_rank() over(partition by q.year,q.quarter order by q.manager_rating_1_5 desc ) as performance_rank from quarterly_performance q join employee_master e on q.employee_id=e.employee_id;
select distinct e.employee_id,e.employee_name,e.job_title,e.department from employee_master e where e.employee_id in(select employee_id from quarterly_performance where goal_achievement_rate_percent>=100);
SELECT 
    e.Employee_ID,
    e.Employee_Name,
    e.Department,
    ROUND(AVG(p.On_Time_Rate_Percent), 2) AS Avg_On_Time_Rate
FROM employee_master e
JOIN quarterly_performance p 
    ON e.Employee_ID = p.Employee_ID
GROUP BY e.Employee_ID, e.Employee_Name, e.Department
HAVING AVG(p.On_Time_Rate_Percent) < 80
ORDER BY Avg_On_Time_Rate ASC;
select e.department,round(avg(q.manager_rating_1_5),2) as avg_manager_rating,round(avg(q.on_time_rate_percent),2) as avg_on_rate from employee_master e join quarterly_performance q on e.employee_id=q.employee_id where q.year=(select max(year) from quarterly_performance) and q.quarter='Q4' group by e.department order by avg_manager_rating desc;
select employee_id,employee_name, job_title, experience_years,location from employee_master where department='Engineering' and employment_type='Full-Time' and experience_years>3 order by experience_years desc;