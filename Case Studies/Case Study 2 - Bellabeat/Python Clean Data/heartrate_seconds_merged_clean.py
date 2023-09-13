#Done in Python beacause it has over 2 million rows
import pandas as pd
from datetime import datetime

#import csv file into dataframe
df = pd.read_csv(r'/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 2 - Bellabeat/Data/Fitabase Data 4.12.16-5.12.16/heartrate_seconds_merged.csv')
print(df)

# Convert 'Time' column to datetime format
df['Time'] = pd.to_datetime(df['Time'])


# Specify the desired datetime format
new_datetime_format = '%Y/%m/%d %H:%M:%S'  # Example format: '2023/07/29 08:00:00'

# Transform datetime format and store it in a new column
df['Formatted_Time'] = df['Time'].dt.strftime(new_datetime_format)

# Check if 'time' column contains valid dates
try:
    pd.to_datetime(df['Time'])
    print("All values in 'time' column are valid dates.")
except ValueError:
    print("Some values in 'time' column are not valid dates.")

# Extract date components and save them into new columns
df['activity_day'] = df['Time'].dt.date
#Extract time components and save them into new columns
df['Time_Of_Day'] = df['Time'].dt.time
# Extract weekdays and store in a new column 'Weekday'
df['Weekday'] = df['Time'].dt.day_name()
# Convert 'ID' to string and create a new column 'ID_Length' with the length of each 'ID'
df['Id_Length'] = df['Id'].astype(str).str.len()
# Verify that all ID lengths are 10
all_lengths_are_10 = (df['Id_Length'] == 10).all()
print(f"All ID lengths are 10: {all_lengths_are_10}")

#Change all column names to lowercase
df.columns = df.columns.str.lower()
print(df)

# List of column names to strip whitespace from
columns_to_strip = ['id', 'time', 'value', 'formatted_time', 'activity_day', 'time_of_day', 'weekday', 'id_length']

# Strip leading and trailing whitespace from specified columns
df[columns_to_strip] = df[columns_to_strip].astype(str).apply(lambda x: x.str.strip())

# Remove rows with null or NA values
df_cleaned = df.dropna()

# Remove duplicates
df_cleaned = df.drop_duplicates()

# Sort by 'id', 'date', and 'time_of_day' in descending order
df_sorted = df_cleaned.sort_values(by=['id', 'activity_day', 'time_of_day'], ascending=[False, False, False])

# Print the cleaned DataFrame
print(df_cleaned)

#Uncomment to convert to csv
#df_cleaned.to_csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 2 - Bellabeat/Data/Clean Data/heartrate_seconds_merged_clean.csv', index=False)