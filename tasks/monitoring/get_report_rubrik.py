import argparse
import datetime
import requests

# Set your Rubrik API key or credentials here
RUBRIK_API_KEY = "your_api_key_here"

# Define the Rubrik API endpoint for downloading CSV reports
RUBRIK_REPORT_API = "https://your_rubrik_instance/api/v1/report/download"

# Parse command-line arguments for the time interval
parser = argparse.ArgumentParser(description="Download CSV report from Rubrik")
parser.add_argument("--start-date", type=str, required=True, help="Start date in YYYY-MM-DD format")
parser.add_argument("--end-date", type=str, required=True, help="End date in YYYY-MM-DD format")
args = parser.parse_args()

# Calculate the time interval
start_date = datetime.datetime.strptime(args.start_date, "%Y-%m-%d")
end_date = datetime.datetime.strptime(args.end_date, "%Y-%m-%d")
time_interval = (end_date - start_date).days

# Set the necessary headers for authentication
headers = {
    "Authorization": f"Bearer {RUBRIK_API_KEY}"
}

# Make the API call to download the CSV report
response = requests.get(
    RUBRIK_REPORT_API,
    headers=headers,
    params={
        "start_date": start_date.strftime("%Y-%m-%dT%H:%M:%S"),
        "end_date": end_date.strftime("%Y-%m-%dT%H:%M:%S"),
        "time_interval": time_interval,
    },
)

# Check for errors in the response
response.raise_for_status()

# Save the CSV report to a file
with open(f"rubrik_report_{args.start_date}_to_{args.end_date}.csv", "wb") as f:
    f.write(response.content)

print(f"Downloaded CSV report for the time interval {args.start_date} to {args.end_date}")
