# Attrition Data Analysis for further exploratory data analysis and visualization.
# This script loads employee data, cleans it, and produces several charts
# to explore what factors (department, overtime, income, gender) relate to attrition.

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns


# ─── 1. DATA LOADING ──────────────────────────────────────────────────────────
# Load employee data from a CSV or Excel file.
# pd.read_csv works here because the file content is delimited text despite the .xls extension.

df = pd.read_csv('employee.xls')
print('Data Loaded')
print(df.shape)   # prints (rows, columns)
print(df.head())  # previews the first 5 rows


# ─── 2. INITIAL DATA QUALITY CHECK ────────────────────────────────────────────
# Print count of missing values per column and total number of duplicate rows.
# This gives a quick picture of how much cleaning is needed before analysis.
print(df.isna().sum())
print(df.duplicated().sum())


# ─── 3. OUTLIER REMOVAL (IQR METHOD) ──────────────────────────────────────────
# Replace outliers in numeric columns with NaN using the IQR method.
# The IQR (Interquartile Range) flags values that fall more than 1.5×IQR
# below Q1 or above Q3 — a standard threshold for detecting outliers.

df_copy = df.copy()  # work on a copy to preserve the original data
outlier_cols = df_copy.select_dtypes(include='number').columns.tolist()  # only numeric columns need outlier treatment

for col in outlier_cols:
    Q1 = df_copy[col].quantile(0.25)           # lower quartile
    Q3 = df_copy[col].quantile(0.75)           # upper quartile
    IQR = Q3 - Q1                              # interquartile range
    lower = Q1 - 1.5 * IQR                    # anything below this is an outlier
    upper = Q3 + 1.5 * IQR                    # anything above this is an outlier
    df_copy.loc[(df_copy[col] < lower) | (df_copy[col] > upper), col] = np.nan  # replace outliers with NaN for imputation

print('Outliers Eliminated✅')


# ─── 4. MISSING VALUE IMPUTATION ──────────────────────────────────────────────
# Fill NaN values in numeric columns with the column median.
# This also fills in the NaNs that were just introduced by outlier removal above.

numeric_cols = df_copy.select_dtypes(include='number')
df_copy[numeric_cols.columns] = numeric_cols.fillna(numeric_cols.median().round(2))  # median is robust to skewed distributions
print("NaN values filled with relevant data✅")


# ─── 5. DUPLICATE REMOVAL ─────────────────────────────────────────────────────
# Remove duplicate rows from the DataFrame.
# df: DataFrame that may contain duplicate rows.
# Printing counts before and after confirms that the operation worked.

print("Duplicates before:", df_copy.duplicated().sum())
df_copy.drop_duplicates(inplace=True)  # modifies df_copy in place
print("Duplicates after:", df_copy.duplicated().sum())


# ─── 6. OVERALL ATTRITION RATE ────────────────────────────────────────────────
# Plot the overall attrition rate as a pie chart.
# normalize=True converts raw counts to proportions so the chart shows percentages.

attrition_rate = df_copy['Attrition'].value_counts(normalize=True)  # get proportions (Yes/No)
attrition_rate.plot(kind='pie', autopct='%1.1f%%', startangle=90)
plt.title('Attrition Rate')
plt.ylabel('')  # hide the default y-axis label that matplotlib adds to pie charts
plt.show()


# ─── 7. ATTRITION BY DEPARTMENT ───────────────────────────────────────────────
# Plot the distribution of attrition (Yes) across departments as a pie chart.
# unstack() reshapes the grouped result so 'Yes' and 'No' become separate columns,
# allowing us to plot only the 'Yes' slice for a cleaner department comparison.

attrition_dept = df_copy.groupby(['Department', 'Attrition']).size().unstack()  # pivot so columns are Yes/No
print(attrition_dept)
attrition_dept['Yes'].plot(
    kind='pie', autopct='%1.1f%%', startangle=100, textprops={'fontsize': 9}
)
plt.title('Attrition (Yes) by Department')
plt.ylabel('')  # hide the default y-axis label that matplotlib adds to pie charts
plt.show()

# ─── 8. ATTRITION BY OVERTIME ─────────────────────────────────────────────────
# Do employees who work overtime leave more? Compare attrition rate for OverTime Yes vs No.
# We first filter to only overtime workers, then count their Yes/No attrition split.

attrition_overtime = df_copy[df_copy['OverTime']=='Yes']
attrition_overtime = attrition_overtime['Attrition'].value_counts()
print(attrition_overtime)

attrition_overtime.plot(
    kind='pie', autopct='%1.1f%%', startangle=100, textprops={'fontsize': 9}
)
plt.title('Attrition by OverTime')
plt.ylabel('')  # hide the default y-axis label that matplotlib adds to pie charts
plt.show()

# ─── 9. AVERAGE MONTHLY INCOME BY ATTRITION ───────────────────────────────────
# What is the avg monthly income of employees who left vs stayed?
# avg_income.plot() draws the first bar chart; plt.bar() redraws it so we can
# attach value labels on top of each bar using plt.text().

avg_income = df_copy.groupby('Attrition')['MonthlyIncome'].mean().round(3)
print(avg_income)

avg_income.plot(kind='bar')
bars = plt.bar(avg_income.index, avg_income.values)
for bar in bars:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2,
            height,
            f'{height:.0f}',
            ha='center', va='bottom', fontsize=11, weight='bold')
plt.title('Average Monthly Income by Attrition')
plt.xlabel('Attrition', fontsize=12)
plt.ylabel('Monthly Income', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()
plt.show()

# ─── 10. ATTRITION BY GENDER ──────────────────────────────────────────────────
# What is the attrition based on gender?
# Two side-by-side subplots: left shows overall gender distribution,
# right shows attrition counts broken down by gender using hue.

plt.figure(figsize=(8,6))

ax1 = plt.subplot(1,2,1)
sns.countplot(x='Gender', data=df_copy, ax=ax1)
ax1.set_title('Distribution of Gender')
ax1.set_xlabel('Gender')
ax1.set_ylabel('Count')

# bar_label automatically places the count value on top of each bar
for container in ax1.containers:
    ax1.bar_label(container)


ax2 = plt.subplot(1,2,2)
sns.countplot(x='Attrition', hue='Gender', data=df_copy, ax=ax2, palette='magma')
ax2.set_title('Distribution of Attrition by Gender')
ax2.set_xlabel('Attrition')
ax2.set_ylabel('Count')

# bar_label automatically places the count value on top of each bar
for container in ax2.containers:
    ax2.bar_label(container)

plt.show()
