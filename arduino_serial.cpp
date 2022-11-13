#include <Arduino.h>

// Define variables
#define pi 3.14
double a = 0;
double f;

void setup() {
  // Initialize serial comunication
  Serial.begin(9600);
}

void loop() {
  // Cal sine function
  a = a + 0.01;
  f = sin(a);

  if (a > (2*pi)) {
    a = 0;
  }
  
  // Send data vea serial communication
  Serial.print(f);
  Serial.print("\n"); // Delimiter
  delay(10);
}
