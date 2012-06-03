/* voltmeter - simple serial voltmeter written by Clarence (blog:
clarence's wicked mind) */


// variables for input pin and control LED
  int analogInput = 1;
  int LEDpin = 13;
  int prev = LOW;
  int refresh = 2000;
  float vout = 0.0;
  float vin = 0.0;
  int seg_digit;
  float R1 = 50000.0;
  float R2 = 4000.0;
  
// variable to store the value
  int value = 0;
  
//                    Arduino pin: 2,3,4,5,6,7,8
byte seven_seg_digits[10][7] = { { 0,1,1,1,1,1,1 },  // = 0
                                 { 0,0,0,1,0,0,1 },  // = 1
                                 { 1,0,1,1,1,1,0 },  // = 2
                                 { 1,0,1,1,0,1,1 },  // = 3
                                 { 1,1,0,1,0,0,1 },  // = 4
                                 { 1,1,1,0,0,1,1 },  // = 5
                                 { 1,1,1,0,1,1,1 },  // = 6
                                 { 0,0,1,1,0,0,1 },  // = 7
                                 { 1,1,1,1,1,1,1 },  // = 8
                                 { 1,1,1,1,0,0,1 }   // = 9
                                };
  
void writeDot(byte dot) {
  digitalWrite(9, dot);
}

void sevenSegWrite(byte digit) {
  byte pin = 2;
  for (byte segCount = 0; segCount < 7; ++segCount) {
    digitalWrite(pin, !seven_seg_digits[digit][segCount]);
    ++pin;
  }
}

void setup()
{
  // declaration of pin modes
  pinMode(analogInput, INPUT);
  pinMode(LEDpin, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);
  
  //begin sending over serial port
  Serial.begin(9600);
}

void loop()
{
  // read the value on analog input
  value = analogRead(analogInput);
  //Serial.print("value=");
  //Serial.println(value);
  
  if (value >= 1023)
  {
    Serial.println("MAX!!");
    delay(refresh);
    return;
  }
  else if (value <= 0)
  {
    Serial.println("MIN!!");
    delay(refresh);
    return;
  }
  
  //blink the LED
  if (prev == LOW)
  {
    prev = HIGH;
  }
  else
  {
    prev = LOW;
  }
  digitalWrite(LEDpin, prev);
  
  // print result over the serial port
  vout = (value * 5.0) / 1024.0;
  vin = vout / (R2/(R1+R2));
  
  //Serial.print("vout=");
  //Serial.println(" volt");
  
  Serial.print(vin);
  Serial.println(" volt");
  
  //write 'one's place' of value to segmented display
  seg_digit = ((int) vin) % 10;
  
  sevenSegWrite(seg_digit);
  writeDot(LOW);
  
  // sleep for half of refresh
  delay(refresh/2);
  
  //write 'tenth's place' of value to segmented display
  seg_digit = ((int) (10.0 * vin)) % 10;
  
  sevenSegWrite(seg_digit);
  writeDot(HIGH);
  
  // sleep for second half of refresh
  delay(refresh/2);
}
