#include <ESP8266WiFi.h>
#include <PubSubClient.h>
 
const char* ssid = "YourSSID";
const char* password =  "PAssword";
const char* mqttServer = "MQTT_URL";
const int mqttPort = PORT  ;
const char* mqttUser = "USERNAME";
const char* mqttPassword = "PASSWORD";
 
WiFiClient espClient;
PubSubClient client(espClient);
 
void setup() {
 
  Serial.begin(115200);
 
  WiFi.begin(ssid, password);
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");
 
  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);
 
  while (!client.connected()) {
    Serial.println("Connecting to MQTT...");
 
    if (client.connect("ESP8266Client", mqttUser, mqttPassword )) {
 
      Serial.println("connected");  
 
    } else {
 
      Serial.print("failed with state ");
      Serial.print(client.state());
      delay(2000);
 
    }
  }
 
 // client.publish("esp/test", "Hello from ESP8266");
 // client.subscribe("esp/test");
 
}
 
void callback(char* topic, byte* payload, unsigned int length) {
 
  Serial.print("Message arrived in topic: ");
  Serial.println(topic);
 
  Serial.print("Message:");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
 
  Serial.println();
  Serial.println("-----------------------");
 
}
 
void loop() {
  client.loop();
  Serial.println("scan start");
  String networkd="";
  // WiFi.scanNetworks will return the number of networks found
  int n = WiFi.scanNetworks();
  Serial.println("scan done");
  if (n == 0) {
    networkd+="no networks found";
  } else {
        networkd.concat("[");
    for (int i = 0; i < n; ++i) {
      // Print SSID and RSSI for each network found
      networkd.concat("{\"id\":");
      networkd.concat((i + 1));
      networkd.concat("\",");
      networkd.concat(" \"ssid\":");
      networkd.concat(WiFi.SSID(i));
      networkd.concat(",\"rssi\":");
      networkd.concat(WiFi.RSSI(i));
      networkd.concat(",\"encType\":");
      networkd.concat((WiFi.encryptionType(i) == ENC_TYPE_NONE) ? " " : "*");
      networkd.concat("}");
      if(i!=n-1)
      networkd.concat(",");
    }
    networkd.concat("]");
    
  
  }
    delay(100);
    client.publish("esp/test",   networkd.c_str());
}
