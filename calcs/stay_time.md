# Stay Time Calculation

The **Stay Time** tool is an essential practical measure in Health Physics and ALARA (As Low As Reasonably Achievable) principles. It computes the maximum permissible time a worker can remain in a known radiation field without breaching their allowable dose quota. 

## Formula
```math
\text{Stay Time} = \frac{\text{Allowable Exposure}}{\text{Exposure Rate}}
```

*(Note: The internal application accounts for time-unit conversions seamlessly behind the scenes, outputting standard seconds/minutes as required)*

### Variables
- **Stay Time:** Total safe duration threshold in the work zone.
- **Allowable Exposure:** The defined dose limit cap established by regulatory guidelines or specific working permissions.
- **Exposure Rate:** The physical rate of radiation exposure measured dynamically in the area.

## Features
1. **Stay Time:** Automatically calculates the max limits for a worker given total exposure allowable limits. 
2. **Allowable Exposure:** Verifies the cumulative dose an individual will incur mathematically if they stay for a defined extended period.
3. **Exposure Rate:** Extracts what the theoretical area field strength limit is allowed to be if a task requires exactly X hours to perform but is limited to Y allowable accumulated exposure.
