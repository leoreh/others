/*
  IO box controlling open ephys digital signals.
  LH 07 jun 20

  Functions:
  (1) initPins       initialize pins. Called once during setup.
  (2) cam            send pulse to camera (frame acquisition). called in loop.
  (3) stim           send pulse to stimulator according to pre-defined protocols:
                   1 - IO (0.1 Hz repetitively)
                   2 - LTP (five bursts of 50 x 200 Hz stimulations once a second, repeated six times once a minute
*/

// Fixed parameters:
const float camF = 30;              // camera frequency [Hz]
const int pulseDur = 2;             // output pulse duration [ms]
const int cam_pins[] = {8, 11};
const int stim_pins[] = {9, 12};
const int camSwch_pin = 2;
const int stimSwch_pin = 3;
const int abortSwch_pin = 7;        // force stops ltp stimulation
int stimProtocol = 1;
int rep1, rep2, rep3, i, ii, iii;
float stimF;

void setup() {
  Serial.begin(9600);
  initPins();
}

void loop() {
  int camSwch_val = digitalRead(camSwch_pin);
  int stimSwch_val = digitalRead(stimSwch_pin);
  if (camSwch_val < 1) {
    cam();
  }
  if (stimSwch_val < 1) {
    stim();
  }
}

void initPins() {
  pinMode(camSwch_pin, INPUT_PULLUP);
  pinMode(stimSwch_pin, INPUT_PULLUP);
  pinMode(abortSwch_pin, INPUT_PULLUP);
  for (i = 0; i < 2; i++) {
    pinMode(cam_pins[i], OUTPUT);
  }
  for (i = 0; i < 2; i++) {
    pinMode(stim_pins[i], OUTPUT);
  }
}

void cam() {
  digitalWrite(cam_pins[0], HIGH);
  digitalWrite(cam_pins[1], HIGH);
  delay(pulseDur);
  digitalWrite(cam_pins[0], LOW);
  digitalWrite(cam_pins[1], LOW);
  delay(1 / camF * 1000);
}

void stim() {
  switch (stimProtocol) {
    case 1:     // io
      stimF = 0.1;
      digitalWrite(stim_pins[0], HIGH);
      digitalWrite(stim_pins[1], HIGH);
      delay(pulseDur);
      digitalWrite(stim_pins[0], LOW);
      digitalWrite(stim_pins[1], LOW);
      delay(1 / stimF * 1000);
      break;

    case 2:      // ltp
      rep1 = 6;
      rep2 = 5;
      rep3 = 50;
      stimF = 200;
      for (i = 0; i < rep1; i++) {
        for (ii = 0; ii < rep2; ii++) {
          for (iii = 0; iii < rep3; iii++) {
            digitalWrite(stim_pins[0], HIGH);
            digitalWrite(stim_pins[1], HIGH);
            delay(pulseDur);
            digitalWrite(stim_pins[0], LOW);
            digitalWrite(stim_pins[1], LOW);
            delay(1 / stimF * 1000);
          }
          delay(1000);
          int abortSwch_val = digitalRead(abortSwch_pin);
          if (abortSwch_val < 1) {
            return;
          }
        }
        delay(60000);
      }
      break;

    default:
      break;
  }
}
