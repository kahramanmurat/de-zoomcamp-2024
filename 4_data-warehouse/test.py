import os
import requests
from bs4 import BeautifulSoup
import re

# Function to download file from URL to a specified folder
def download_file(url, folder):
    filename = os.path.join(folder, os.path.basename(url))
    with open(filename, 'wb') as f:
        response = requests.get(url)
        f.write(response.content)
    return filename

# URL of the webpage
url = 'https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page'

# Patterns for file URLs
patterns = {
    'green_tripdata': ['green_tripdata_2019', 'green_tripdata_2020'],
    'yellow_tripdata': ['yellow_tripdata_2019', 'yellow_tripdata_2020'],
    'fhv_tripdata': ['fhv_tripdata_2019', 'fhv_tripdata_2020']
}

# Local folder path to save the downloaded files
local_folder = "data"  # Modify this to your desired local folder path

# Create folders for each type of trip data
for folder in patterns.keys():
    folder_path = os.path.join(local_folder, folder)
    os.makedirs(folder_path, exist_ok=True)

# Fetch webpage content
response = requests.get(url)
soup = BeautifulSoup(response.content, 'html.parser')

# Find all links on the webpage
links = soup.find_all('a', href=True)

# Iterate over links to find matching URLs and download them
for link in links:
    href = link['href']
    for folder, file_patterns in patterns.items():
        for pattern in file_patterns:
            if re.search(pattern, href):
                print(f"Downloading {href} to {folder} folder...")
                folder_path = os.path.join(local_folder, folder)
                file_url = href if href.startswith('http') else url + href
                download_file(file_url, folder_path)
                break

print("Downloads completed.")
