#!/usr/bin/env python3

import pandas as pd

# Read the CSV file
df = pd.read_csv('data/metadata.csv')

# Rename columns
# Format: 'original_column_name': 'new_column_name'
columns_to_keep = {
    'Run': 'ID',
    'Instrument': 'INSTRUMENT',
    'HOST': 'HOST',
    'env_medium': 'SAMPLE_TYPE',
    'Host_age': 'HOST_AGE',
    'host_body_mass_index': 'HOST_BMI',
    'host_height': 'HOST_HEIGHT',
    'host_sex': 'HOST_SEX',
    'host_tot_mass': 'HOST_MASS',
    'Sample Name': 'SAMPLE_NAME',
    'subject': 'SUBJECT',
    'visit': 'VISIT',
    'geo_loc_name_country': 'COUNTRY',
}

# Only select the columns in 'columns_to_keep'
df_selected = df[list(columns_to_keep.keys())].copy()
df_selected = df_selected.rename(columns=columns_to_keep)

# Define the final column order
final_column_order = [
    'ID', 
    'SAMPLE_NAME',
    'SUBJECT',
    'VISIT',
    'SAMPLE_TYPE',
    'HOST',
    'HOST_AGE',
    'HOST_SEX',
    'HOST_BMI',
    'HOST_HEIGHT',
    'HOST_MASS',
    'COUNTRY',
    'INSTRUMENT'
]

# Step 4: Reorder columns (only include columns that exist after selection)
existing_columns = [col for col in final_column_order if col in df_selected.columns]
df_final = df_selected[existing_columns]

# Save as TSV
df_final.to_csv('data/metadata.tsv', sep='\t', index=False)
