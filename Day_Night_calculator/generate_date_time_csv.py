import pandas as pd
from astral.sun import sun
from astral import LocationInfo
from datetime import datetime, timedelta

# Define NYC location
location = LocationInfo("New York", "USA", "America/New_York", 40.7128, -74.0060)

# Generate sunrise & sunset times for a full year
start_date = datetime(2015, 1, 1)  # Change year if needed
end_date = datetime(2018, 1, 1)

date_list = []
sunrise_list = []
sunset_list = []
# Loop through each day in the range
current_date = start_date
while current_date < end_date:
    try:
        s = sun(location.observer, date=current_date, tzinfo=location.timezone)
        date_list.append(current_date.date())
        sunrise_list.append(s["sunrise"].strftime("%H:%M"))  # Store sunrise
        sunset_list.append(s["sunset"].strftime("%H:%M"))    # Store sunset
    except Exception as e:
        print(f"Error on {current_date}: {e}")  # Debugging message
        sunrise_list.append(None)
        sunset_list.append(None)
    
    current_date += timedelta(days=1)

# Create DataFrame
df = pd.DataFrame({"Date": date_list, "Sunrise": sunrise_list, "Sunset": sunset_list})

# Save to CSV
df.to_csv("sunrise_sunset_nyc.csv", index=False)
print("CSV file created: sunrise_sunset_nyc.csv")