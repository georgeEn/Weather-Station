#include <dht.h>
#include <LiquidCrystal.h>
#include <ArduinoMqttClient.h>
#include <WiFiNINA.h>
#include <SPI.h>
#include "arduino_secrets.h"
#define dht_apin A0 // Analog Pin sensor is connected to

char ssid[] = SECRET_SSID;        // your network SSID (name)
char pass[] = SECRET_PASS;    // your network password (use for WPA, or use as key for WEP
const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

WiFiClient wifiClient;
MqttClient mqttClient(wifiClient);

const char broker[] = "192.168.2.148";
int        port     = 1883;
const char topic[]  = "Sensor";
const char topic2[]  = "Temperature";
const char topic3[]  = "Humidity";
int status = WL_IDLE_STATUS;
 
dht DHT;
 
void setup(){
  lcd.begin(16, 2);
  Serial.begin(9600);
  Serial.println("DHT11 Humidity & temperature Sensor\n\n");
  delay(500);//Wait before accessing Sensor

  // check for the WiFi module:
  if (WiFi.status() == WL_NO_MODULE) {
    Serial.println("Communication with WiFi module failed!");
    // don't continue
    while (true);
  }

  String fv = WiFi.firmwareVersion();
  if (fv < WIFI_FIRMWARE_LATEST_VERSION) {
    Serial.println("Please upgrade the firmware");
  }

  // attempt to connect to WiFi network:
  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network:
    status = WiFi.begin(ssid, pass);
    

    // wait 10 seconds for connection:
    delay(10000);
  }

  mqttClient.connect(broker, port);
  if (!mqttClient.connect(broker, port)) {
   Serial.print("MQTT connection failed! Error code = ");
   Serial.println(mqttClient.connectError());
   while (1);
 }
 
}
 
void loop(){
  DHT.read11(dht_apin);

  if (DHT.temperature>25){
    digitalWrite(10,HIGH);
    delay(2000);
    digitalWrite(10,LOW);
  }else{
    digitalWrite(7,HIGH);
    delay(2000);
    digitalWrite(7,LOW);
  }
  
  
  //Print sensor data on MQTT subscriber
  mqttClient.beginMessage(topic);
  mqttClient.print("The temperature is: ");
  mqttClient.print(DHT.temperature);
  mqttClient.print("°C and the humidity is: ");
  mqttClient.print(DHT.humidity);
  mqttClient.print("%");
  mqttClient.endMessage();
  
  //Plot Temperature on MQTT subscriber
  mqttClient.beginMessage(topic2);
  mqttClient.print(DHT.temperature);
  mqttClient.endMessage();
  
  //Plot Humidity on MQTT subscriber
  mqttClient.beginMessage(topic3);
  mqttClient.print(DHT.humidity);
  mqttClient.endMessage();

  //Print on LCD
 lcd.setCursor(0, 0);
 lcd.print("Temp: ");
 lcd.print(DHT.temperature);
 lcd.print("C");
 lcd.setCursor(0, 1);
 lcd.print("Humidity: ");
 lcd.print(DHT.humidity);
 lcd.print("%");

delay(1000);
}
