// Watchman wearable sketch — ESP32 + GNSS + BLE notify
// Libraries: TinyGPSPlus, NimBLE-Arduino
// Wiring: GPS TX -> GPIO16, SOS button -> GPIO0 to GND

#include <NimBLEDevice.h>
#include <TinyGPSPlus.h>

#define SERVICE_UUID        "7e0b0001-5741-5443-484d-4b5730310001"
#define CHAR_FIX_UUID       "7e0b0002-5741-5443-484d-4b5730310001"
#define CHAR_PIN_UUID       "7e0b0003-5741-5443-484d-4b5730310001"
#define CHAR_SOS_UUID       "7e0b0004-5741-5443-484d-4b5730310001"

TinyGPSPlus gps;
HardwareSerial GPSSerial(2);

NimBLECharacteristic* fixChar;
NimBLECharacteristic* sosChar;
bool paired = false;

const int SOS_PIN = 0;
bool lastSos = false;

class PinCallbacks : public NimBLECharacteristicCallbacks {
  void onWrite(NimBLECharacteristic* c) {
    std::string v = c->getValue();
    if (v.size() == 6) {
      paired = true;
      Serial.println("Watchman paired");
    }
  }
};

void setup() {
  Serial.begin(115200);
  GPSSerial.begin(9600, SERIAL_8N1, 16, 17);
  pinMode(SOS_PIN, INPUT_PULLUP);

  NimBLEDevice::init("Watchman");
  NimBLEDevice::setSecurityAuth(true, true, true);

  NimBLEServer* server = NimBLEDevice::createServer();
  NimBLEService* service = server->createService(SERVICE_UUID);

  fixChar = service->createCharacteristic(
      CHAR_FIX_UUID,
      NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);

  NimBLECharacteristic* pinChar = service->createCharacteristic(
      CHAR_PIN_UUID,
      NIMBLE_PROPERTY::WRITE);
  pinChar->setCallbacks(new PinCallbacks());

  sosChar = service->createCharacteristic(
      CHAR_SOS_UUID,
      NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);

  service->start();
  NimBLEAdvertising* adv = NimBLEDevice::getAdvertising();
  adv->addServiceUUID(SERVICE_UUID);
  adv->start();
}

void loop() {
  while (GPSSerial.available()) {
    gps.encode(GPSSerial.read());
  }

  bool sos = digitalRead(SOS_PIN) == LOW;
  if (sos && !lastSos && paired) {
    sosChar->setValue("SOS");
    sosChar->notify();
  }
  lastSos = sos;

  static unsigned long last = 0;
  if (paired && gps.location.isValid() && millis() - last > 4000) {
    last = millis();
    char buf[64];
    snprintf(buf, sizeof(buf), "%.6f,%.6f,%d",
             gps.location.lat(),
             gps.location.lng(),
             86);
    fixChar->setValue((uint8_t*)buf, strlen(buf));
    fixChar->notify();
  }
}
