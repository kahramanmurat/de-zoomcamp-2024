import requests
from bs4 import BeautifulSoup
import re
import os

# Function to download a file given its URL
def download_file(url, folder_path):
    # Extract the filename from the URL
    filename = url.split('/')[-1]
    # Download the file
    with open(os.path.join(folder_path, filename), 'wb') as f:
        response = requests.get(url)
        f.write(response.content)

url = "https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page"

# Send a GET request to the URL
response = requests.get(url)

# Parse the HTML content
soup = BeautifulSoup(response.text, "html.parser")

# Find all <a> tags (links)
links = soup.find_all("a")

# Define the regex pattern to match links containing a substring similar to "green_trip_data_2022"
pattern = re.compile(r'green_tripdata_2022')

# Iterate through the links and download those containing the pattern
url_list = []
for link in links:
    href = link.get("href")
    if href and pattern.search(href):
        url_list.append(href)
print(url_list)

# Define the folder path where you want to save the files
folder_path = "./green_tripdata_2022"
os.makedirs(folder_path, exist_ok=True)

# Download each file within the folder
for file_url in url_list:
    download_file(file_url, folder_path)

print("Files downloaded successfully to:", folder_path)
