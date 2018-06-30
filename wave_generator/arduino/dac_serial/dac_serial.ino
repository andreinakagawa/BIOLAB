/*
 * ----------------------------------------
 * FEDERAL UNIVERSITY OF UBERLANDIA
 * Faculty of Electrical Engineering
 * Biomedical Engineering Lab
 * Uberlandia, Brazil
 * ----------------------------------------
 * Author: Andrei Nakagawa-Silva, MSc
 * contact: andrei.ufu@gmail.com
 * ----------------------------------------
 */
//-----------------------------------------
//LIBRARIES
#include <Wire.h>
#include <Adafruit_MCP4725.h>
//-----------------------------------------
//DEFINES
#define ledPin 13
#define dacAddr 0x60
#define baud 115200
#define PKG_ST 0x24
#define PKG_ET 0x21
#define PKG_SIZE 4
#define numBytes 2
//-----------------------------------------
//VARIABLES
Adafruit_MCP4725 dac;
//-----------------------------------------
uint8_t* receivePackage()
{
  uint8_t package[PKG_SIZE] = {0,0,0,0};
  uint8_t incByte = 0;
  if(Serial.available())
  {
    //reads one byte from the serial buffer
    incByte = Serial.read();
    //if the byte corresponds to the header
    if(incByte == PKG_ST)
    {
      package[0] = PKG_ST;
      
      //for debugging
      //Serial.println("READ THE HEADER!");
      
      //waits until a complete package in the serial buffer is available
      while(Serial.available() < numBytes)
      {
        //for debugging purposes
        //Serial.println("waiting...");
      }      
      
      //once the amount of bytes are available, read all of them
      //byte by byte and store them in the package buffer
      for(int i=0; i<numBytes+1; i++)
      {
        package[i+1] = Serial.read();
        Serial.println(package[i+1]); //debugging
      }

      //Checks if the last byte corresponds to the end of the buffer
      //if it is, then the package can be validated
      //otherwise, it returns a NULL pointer
      if(package[PKG_SIZE-1] == PKG_ET)
      {
        //for debugging purposes
        Serial.println("PACKAGE OK!");  
        Serial.println(String(package[0]) + " " + String(package[1]) + " " + String(package[2]) + " " + String(package[3]));
        return package;
      }
      else
        return NULL;
    }
    else
      return NULL;
  }
  else
    return NULL;
}
//-----------------------------------------
void setup() {
  // put your setup code here, to run once:
  //serial
  Serial.begin(baud);
  pinMode(ledPin,OUTPUT);
  //write a given value to the DAC
  dac.begin(dacAddr);
  uint16_t v = 0;
  dac.setVoltage(v,false);
}
//-----------------------------------------
void loop() {
  // put your main code here, to run repeatedly:
  uint8_t* inpckg = receivePackage();
  if(inpckg != NULL)
  {
    digitalWrite(ledPin,HIGH);
    uint16_t sample = inpckg[1]<<8 | inpckg[2];
    //Serial.println(sample);
    dac.setVoltage(sample,false);
  }
}
//-----------------------------------------
