/*---------------------------------------------------
 * FEDERAL UNIVERSITY OF UBERLÂNDIA - UFU
 * FACULTY OF ELECTRICAL ENGINEERING - FEELT 
 * BIOMEDICAL ENGINEERING LAB - BIOLAB
 * Uberlândia, Brazil
 *---------------------------------------------------
 * Author: Andrei Nakagawa-Silva
 * Contact: nakagawa.andrei@gmail.com
 * URL: www.biolab.eletrica.ufu.br
  *---------------------------------------------------
 * Description: This Arduino sketch serves as DAQ 
 * system. Analog data to be converted should be
 * input to pin A0.
 *---------------------------------------------------
 * TO-DO: Use a timer interrupt to send data
 *---------------------------------------------------
*/
//---------------------------------------------------
//DEFINES
#define PKG_ST '$'
#define PKG_ET '!'
//---------------------------------------------------
//VARIABLES
uint16_t adSample = 0; //adc value
uint8_t adMSB = 0; //adc msb
uint8_t adLSB = 0; //adc lsb
uint8_t packet[4] = {0,0,0,0}; //serial packet
//---------------------------------------------------
void setup() {  
  Serial.begin(38400); //initializes serial
}

void loop() {  
  adSample = analogRead(A0); //reads the ADC channel
  adMSB = adSample>>8; //retrieves msb
  adLSB = adSample&0x0F; //retrieves lsb
  //mounts the serial packet
  packet[0] = PKG_ST; //header
  packet[1] = adMSB; //data msb
  packet[2] = adLSB; //data lsb
  packet[3] = PKG_ET; //end of packet
  Serial.write(packet,sizeof(packet)); //sends the packet via serial
  delay(100); //sampling period: 10ms = 100 Hz
}
