$webhookUrl = "YOUR_WEBHOOK_URL" # Replace with your webhook URL

# Replace the following line with the code that generates your script output
$output = "This is the output of my script"

# Create a JSON payload with the output
$message = @{
    "@type"      = "MessageCard"
    "@context"   = "http://schema.org/extensions"
    "text"       = $output
} | ConvertTo-Json

# Send the JSON payload to the webhook URL
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $message -ContentType "application/json"
