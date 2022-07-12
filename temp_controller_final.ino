
#define aref_voltage 3.3         // we tie 3.3V to ARef

int sensorPin = 0; //the analog pin the TMP36's Vout (sense) pin is connected to
                        //the resolution is 10 mV / degree centigrade with a
                        //500 mV offset to allow for negative temperatures
int relay = 6;

int target_temp = 14;  // target temperature
int state = 0;
int num_delay = 0;

float voltage = 0;
int num_to_average = 200;
int seconds_between_toggle = 10;
int delay_between_samples = seconds_between_toggle*1000/num_to_average;

/*
 * setup() - this function runs once when you turn your Arduino on
 * We initialize the serial connection with the computer
 */
void setup()
{
  Serial.begin(9600);  //Start the serial connection with the computer
                       //to view the result open the serial monitor
  Serial.println("CLEARDATA"); //clears up any data left from previous projects
  Serial.println("LABEL,Time,Time Since Start (s),Temperature (C)"); 
  Serial.println("RESETTIMER"); //resets timer to 0
  
  pinMode(relay, OUTPUT);
   
  // If you want to set the aref to something other than 5v
  analogReference(EXTERNAL);
}
 
void loop()                     // run over and over again
{
  Serial.print("DATA,TIME,TIMER,"); //writes the time in the first column A and the time since the measurements started in column B

  //getting the voltage reading from the temperature sensor
  float reading = 0;
  for (int i = 0; i < num_to_average; i++)
  {
    reading += analogRead(sensorPin);
    delay(delay_between_samples);
  }
  reading = reading/num_to_average;

  // converting that reading to voltage, for 3.3v arduino use 3.3
  voltage = reading * aref_voltage;
  voltage /= 1024.0;
  
  // correcting for drop in voltage when relay is on (assuming peltier is plugged in)
  if (state==1)
  {
    voltage = voltage*1.057;
  }
  
  // print out the temperature
  float temperatureC = (voltage - 0.5) * 100 ;  //converting from 10 mv per degree with 500 mV offset
                                               // to degrees ((voltage - 500mV) times 100)
  Serial.println(temperatureC);//Serial.println(" degrees C");
  
  if (num_delay >= 3)
  {
    if (temperatureC > target_temp + 0.25)
    {
      digitalWrite(relay, HIGH);
      state = 1;
      delay(2000);
      num_delay = 0;
    }
    else
    {
      digitalWrite(relay, LOW);
      state = 0;
      delay(2000);
      num_delay = 0;
    }
  }
  else
  {
    num_delay += 1;
  }
}

