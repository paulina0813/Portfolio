#Done in Python beacause it has over 1 million rows
import pandas as pd
from datetime import datetime

#import csv file into dataframe
df = pd.read_csv(r'/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 2 - Bellabeat/Data/Fitabase Data 4.12.16-5.12.16/minuteCaloriesNarrow_merged.csv')
print(df)

# Convert 'Time' column to datetime format
df['ActivityMinute'] = pd.to_datetime(df['ActivityMinute'])

#Rename ActivityMinute to add an underscore between both words
df.rename(columns={'ActivityMinute': 'Activity_Minute'}, inplace=True)

# Specify the desired datetime format
new_datetime_format = '%Y/%m/%d %H:%M:%S'  # Example format: '2023/07/29 08:00:00'

# Transform datetime format and store it in a new column
df['Formatted_Activity_Minute'] = df['Activity_Minute'].dt.strftime(new_datetime_format)

# Check if 'time' column contains valid dates
try:
    pd.to_datetime(df['Activity_Minute'])
    print("All values in 'time' column are valid dates.")
except ValueError:
    print("Some values in 'time' column are not valid dates.")

# Extract date components and save them into new columns
df['activity_day'] = df['Activity_Minute'].dt.date
#Extract time components and save them into new columns
df['activity_time_minute'] = df['Activity_Minute'].dt.time
# Extract weekdays and store in a new column 'Weekday'
df['Weekday'] = df['Activity_Minute'].dt.day_name()
# Convert 'ID' to string and create a new column 'ID_Length' with the length of each 'ID'
df['Id_Length'] = df['Id'].astype(str).str.len()
# Verify that all ID lengths are 10
all_lengths_are_10 = (df['Id_Length'] == 10).all()
print(f"All ID lengths are 10: {all_lengths_are_10}")

#Change all column names to lowercase
df.columns = df.columns.str.lower()
print(df)

# Function to limit decimals to 2 decimal places
def limit_decimals(x):
    return round(x, 2)

# Apply the function to the 'value' column
df['calories'] = df['calories'].apply(limit_decimals)

# List of column names to strip whitespace from
columns_to_strip = ['id', 'activity_minute', 'calories', 'formatted_activity_minute', 'activity_day', 'activity_time_minute', 'weekday', 'id_length']

# Strip leading and trailing whitespace from specified columns
df[columns_to_strip] = df[columns_to_strip].astype(str).apply(lambda x: x.str.strip())

# Remove rows with null or NA values
df_cleaned = df.dropna()

# Remove duplicates
df_cleaned = df.drop_duplicates()

# Sort by 'id', 'date', and 'time_of_day' in descending order
df_sorted = df_cleaned.sort_values(by=['id', 'activity_day', 'activity_time_minute'], ascending=[False, False, False])

# Print the cleaned DataFrame
print(df_cleaned)

#Uncomment to convert to csv
#df_cleaned.to_csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 2 - Bellabeat/Data/Clean Data/minuteCaloriesNarrow_merged_clean.csv', index=False)