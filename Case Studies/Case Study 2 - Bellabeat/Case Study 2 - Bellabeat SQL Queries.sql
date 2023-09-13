-- List the unique number of users in each table
SELECT COUNT(DISTINCT id) FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`;
SELECT COUNT(DISTINCT id) FROM `optimum-beach-395318.DailyCalories.dailyCalories_merged`;
SELECT COUNT(DISTINCT id) FROM `optimum-beach-395318.DailySleep.sleepDay_merged`;
SELECT COUNT(DISTINCT id) FROM `optimum-beach-395318.DailySteps.dailySteps_merged`;
SELECT COUNT(DISTINCT id) FROM `optimum-beach-395318.WeightLog.weightLogInfo_merged`;

/*
Daily Activity - 33
Daily Calories - 33
Daily Sleep - 24
Daily Steps - 33
Weight Log - 8
*/

SELECT
  Min(activity_date) AS first_day,
  Max(activity_date) AS last_day
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`;
-- The dates are not consistent with the ones stated in the database summary.
-- The summary stated that the date range was 2016-03-12 to 2016-05-12
-- This data only goes rom 2016-04-12 to 2016-05-12

-- View how many times each user used the tracker
SELECT 
    id,
    COUNT(id) AS number_of_logged_data
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
GROUP BY id;

-- View the number of users who logged into the tracker for a certain number of days.
SELECT 
  number_of_logged_data,
  COUNT(number_of_logged_data) AS number_of_users
FROM (
  SELECT 
    id,
    COUNT(id) AS number_of_logged_data
  FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
  GROUP BY id
)
GROUP BY number_of_logged_data
ORDER BY number_of_logged_data DESC;

-- See what type of user each user is based on the amount of times they used their tracker
SELECT 
  id,
  COUNT(id) AS total_times_logged,
  CASE
    WHEN COUNT(id) BETWEEN 29 AND 31 THEN 'Heavy User'
    WHEN COUNT(id) BETWEEN 22 and 28 THEN 'Moderate User'
    WHEN COUNT(id) BETWEEN 16 AND 21 THEN 'Light User'
    WHEN COUNT(id) BETWEEN 0 AND 15 THEN 'Sporadic User'
  END type_of_user
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
GROUP BY id;

-- See the distribution of the different types of user
SELECT
  type_of_user,
  COUNT(type_of_user) AS user_quantity
FROM (
  SELECT 
    id,
    COUNT(id) AS total_times_logged,
  CASE
    WHEN COUNT(id) BETWEEN 29 AND 31 THEN 'Heavy User'
    WHEN COUNT(id) BETWEEN 22 and 28 THEN 'Moderate User'
    WHEN COUNT(id) BETWEEN 16 AND 21 THEN 'Light User'
    WHEN COUNT(id) BETWEEN 0 AND 15 THEN 'Sporadic User'
  END AS type_of_user
  FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
  GROUP BY id
  )
GROUP BY(type_of_user)
ORDER BY
    CASE
        WHEN type_of_user = 'Heavy User' THEN 1
        WHEN type_of_user = 'Moderate User' THEN 2
        WHEN type_of_user = 'Light User' THEN 3
        ELSE 4
    END;


-- ACTIVITY LEVEL
--  Total active minutes per intensity and the cumulative sedentary minutes for each weekday
SELECT
  weekday,
  SUM(very_active_minutes) AS very_active,
  SUM(fairly_active_minutes) AS fairly_active,
  SUM(lightly_active_minutes) AS lightly_active,
  SUM(sedentary_minutes) AS sedentary,
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;

-- Average of active minutes and sedentary minutes per weekday
SELECT
  weekday,
  ROUND(AVG(very_active_minutes) + AVG(fairly_active_minutes) + AVG(lightly_active_minutes),2) AS average_active_mins,
  ROUND(AVG(sedentary_minutes),2) AS avg_sedentary_mins
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;

--  Total active distance per intensity and the cumulative sedentary distance for each weekday
SELECT
  weekday,
  ROUND(SUM(very_active_distance),2) AS very_active,
  ROUND(SUM(moderately_active_distance),2) AS moderately_active,
  ROUND(SUM(light_active_distance),2) AS light_active,
  ROUND(SUM(sedentary_active_distance),2) AS sedentary,
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;

-- Average of active distance and sedentary distance per weekday
SELECT
  weekday,
  ROUND(AVG(very_active_distance) + AVG(moderately_active_distance) + AVG(light_active_distance),2) AS average_active_distance,
  ROUND(AVG(sedentary_active_distance),2) AS avg_sedentary_mins
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;


-- STEPS

--Total number of steps taken per weekday
SELECT
  weekday,
  SUM(step_total) AS total_steps
FROM `optimum-beach-395318.DailySteps.dailySteps_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;

--Average of steps taken per weekday
SELECT
  weekday,
  ROUND(AVG(step_total),2) AS avg_total_steps
FROM `optimum-beach-395318.DailySteps.dailySteps_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;

-- Average steps per user per weekday
SELECT
  id,
  ROUND(AVG(CASE WHEN weekday = 'Monday' THEN step_total END), 2) AS avg_monday_steps,
  ROUND(AVG(CASE WHEN weekday = 'Tuesday' THEN step_total END), 2) AS avg_tuesday_steps,
  ROUND(AVG(CASE WHEN weekday = 'Wednesday' THEN step_total END), 2) AS avg_wednesday_steps,
  ROUND(AVG(CASE WHEN weekday = 'Thursday' THEN step_total END), 2) AS avg_thursday_steps,
  ROUND(AVG(CASE WHEN weekday = 'Friday' THEN step_total END), 2) AS avg_friday_steps,
  ROUND(AVG(CASE WHEN weekday = 'Saturday' THEN step_total END), 2) AS avg_saturday_steps,
  ROUND(AVG(CASE WHEN weekday = 'Sunday' THEN step_total END), 2) AS avg_sunday_steps,
  ROUND(AVG(step_total)) AS avg_daily_steps
FROM `optimum-beach-395318.DailySteps.dailySteps_merged`
GROUP BY id
ORDER BY id;

-- Check the activity level of users
SELECT
  id,
  ROUND(AVG(step_total),2) AS avg_daily_steps,
  CASE
    WHEN AVG(step_total) BETWEEN 0 AND 4500 THEN 'Inactive'
    WHEN AVG(step_total) BETWEEN 4501 AND 6000 THEN 'Light Active'
    WHEN AVG(step_total) BETWEEN 6001 AND 8000 THEN 'Moderately Active'
    WHEN AVG(step_total) BETWEEN 8001 AND 10000 THEN 'Active'
    WHEN AVG(step_total) > 10000 THEN 'Highly Active'
    ELSE 'Not enough data'
  END AS activity_level
FROM `optimum-beach-395318.DailySteps.dailySteps_merged`
GROUP BY id
ORDER BY id;

-- Check how many users belong to each activity level
SELECT
  activity_level,
  COUNT(activity_level) AS user_quantity
FROM (
  SELECT
    id,
    ROUND(AVG(step_total),2) AS avg_daily_steps,
    CASE
      WHEN AVG(step_total) BETWEEN 0 AND 4500 THEN 'Inactive'
      WHEN AVG(step_total) BETWEEN 4501 AND 6000 THEN 'Light Active'
      WHEN AVG(step_total) BETWEEN 6001 AND 8000 THEN 'Moderate Active'
      WHEN AVG(step_total) BETWEEN 8001 AND 10000 THEN 'Active'
      WHEN AVG(step_total) > 10000 THEN 'Highly Active'
      ELSE 'Not enough data'
    END AS activity_level
  FROM `optimum-beach-395318.DailySteps.dailySteps_merged`
  GROUP BY id
  ORDER BY id
)
GROUP BY activity_level
ORDER BY
  CASE
    WHEN activity_level = 'Highly Active' THEN 1
    WHEN activity_level = 'Active' THEN 2
    WHEN activity_level = 'Moderate Active' THEN 3
    WHEN activity_level = 'Light Active' THEN 4
    ELSE 5
  END;


-- CALORIES

-- Total number of calories taken per weekday
SELECT
  weekday,
  SUM(calories) AS total_calories
FROM `optimum-beach-395318.DailyCalories.dailyCalories_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;

-- Average number of calories taken per weekday
SELECT
  weekday,
  ROUND(AVG(calories), 2) AS avg_calories
FROM `optimum-beach-395318.DailyCalories.dailyCalories_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;

-- Total number of calories taken per weekday per user per day
SELECT
  id,
  SUM(CASE WHEN weekday = 'Monday' THEN calories END) AS monday_calories,
  SUM(CASE WHEN weekday = 'Tuesday' THEN calories END) AS tuesday_calories,
  SUM(CASE WHEN weekday = 'Wednesday' THEN calories END) AS wednesday_calories,
  SUM(CASE WHEN weekday = 'Thursday' THEN calories END) AS thursday_calories,
  SUM(CASE WHEN weekday = 'Friday' THEN calories END) AS friday_calories,
  SUM(CASE WHEN weekday = 'Saturday' THEN calories END) AS saturday_calories,
  SUM(CASE WHEN weekday = 'Sunday' THEN calories END) AS sunday_calories,
  SUM(calories) AS weekly_calories
FROM `optimum-beach-395318.DailyCalories.dailyCalories_merged`
GROUP BY id
ORDER BY id DESC;
  
-- Average number of calories taken per user
SELECT
  id,
  ROUND(AVG(CASE WHEN weekday = 'Monday' THEN calories END),2) AS avg_mon_calories,
  ROUND(AVG(CASE WHEN weekday = 'Tuesday' THEN calories END),2) AS avg_tue_calories,
  ROUND(AVG(CASE WHEN weekday = 'Wednesday' THEN calories END),2) AS avg_wed_calories,
  ROUND(AVG(CASE WHEN weekday = 'Thursday' THEN calories END),2) AS avg_thu_calories,
  ROUND(AVG(CASE WHEN weekday = 'Friday' THEN calories END),2) AS avg_fri_calories,
  ROUND(AVG(CASE WHEN weekday = 'Saturday' THEN calories END),2) AS avg_sat_calories,
  ROUND(AVG(CASE WHEN weekday = 'Sunday' THEN calories END),2) AS avg_sun_calories,
  ROUND(AVG(calories),2) AS avg_daily_calories
FROM `optimum-beach-395318.DailyCalories.dailyCalories_merged`
GROUP BY id
ORDER BY id DESC;

-- Check caloric burn levels
SELECT
  id,
  ROUND(AVG(calories)) AS avg_daily_calories,
  CASE
    WHEN AVG(calories) BETWEEN 0 AND 1999 THEN 'Low'
    WHEN AVG(calories) BETWEEN 2000 AND 3000 THEN 'Normal'
    WHEN AVG(calories) > 3000 THEN 'High'
  END AS cal_burn_level
FROM `optimum-beach-395318.DailyCalories.dailyCalories_merged`
GROUP BY id
ORDER BY
  CASE
    WHEN cal_burn_level = 'High' THEN 1
    WHEN cal_burn_level = 'Normal' THEN 2
    ELSE 3
  END;

-- Check how many users belong to each group
SELECT
  cal_burn_level,
  COUNT(cal_burn_level) AS user_quantity
FROM (
  SELECT
    id,
    ROUND(AVG(calories)) AS avg_daily_calories,
    CASE
      WHEN AVG(calories) BETWEEN 0 AND 1999 THEN 'Low'
      WHEN AVG(calories) BETWEEN 2000 AND 3000 THEN 'Normal'
      WHEN AVG(calories) > 3000 THEN 'High'
    END AS cal_burn_level
  FROM `optimum-beach-395318.DailyCalories.dailyCalories_merged`
  GROUP BY id
  ORDER BY id DESC
)
GROUP BY cal_burn_level
ORDER BY
  CASE
    WHEN cal_burn_level = 'High' THEN 1
    WHEN cal_burn_level = 'Normal' THEN 2
    ELSE 3
  END;

-- STEPS, CALORIES, AND ACTIVE MINUTES

-- Comparison of total steps, total calories, and total active minutes by user
SELECT 
  id, 
  SUM(total_steps) AS sum_total_steps,
  SUM(calories) AS sum_calories, 
  SUM(very_active_minutes + fairly_active_minutes + lightly_active_minutes) AS sum_active_minutes
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
GROUP BY id;

-- Comparison of avg steps, avg calories, and avg active minutes by user
SELECT
  id,
  ROUND(AVG(total_steps), 2) AS avg_total_steps,
  ROUND(AVG(calories), 2) AS avg_calories,
  ROUND(AVG(very_active_minutes)+ AVG(fairly_active_minutes) + AVG(lightly_active_minutes), 2) AS avg_active_minutes
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged`
GROUP BY id;

-- SLEEP

-- In which date did people get the most sleep?
SELECT
  sleep_date,
  SUM(total_minutes_asleep) AS total_minutes_asleep
FROM `optimum-beach-395318.DailySleep.sleepDay_merged`
GROUP BY sleep_date
ORDER BY total_minutes_asleep DESC;

-- In which day of the week did users get the most sleep?
SELECT
  weekday,
  SUM(total_minutes_asleep) AS total_minutes_asleep
FROM `optimum-beach-395318.DailySleep.sleepDay_merged`
GROUP BY weekday
ORDER BY total_minutes_asleep DESC;

-- Avg time in bed compared to avg minutes of sleep per user
SELECT
  id,
  ROUND(AVG(total_minutes_asleep),2) AS avg_minutes_asleep,
  ROUND(AVG(total_time_in_bed),2) AS avg_time_in_bed
FROM `optimum-beach-395318.DailySleep.sleepDay_merged`
GROUP BY id
ORDER BY id DESC;

-- Avg time in bed compared to avg minutes of sleep per weekday
SELECT
  weekday,
  ROUND(AVG(total_minutes_asleep),2) AS avg_minutes_asleep,
  ROUND(AVG(total_time_in_bed),2) AS avg_time_in_bed
FROM `optimum-beach-395318.DailySleep.sleepDay_merged`
GROUP BY weekday
ORDER BY
  CASE
    WHEN weekday = 'Monday' THEN 1
    WHEN weekday = 'Tuesday' THEN 2
    WHEN weekday = 'Wednesday' THEN 3
    WHEN weekday = 'Thursday' THEN 4
    WHEN weekday = 'Friday' THEN 5
    WHEN weekday = 'Saturday' THEN 6
    ELSE 7
  END;

  -- Avg miutes sleep, avg time in bed, avg steps, avg calories, avg active minutes, and avg sedentary minutes by user ID
SELECT 
  daily_act.id,
  ROUND(AVG(daily_act.total_steps), 2) AS avg_daily_steps,
  ROUND(AVG(daily_act.calories), 2) AS avg_daily_calories,
  ROUND(AVG(daily_act.very_active_minutes) + AVG(daily_act.fairly_active_minutes) + AVG(daily_act.lightly_active_minutes), 2) AS avg_active_minutes,
  ROUND(AVG(daily_sleep.total_minutes_asleep), 2) AS avg_daily_sleep,
  ROUND(AVG(daily_sleep.total_time_in_bed), 2) AS avg_daily_time_in_bed,
  ROUND(AVG(daily_act.sedentary_minutes), 2) AS avg_sedentary_minutes
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged` AS daily_act
INNER JOIN `optimum-beach-395318.DailySleep.sleepDay_merged` AS daily_sleep ON daily_act.id = daily_sleep.id
GROUP BY daily_act.id
ORDER BY daily_act.id ASC;


-- Avg Minutes asleep vs Avg sedentary minutes per id
SELECT
  DISTINCT daily_act.id,
  daily_act.activity_date,
  ROUND(AVG(daily_act.sedentary_minutes),2) AS sedentary_mins,
  ROUND(AVG(daily_sleep.total_minutes_asleep),2) AS minutes_asleep
FROM `optimum-beach-395318.DailyActivity.dailyActivity_merged` AS daily_act
INNER JOIN `optimum-beach-395318.DailySleep.sleepDay_merged` AS daily_sleep ON daily_act.id = daily_sleep.id AND daily_act.activity_date = daily_sleep.sleep_date
WHERE daily_sleep.total_minutes_asleep is not NULL
GROUP BY daily_act.id, daily_act.activity_date
ORDER BY daily_act.id ASC;


-- WEIGHT

-- Count number of logged instances by id
SELECT
  id,
  COUNT(id) AS quantity
FROM `optimum-beach-395318.WeightLog.weightLogInfo_merged`
GROUP BY id
ORDER BY quantity DESC;

-- Avg Calories vs Avg BMI
SELECT
  weight.id,
  ROUND(AVG(weight.bmi),2) AS avg_bmi,
  ROUND(AVG(daily_act.calories),2) AS avg_calories
FROM `optimum-beach-395318.WeightLog.weightLogInfo_merged` AS weight
INNER JOIN `optimum-beach-395318.DailyActivity.dailyActivity_merged` AS daily_act ON weight.id = daily_act.id
GROUP BY weight.id;

-- Calories vs Weight Kg
SELECT
  weight.id,
  ROUND(AVG(weight.weight_kg),2) AS avg_weight_kg,
  ROUND(AVG(daily_act.calories),2) AS avg_calories
FROM `optimum-beach-395318.WeightLog.weightLogInfo_merged` AS weight
INNER JOIN `optimum-beach-395318.DailyActivity.dailyActivity_merged` AS daily_act ON weight.id = daily_act.id
GROUP BY weight.id;

-- Weight vs Active Minutes
SELECT
  weight.id,
  ROUND(AVG(weight.weight_kg),2) AS avg_weight_kg,
  ROUND(AVG(daily_act.very_active_minutes) + AVG(daily_act.fairly_active_minutes) + AVG(daily_act.lightly_active_minutes),2) AS avg_active_mins
FROM `optimum-beach-395318.WeightLog.weightLogInfo_merged` AS weight
INNER JOIN `optimum-beach-395318.DailyActivity.dailyActivity_merged` AS daily_act ON weight.id = daily_act.id
GROUP BY weight.id;

-- BMI vs Weight
SELECT
  id,
  ROUND(AVG(bmi), 2) AS avg_bmi,
  ROUND(AVG(weight_kg), 2) AS avg_weight_kg
FROM `optimum-beach-395318.WeightLog.weightLogInfo_merged`
GROUP BY id;

-- Weight vs Steps
SELECT
  weight.id,
  ROUND(AVG(weight.weight_kg),2) AS avg_weight_kg,
  ROUND(AVG(daily_act.total_steps),2) AS avg_total_steps
FROM `optimum-beach-395318.WeightLog.weightLogInfo_merged` AS weight
INNER JOIN `optimum-beach-395318.DailyActivity.dailyActivity_merged` AS daily_act ON weight.id = daily_act.id
GROUP BY weight.id;