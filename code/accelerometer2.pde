import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import java.util.ArrayList;

SensorManager sensorManager;
Sensor accelerometer;
class AccelerometerListener implements SensorEventListener {
    @Override
    public void onSensorChanged(SensorEvent event) {
        if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
            xAccel = event.values[0];
            yAccel = event.values[1];
            zAccel = event.values[2];
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        // Not used
    }
}

AccelerometerListener accelerometerListener;

// Variables to store accelerometer values
float xAccel, yAccel, zAccel;

// ArrayLists to store history of accelerometer data for plotting
ArrayList<Float> xHistory = new ArrayList<Float>();
ArrayList<Float> yHistory = new ArrayList<Float>();
ArrayList<Float> zHistory = new ArrayList<Float>();

// ArrayList to store timestamps of detected peaks
ArrayList<Long> peakTimestamps = new ArrayList<Long>();

// Maximum number of data points to display in the plot
int maxDataPoints = 100;

// Threshold for peak detection
float peakThreshold = 15.0;

// Minimum time interval between peaks (in milliseconds)
long minPeakInterval = 300;

void setup() {
    fullScreen();
    textSize(80);
    fill(255);

    // Initialize the sensor manager and accelerometer
    sensorManager = (SensorManager) getActivity().getSystemService(Context.SENSOR_SERVICE);
    accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
    
    // Check if the accelerometer is available
    if (accelerometer != null) {
        accelerometerListener = new AccelerometerListener();
        sensorManager.registerListener(accelerometerListener, accelerometer, SensorManager.SENSOR_DELAY_UI);
        orientation(PORTRAIT);  // Lock to portrait mode for easier viewing
    } else {
        println("No accelerometer found.");
    }
}

void draw() {
    background(0);

    // Draw accelerometer values as text
    text("Accelerometer Data:", 10, 30);
    text("X: " + nf(xAccel, 1, 2), 10, 60);
    text("Y: " + nf(yAccel, 1, 2), 10, 90);
    text("Z: " + nf(zAccel, 1, 2), 10, 120);

    // Update history arrays with new values
    updateHistory(xAccel, yAccel, zAccel);

    // Detect peaks in the accelerometer data
    detectPeaks(zAccel);

    // Calculate and display stride rate
    float strideRate = calculateStrideRate();
    text("Stride Rate: " + nf(strideRate, 1, 2) + " steps/min", 10, 150);

    // Draw the plot for each axis
    drawPlot(xHistory, color(255, 51, 51), height / 2 - 100);  // X-axis in red
    drawPlot(yHistory, color(51, 255, 51), height / 2);        // Y-axis in green
    drawPlot(zHistory, color(51, 153, 255), height / 2 + 100);  // Z-axis in blue
}

// Update history arrays and maintain maximum length
void updateHistory(float x, float y, float z) {
    xHistory.add(x);
    yHistory.add(y);
    zHistory.add(z);

    // Trim history if it exceeds maximum points
    if (xHistory.size() > maxDataPoints) xHistory.remove(0);
    if (yHistory.size() > maxDataPoints) yHistory.remove(0);
    if (zHistory.size() > maxDataPoints) zHistory.remove(0);
}

// Function to draw the history plot for a given axis
void drawPlot(ArrayList<Float> history, int col, float yOffset) {
    stroke(col);
    noFill();

    // Draw line plot
    beginShape();
    for (int i = 0; i < history.size(); i++) {
        float x = map(i, 0, maxDataPoints, 0, width);
        float y = map(history.get(i), -10, 10, yOffset + 50, yOffset - 50);
        vertex(x, y);
    }
    endShape();
}

// Function to detect peaks in the accelerometer data
void detectPeaks(float z) {
    long currentTime = millis();
    if (z > peakThreshold) {
        if (peakTimestamps.size() == 0 || (currentTime - peakTimestamps.get(peakTimestamps.size() - 1)) > minPeakInterval) {
            peakTimestamps.add(currentTime);
        }
    }
}

// Function to calculate stride rate
float calculateStrideRate() {
    if (peakTimestamps.size() < 2) {
        return 0;
    }

    // Define the time window for recent peaks (e.g., last 10 seconds)
    long currentTime = millis();
    long timeWindow = 10000; // 10 seconds

    // Filter peak timestamps within the time window
    ArrayList<Long> recentPeaks = new ArrayList<Long>();
    for (Long timestamp : peakTimestamps) {
        if (currentTime - timestamp <= timeWindow) {
            recentPeaks.add(timestamp);
        }
    }

    if (recentPeaks.size() < 2) {
        return 0;
    }

    // Calculate time intervals between recent peaks
    ArrayList<Long> intervals = new ArrayList<Long>();
    for (int i = 1; i < recentPeaks.size(); i++) {
        intervals.add(recentPeaks.get(i) - recentPeaks.get(i - 1));
    }

    // Calculate average interval
    long totalInterval = 0;
    for (Long interval : intervals) {
        totalInterval += interval;
    }
    float averageInterval = totalInterval / (float) intervals.size();

    // Calculate stride rate (steps per minute)
    float strideRate = 60000 / averageInterval;
    return strideRate;
}

