#include <Wire.h> // Include the Wire library for I2C communication

// Define the I2C address of your heart rate sensor
#define SENSOR_ADDRESS 0x50 // Replace 0x57 with your sensor's I2C address

void setup() {
  Wire.begin(); // Start the I2C communication
  Serial.begin(9600); // Start serial communication at 9600 bps

  // Initialize the sensor if needed (depends on your specific sensor)
  initializeSensor();
}

void loop() {
  int heartRate = readHeartRate();

  // Print the heart rate value to the serial monitor
  Serial.print("Heart Rate: ");
  Serial.print(heartRate);
  Serial.println(" BPM");

  delay(1000); // Wait 1 second between readings
}

// Function to initialize the sensor (varies by sensor)
void initializeSensor() {
  Wire.beginTransmission(SENSOR_ADDRESS);
  // Add any specific initialization commands for your sensor here
  Wire.endTransmission();
}

// Function to read heart rate from the sensor
int readHeartRate() {
  Wire.beginTransmission(SENSOR_ADDRESS);
  Wire.write(0x00); // Replace 0x00 with the appropriate register for heart rate data
  Wire.endTransmission();
  
  Wire.requestFrom(SENSOR_ADDRESS, 1); // Request 1 byte (or more if needed) from the sensor

  if (Wire.available()) {
    int heartRate = Wire.read(); // Read heart rate value
    return heartRate;
  }
  
  return 0; // Return 0 if no data is available
}
