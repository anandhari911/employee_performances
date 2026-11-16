create database kl;
use kl;
create table employees
(
  employee_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    role VARCHAR(100) NOT NULL,
    experience_years INT NOT NULL,
    project_count INT NOT NULL,
    tasks_assigned INT NOT NULL,
    tasks_completed INT NOT NULL,
    defect_rate DECIMAL(5, 2) NOT NULL,
    attendance_pct DECIMAL(5, 2) NOT NULL,
    training_hours INT NOT NULL,
    performance_rating DECIMAL(3, 2) NOT NULL,
    customer_satisfaction_pct DECIMAL(5, 2) NOT NULL,
    team_collaboration_score INT NOT NULL,
    promotion_eligible VARCHAR(3) NOT NULL
);
select employee_id,name,department,role,performance_rating,customer_satisfaction_pct from employees order by performance_rating, customer_satisfaction_pct desc limit 10;
select department,count(employee_id) as total_employee,round(avg(performance_rating),2) as average_performance_rating,round(avg(experience_years),1) as avg_experience_years,round(avg(defect_rate),2) as average_defect_rate_pct from employees group by department order by average_performance_rating;
select employee_id,name,department,role,tasks_completed,defect_rate,performance_rating from employees where promotion_eligible='Yes' and performance_rating>=4.5 and defect_rate<2.0 order by performance_rating;
select department,role,count(employee_id) as headcount,round(avg(experience_years),1) as avg_experience,round(avg(performance_rating),2) as avg_rating,round(sum(tasks_completed)/nullif(sum(tasks_assigned),0),2) as task_completion_rate,round(avg(defect_rate),2) as avg_defect_rate,round(avg(customer_satisfaction_pct),2) as avg_cast,
    SUM(CASE WHEN promotion_eligible = 'Yes' THEN 1 ELSE 0 END) AS promotion_eligible_count,
    RANK() OVER (PARTITION BY department ORDER BY AVG(performance_rating) DESC) AS role_rank_in_dept from employees group by department,role ORDER BY department, role_rank_in_dept;
select 
  case 
    when experience_years<2 then '1.Junior (0-1 Yrs)'
    when experience_years between 2 and 4 then '2. Mid-level (2-4 Yrs)'
    when experience_years between 5 and 8 then '3. Senior(5-8 Yrs)'
    else '4.Principal/Lead(5+yrs)'
    end as tenure_coherent,
    count(employee_id) as total_employee,
    round(avg(project_count),2) as average_project_count,
    round(avg(tasks_completed*100.0/nullif(tasks_assigned,0)),2) as avg_completed_tasks,
    round(avg(defect_rate),2) as avg_defect_rate,
    round(avg(performance_rating),2) as avg_performance_rating
    from employees group by tenure_coherent order by tenure_coherent;
WITH employee_kpis AS (
    SELECT 
        employee_id,
        department,
        ROUND(tasks_completed * 100.0 / NULLIF(tasks_assigned, 0), 2) AS completion_pct,
        CASE WHEN (tasks_completed * 100.0 / NULLIF(tasks_assigned, 0)) >= 90 THEN 1 ELSE 0 END AS met_delivery_goal,
        CASE WHEN defect_rate <= 2.5 THEN 1 ELSE 0 END AS met_quality_goal,
        CASE WHEN attendance_pct >= 92.0 THEN 1 ELSE 0 END AS met_attendance_goal,
        CASE WHEN performance_rating >= 4.0 THEN 1 ELSE 0 END AS met_rating_goal
    FROM employees
)
select 
department,count(*) as total_staff,ROUND(AVG(met_delivery_goal) * 100, 1) AS pct_met_delivery,
    ROUND(AVG(met_quality_goal) * 100, 1) AS pct_met_quality,
    ROUND(AVG(met_attendance_goal) * 100, 1) AS pct_met_attendance,
    ROUND(AVG(met_rating_goal) * 100, 1) AS pct_met_rating,
    SUM(CASE WHEN met_delivery_goal = 1 AND met_quality_goal = 1 AND met_attendance_goal = 1 AND met_rating_goal = 1 THEN 1 ELSE 0 END) AS all_goals_achieved
    from employee_kpis group by department order by all_goals_achieved desc;
    select
     case 
     WHEN (tasks_completed * 100.0 / NULLIF(tasks_assigned, 0)) >= 88.5 AND defect_rate <= 3.34 
            THEN '1. High Delivery / High Quality (Stars)'
        WHEN (tasks_completed * 100.0 / NULLIF(tasks_assigned, 0)) >= 88.5 AND defect_rate > 3.34 
            THEN '2. High Delivery / Low Quality (Rushing / Burnout Risk)'
        WHEN (tasks_completed * 100.0 / NULLIF(tasks_assigned, 0)) < 88.5 AND defect_rate <= 3.34 
            THEN '3. Low Delivery / High Quality (Over-Cautious / Bottleneck)'
        ELSE '4. Low Delivery / Low Quality (Needs Coaching)'
    END AS quadrant,
    count(employee_id) as employee_count,round(count(employee_id)*100.0/sum(count(employee_id)) over(),2) as workforce_share_pct,round(avg(performance_rating),2) as avg_rating,round(avg(customer_satisfaction_pct),2) as avg_cast,round(avg(training_hours),1) as avg_training_hours from employees group by quadrant order by quadrant;
    WITH stats AS (
    SELECT 
        AVG(defect_rate) AS mean_defect,
        STDDEV(defect_rate) AS sd_defect,
        AVG(tasks_completed) AS mean_tasks,
        STDDEV(tasks_completed) AS sd_tasks
    FROM employees
),
scored_employees AS (
    SELECT 
        e.*,
        ROUND((e.defect_rate - s.mean_defect) / NULLIF(s.sd_defect, 0), 2) AS defect_z_score,
        ROUND((e.tasks_completed - s.mean_tasks) / NULLIF(s.sd_tasks, 0), 2) AS output_z_score,
        ROUND(e.tasks_completed * 100.0 / NULLIF(e.tasks_assigned, 0), 2) AS completion_pct
    FROM employees e
    CROSS JOIN stats s
)
SELECT 
    employee_id,
    name,
    department,
    role,
    performance_rating,
    completion_pct,
    defect_rate,
    defect_z_score,
    promotion_eligible,
    CASE 
        WHEN performance_rating >= 4.7 AND promotion_eligible = 'No' THEN 'Overlooked Top Performer'
        WHEN performance_rating <= 3.0 AND promotion_eligible = 'Yes' THEN 'Questionable Promotion Flag'
        WHEN ABS(defect_z_score) >= 1.7 THEN 'Extreme Defect Rate Outlier'
        WHEN completion_pct < 75.0 AND performance_rating >= 4.2 THEN 'High Rating Despite Low Completion'
    END AS anomaly_reason
FROM scored_employees
WHERE (performance_rating >= 4.7 AND promotion_eligible = 'No')
   OR (performance_rating <= 3.0 AND promotion_eligible = 'Yes')
   OR ABS(defect_z_score) >= 1.7
   OR (completion_pct < 75.0 AND performance_rating >= 4.2)
ORDER BY anomaly_reason, performance_rating DESC;