const int lightPin = 2;
const int laserPin = 3;
const int fansPin = 4;
const int speechPin = 10;
const int pirPin = 9;

const int transistorPinVibHand = 5;
const int transistorPinVibBack = 6;
#define NOFIELD 660L    // Analog output with no applied field, calibrate this


const int thumbPin = A1;
const int pointerPin = A2; 
const int pinkyPin = A3;
const int hallPin = A5;

int oldThumbPos = -1;
int oldPointerPos = -1;
int oldPinkyPos = -1;

const int POS_OPEN = 0;
const int POS_MIDDLE = 1;
const int POS_CLOSE = 2;

int calibratedHall = 0;

String command = "";
int speechState = LOW;

void setup() {
  Serial.begin(115200);
    
  pinMode(lightPin, OUTPUT);
  pinMode(13, OUTPUT);
//  digitalWrite(lightPin, HIGH);
  digitalWrite(13, HIGH);
  pinMode(laserPin, OUTPUT);
  pinMode(fansPin, OUTPUT);
  
  pinMode(transistorPinVibHand, OUTPUT);
  pinMode(transistorPinVibBack, OUTPUT);
  
  pinMode(speechPin, INPUT);
  
  pinMode(pirPin, INPUT);
  
  delay(2000);
  calibratedHall = analogRead(hallPin);
  delay(2000);

}

void loop() {
  while (Serial.available() > 0) {
    char c = Serial.read();
    
    if (c == '\n') {
      doCommand();
    } else {
      command = command + c;
    }
  }

//  int value = analogRead(A1);
//  Serial.println(value);
  
  int oldSpeechState = speechState;
  speechState = digitalRead(speechPin);
//  dprintln(speechState);
  if (speechState != oldSpeechState) {
    if (speechState == HIGH) {
      digitalWrite(lightPin, HIGH);
      sendMsg("start_speech");
    } else {
      digitalWrite(lightPin, LOW);
      sendMsg("stop_speech");    
    }
  }
  
  detectFingers();
  doMagnetRead();
  
  detectMotion();

  delay(500);
}

void detectFingers() {
  int thumb = analogRead(thumbPin);
  int pointer = analogRead(pointerPin);
  int pinky = analogRead(pinkyPin);
  
  dprint("Thumb:   ");
  dprint(thumb);
  dprint("    Pointer: ");
  dprint(pointer);
  dprint("    Pinky:   ");
  dprintln(pinky);

  int thumbPos, pointerPos, pinkyPos;
  if (thumb > 470)
    thumbPos = POS_OPEN;
  else if (thumb > 390)
    thumbPos = POS_MIDDLE;
  else
    thumbPos = POS_CLOSE;

  if (pointer > 470)
    pointerPos = POS_OPEN;
  else if (pointer > 390)
    pointerPos = POS_MIDDLE;
  else
    pointerPos = POS_CLOSE;
  
  if (pinky > 500)
    pinkyPos = POS_OPEN;
  else if (pinky > 460)
    pinkyPos = POS_MIDDLE;
  else
    pinkyPos = POS_CLOSE;
  
  if ((thumbPos != oldThumbPos) || (pointerPos != oldPointerPos) || (pinkyPos != oldPinkyPos)) {
    
    if ((thumbPos == POS_OPEN) && (pointerPos == POS_OPEN) && (pinkyPos == POS_OPEN)) {
      dprintln("\neverything off");
      digitalWrite(lightPin, LOW);
      digitalWrite(laserPin, LOW);
      digitalWrite(fansPin, LOW);
    } else if ((thumbPos == POS_CLOSE) && (pointerPos == POS_CLOSE) && (pinkyPos == POS_CLOSE)) {
      dprintln("\nfan on");
      digitalWrite(lightPin, LOW);
      digitalWrite(laserPin, LOW);
      digitalWrite(fansPin, HIGH);
    } else if ((thumbPos == POS_MIDDLE) && (pointerPos == POS_MIDDLE) && (pinkyPos == POS_MIDDLE)) {
      dprintln("\nlight on");
      digitalWrite(lightPin, HIGH);
      digitalWrite(laserPin, LOW);
      digitalWrite(fansPin, LOW);
    } else if ((thumbPos == POS_CLOSE) && (pointerPos == POS_OPEN) && (pinkyPos == POS_CLOSE)) {
      dprintln("\nlaser on");
      digitalWrite(lightPin, LOW);
      digitalWrite(laserPin, HIGH);
      digitalWrite(fansPin, LOW);
    } else if ((thumbPos == POS_OPEN) && (pointerPos == POS_OPEN) && (pinkyPos == POS_CLOSE)) {
      dprintln("\ntrigger");
      digitalWrite(lightPin, LOW);
      digitalWrite(laserPin, LOW);
      digitalWrite(fansPin, LOW);
    }
    
    oldThumbPos = thumbPos;
    oldPointerPos = pointerPos;
    oldPinkyPos = pinkyPos;
    
    String msg = "hand:";
    msg.concat(thumbPos);
    msg.concat(",");
    msg.concat(pointerPos);
    msg.concat(",");
    msg.concat(pinkyPos);
    sendMsg(msg);
  }
}

int doneMagnet = 0;

void doMagnetRead() {
// measure magnetic field
  int raw = analogRead(hallPin);   // Range : 0..1024

//  Uncomment this to get a raw reading for calibration of no-field point
//  Serial.print("Raw reading: ");
//  Serial.println(raw);

  long compensated = raw;// - NOFIELD;                 // adjust relative to no applied field 
  long gauss = compensated ;//* TOMILLIGAUSS / 1000;   // adjust scale to Gauss

//  Serial.print(gauss);
//  Serial.println(" Gauss ");

  dprint(gauss);
  dprint(", ");
  dprintln(calibratedHall);
  
//  if (gauss > 13 || gauss < 11) {
  if (!doneMagnet && (((gauss - calibratedHall) > 10) || ((gauss - calibratedHall) < -10))) {
//    Serial.println("Detected!!!!");
    sendMsg("magnet");
    doneMagnet = 1;
    digitalWrite(transistorPinVibHand, HIGH);
    delay(200);
    digitalWrite(transistorPinVibHand, LOW);
  } else {
//    Serial.println("Nothing detected");
  }
}

void detectMotion() {
  int pirState = digitalRead(pirPin);
  dprint("PIR: ");
  dprintln(pirState);
  
  if (pirState == HIGH) {
    sendMsg("motion");
    digitalWrite(transistorPinVibBack, HIGH);
    delay(200);
    digitalWrite(transistorPinVibBack, LOW);
  }
}

void doCommand() {
  if (command.equals("light_on")) {
    digitalWrite(lightPin, HIGH);
  } else if (command.equals("light_off")) {
    digitalWrite(lightPin, LOW);
  }
  
  command = "";
//  Serial.println("done");
}

void dprint(String msg) {
//  Serial.print(msg);
}

void dprint(int val) {
//  Serial.print(val);
}

void dprintln(String msg) {
//  Serial.println(msg);
}

void dprintln(int msg) {
//  Serial.println(msg);
}

void sendMsg(String msg) {
  Serial.println(msg);
}

