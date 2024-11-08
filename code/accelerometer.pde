import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import java.util.ArrayList;

SensorManager sensorManager;
Sensor accelerometer;
AccelerometerListener accelerometerListener;

// Variables to store accelerometer values
float xAccel, yAccel, zAccel;

// ArrayLists to store history of accelerometer data for plotting
ArrayList<Float> xHistory = new ArrayList<Float>();
ArrayList<Float> yHistory = new ArrayList<Float>();
ArrayList<Float> zHistory = new ArrayList<Float>();

// Maximum number of data points to display in the plot
int maxDataPoints = 100;

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

// Custom accelerometer listener class
class AccelerometerListener implements SensorEventListener {
  @Override
  public void onSensorChanged(SensorEvent event) {
    xAccel = event.values[0];
    yAccel = event.values[1];
    zAccel = event.values[2];
  }

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
    // Not used, but required to implement
  }
}

void onDestroy() {
  // Unregister the sensor listener when the app is closed
  if (sensorManager != null && accelerometerListener != null) {
    sensorManager.unregisterListener(accelerometerListener);
  }
}
