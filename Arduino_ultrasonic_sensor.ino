/* ARDUINO CODE FOR THE ULTRASONIC ARDUINO-BASED PLANT HEIGHT MEASUREMENT DEVICE */

////////////////////////////////////////////////////////
/// Parameters ///
////////////////////////////////////////////////////////

/* Loading libraries */

#include <SPI.h> // interaction with the SD card
#include <SD.h> // interaction with the SD card
#include <LiquidCrystal.h> // interaction with the LCD screen

/* Pin parametrization */
const int pinInt = 0; // pin for shield buttons
const int pinTrig = 2; // pin for the ultrasonic transmitter
const int pinEch = 3; // pin for the ultrasonic receptor
const int pinSD = 19; // pin for the SD card (pin 5 is converted from analog to digital)
const byte BACKLIGHT_PWM_PIN = 10; // pin for controlling the backlighting of the LCD display

/* Variable initialization */
LiquidCrystal lcd(8, 9, 4, 5, 6, 7); // Defining LCD pins
int int_status = 0; // the swtich which triggers measurements is turned off by default
int num_row = 0; // the.csv file on the SD card will be read line-by-line and we start with a 0 value for calibration
String zero = "0"; // one or several "0" will be added as character strings to plant height values so that they always have 4 digits.
int lg_id = 9; // genotypes'IDs have 9 characters
const int lg_row_id = lg_id + 2; // 2 characters are added to account for carriage returns in the .csv file (e.g. EX4X_XXX_XXX_X+ \r\n)
const int lg_row_rec = lg_id + 8; // 8 characters are added to account for the total number of characters in a row: lg_id + 1 (";" = column separator) + 5 (measurements with four digits + ",") + 2 (\r\n)
File height; // Name of the variable used to store the content of the .csv file when open
File record; // Name of the variable used to create a new .csv file to store measurements on the SD card
const unsigned long Timeout = 25000UL; // Defining a timeout, which is the time after which the receptor of the ultrasonic device stops waiting for the return of the sound wave. It is here defined to correspond to a distance of approximately 8m (the sound speed being 340m/s)
const float dist_cali = 1500-100; // Calibration distance (mm), to be defined depending on the position of the sensor on the alluminum stick

/* Defining a function to detect which button is pushed by the operator */
enum {
  BUTTON_NONE,  /*!< NO BUTTON */
  BUTTON_UP,    /*!< UP BUTTON */
  BUTTON_DOWN,  /*!< DOWN BUTTON */
  BUTTON_LEFT,  /*!< LEFT BUTTON */
  BUTTON_RIGHT, /*!< RIGHT BUTTON */
  BUTTON_SELECT /*!< SELECT BUTTON*/
};

byte getPressedButton() {

  /* read the current state of the buttons as an electric voltage */
  int value = analogRead(pinInt);

  /* Depending on the voltage value, retrieve which button is pushed */
  if (value < 50)
    return BUTTON_RIGHT;
  else if (value < 250)
    return BUTTON_UP;
  else if (value < 450)
    return BUTTON_DOWN;
  else if (value < 650)
    return BUTTON_LEFT;
  else if (value < 850)
    return BUTTON_SELECT;
  else
    return BUTTON_NONE;
}


////////////////////////////////////////////////////////
/// SETUP ///
////////////////////////////////////////////////////////

void setup() {

  Serial.begin(115200); // Initializing the serial monitor
  /* Defining pin status (INPUT/OUTPUT) */
  pinMode(pinTrig, OUTPUT);
  pinMode(pinEch, INPUT);
  pinMode(pinInt, INPUT);
  pinMode(pinSD, OUTPUT);

  analogWrite(BACKLIGHT_PWM_PIN, 150); // setting the backlighting intensity of the LCD Display 
  /* Initializing the LCD display */
  lcd.begin(16, 2);
  lcd.print("Init. SD card...");
  lcd.setCursor(0, 1);

  /* Checking the presence of the SD card */
  if (!SD.begin(pinSD)) {
    lcd.print("card failed.");
    return;
  } else {

    lcd.print("card initialized.");
  }

  delay(1000);
  lcd.clear();


  /* Checking the presence of the file with identifiers on the SD card */
  height = SD.open("height.csv", FILE_READ);
  if (height) {
    lcd.print("height.csv");
  } else {
    lcd.print("error");
  }
  height.close();

  delay(1000);
  lcd.clear();


  /* Starting calibration */
  lcd.print("Cali ");

  /* Creating an empty file to store measurement data on the SD Card */
  File record = SD.open("rec.csv", O_WRITE | O_CREAT | O_TRUNC);
  String header = "id_geno;height";
  record.println(header);
  record.close();
}


////////////////////////////////////////////////////////
/// LOOP ///
////////////////////////////////////////////////////////
void loop() {

  /* Calibration*/
  if (num_row == 0) {
     /* Calibration is triggered by pushing the DOWN button */
    if (getPressedButton() == BUTTON_DOWN) {

      /* The trigger pin transmits the sound wave */
      delay(100);
      digitalWrite(pinTrig, HIGH);
      delayMicroseconds(10);
      digitalWrite(pinTrig, LOW);

      /* The speed of the sound is computed de novo based on the time elapsed between transmission and reception of the signal */
      float travel_time = pulseIn(pinEch, HIGH, Timeout); // travel time
      const float vit_son = 2 * 1000 * dist_cali / travel_time; // sound speed

      /* Sound speed is diplayed on the screen */
      lcd.setCursor(6, 0);
      lcd.print(vit_son);
      lcd.print(" m/s");

      /* Sound speed is saved on the SD card */
      File fichier_son = SD.open("vit_son.csv", O_WRITE | O_CREAT | O_TRUNC);
      fichier_son.println(vit_son);
      fichier_son.close();

      num_row++; // Going to the next row in the .csv file with identifiers (here, we go from row 0 (calibration) to row 1 (first measurement))
      lcd.setCursor(0, 1);

      /* The ID of the next measurement is diplayed on the screen */
      int position = (num_row - 1) * lg_row_id;
      height = SD.open("height.csv", FILE_READ);
      height.seek(position);
      String id_geno = height.readStringUntil('\r');
      id_geno.trim();
      height.close();

      lcd.print(id_geno);
      delay(500); // little delay before next measurement
    }

    /* Switching to the acquisition mode when num_row>0 */

  } else {

    /* Acquisition is triggered by pushing the DOWN button */
    if (getPressedButton() == BUTTON_DOWN) {
      lcd.clear();

      /* Retrieving the ID of the plot/genotype to be measured */
      int position = (num_row - 1) * lg_row_id;
      height = SD.open("height.csv", FILE_READ);
      height.seek(position);
      String id_geno = height.readStringUntil('\r');
      id_geno.trim();
      height.close();

      /* Measuring plant height */
      digitalWrite(pinTrig, HIGH);
      delayMicroseconds(10);
      digitalWrite(pinTrig, LOW);
      float travel_time = pulseIn(pinEch, HIGH, Timeout); // travel time
      File fichier_son = SD.open("VIT_SON.csv", FILE_READ);
      float vit_son = fichier_son.parseFloat();
      float ht = ((dist_cali + 100) - (travel_time / 1000 * vit_son / 2)) / 10; // plant height
      String ht_string = String(ht, 1);
      fichier_son.close();


      /* Saving the plant height value on the SD Card */
      /* First, the height value is transformed to have 4 digits */
      int nb = ht_string.length();
      int i = 1;
      while (i <= (4 - (nb - 1))) {
        ht_string = ht_string + zero;
        i++;
      }

      /* The height value is diplayed on the LCD screen together with the ID of the measurement */
      lcd.print(id_geno);
      lcd.print(" ");
      lcd.print(ht_string);

      /* The height value is saved on the SD card */
      record = SD.open("rec.csv", FILE_WRITE);
      int position_rec = (num_row - 1) * lg_row_rec;
      record.seek(position_rec);
      String data = String(id_geno) + ";" + ht_string;
      record.println(data);
      record.close();

      num_row++; // We go to the next row in the identifier file
      lcd.setCursor(0, 1);

      /* Printing the ID of the next measurement */
      int position_suivant = (num_row - 1) * lg_row_id;
      height = SD.open("height.csv", FILE_READ);
      height.seek(position_suivant);
      String id_geno_suivant = height.readStringUntil('\r');
      id_geno_suivant.trim();
      height.close();

      lcd.print(id_geno_suivant);
      delay(500); // little delay before the next acquisition


    } else {

      /* If the error button (UP button) is pushed */
      if (getPressedButton() == BUTTON_UP) {
        lcd.clear();

        /* Printing the ID of the previous measurement */
        num_row--;
        int position_rec = (num_row - 1) * lg_row_rec;
        record = SD.open("rec.csv", FILE_READ);
        record.seek(position_rec);
        String id_geno = record.readStringUntil('\r');
        id_geno.trim();
        id_geno.replace(";", " ");
        lcd.setCursor(0, 1);
        lcd.print(id_geno);
        record.close();
        delay(500);
        /* at the end of this step, the operator pushes the acquisition button (DOWN) to erase the erroneous value and replace it with a new measurement */
      }

      /* If the return button (RIGHT button) is pushed */
      if (getPressedButton() == BUTTON_RIGHT) {
        lcd.clear();

        /* Printing all measurements'IDs from the corrected measurement to the last correct measurement before entering the correction mode */
        int position_rec = (num_row - 1) * lg_row_rec;
        record = SD.open("rec.csv", FILE_READ);
        record.seek(position_rec);
        while (record.available()) {
          String id_geno = record.readStringUntil('\r');
          id_geno.trim();
          id_geno.replace(";", " ");
          lcd.setCursor(0, 0);
          lcd.print(id_geno);
          num_row++;
          delay(200);
        }
        record.close();
        num_row--;
        lcd.setCursor(0, 1);

        /* Printing the ID of the next measurement */
        int position = (num_row - 1) * lg_row_id;
        height = SD.open("height.csv", FILE_READ);
        height.seek(position);
        String id_geno = height.readStringUntil('\r');
        id_geno.trim();
        height.close();

        lcd.print(id_geno);

        delay(500); // Little delay before the next acquisition
      }
    }
  }
}
