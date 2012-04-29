#include <NewSoftSerial.h>  //Include the NewSoftSerial library to send serial commands to the cellular module.
#include <String.h>

boolean pch,atready=false;
int in1=A3;
int in2=A4;
int in3=A5;
int out1=A0;
int out2=A1;
int out3=A2;
int control=2;
char buffer[300];
char index,type;
char string[140];
char number[11];
char nu1[]="From:";
char nu2[]="Msg:";
int firstTimeInLoop = 1;
int j,counter;
char incom=0;      //Will hold the incoming character from the Serial Port.
NewSoftSerial cell(2,3);  //Create a 'fake' serial port. Pin 2 is the Rx pin, pin 3 is the Tx pin.


void setup()
{
    pinMode(2,INPUT);
    pinMode(3,OUTPUT);
    pinMode(in1,OUTPUT);
    pinMode(in2,OUTPUT);
    pinMode(in3,OUTPUT);
    pinMode(out1,OUTPUT);
    pinMode(out2,OUTPUT);
    pinMode(out3,OUTPUT);
    pinMode(control,OUTPUT);
    pinMode(13,OUTPUT);
    counter=0;
    digitalWrite(control,1); 
    Serial.begin(9600);
    cell.begin(9600);
    digitalWrite(13,HIGH);
    Serial.println("Starting SM5100B Communication...");
    delay(500);
    digitalWrite(13,LOW);
    
    if(firstTimeInLoop) 
    {
        firstTimeInLoop = 0;
        while (atready == 0) 
        {
           readstring();
            if( strstr(buffer, "+SIND: 4") != 0 )
          {
            Serial.println("aaaaa");
            atready=true;
          }
        }
        cell.print("AT+CNMI=3,3,0,0\r");
        delay(500);
        cell.print("AT+CMGF=1\r");
        delay(500);
        cell.print("AT+CMGD=1,4\r");
        delay(500);
         digitalWrite(13,HIGH);
    }

}

/* Reads AT String from the SM5100B GSM/GPRS Module */

void readstring(void) {

    char c;
    index= 0; // start at begninning
    while (index!=199) {
        if(cell.available() > 0) {
            c=cell.read();
            
            if ((c == -1) ||(c == '\r')) 
            {
                buffer[index] = '\0';
                return;
            }

            if (c == '\n') {
                continue;
            }

            buffer[index]= c;
            index++;
        }
    }
}

void loop() {

    /* If called for the first time, loop until GPRS and AT is ready */

 while(cell.available() >0)
  { 
    
    if (index !=199)
    {
    incom=cell.read();   
    buffer[index]=incom;
    index++;
    delay(1);
    buffer[index]='\0';
    }
    
    pch=true;
  }


  
if(pch==true)
{
 
  index=0;
  pch=false;

  Serial.print('\n');
  if (strlen(buffer)>50)
    {
      input();
    }
  index=0;
}
}

void input()
{
   
  j=0;
  if (buffer[60]==32)
  {
    index=62;
  }
  else
  {
    index=63;
  }
  for(index;buffer[index]!='\r';index++)
  {
    string[j]=buffer[index];
    j++;
    string[j]='\0';
  }
  j=0;
  for (index=9;index<19;index++)
    {
     number[j]=buffer[index];
     j++;
     number[j]='\0'; 
    }
    process();
}

void process()
{
   for (index=0; nu1[index]!='\0';index++)
  {
    Serial.print(nu1[index]);
  }
  for (index=0; number[index]!='\0';index++)
  {
    printchar(number[index]);
  }
   printchar('\n');
   for (index=0; nu2[index]!='\0';index++)
  {
    printchar(nu2[index]);
  }
   for (index=0; string[index]!='\0';index++)
  {
    printchar(string[index]);
  }
  printchar('\n');
  cell.print("AT+CMGD=1,4\r");
  delay(100);
}

void printchar(char type)
{
  newline();
  switch(type)
  {
    case ' ':
    output(0,0,0,1,1,1);
    break;
    case 'a':
    output(1,1,0,1,1,1);
    break;
    case 'A':
    outputcap(1,1,0,1,1,1);
    break;
    case 'b':
    output(0,1,0,0,0,0);
    break;
    case 'B':
    outputcap(0,1,0,0,0,0);
    break;
    case 'c':
    output(1,0,0,0,1,0);
    break;
    case 'C':
    outputcap(1,0,0,0,1,0);
    break;
    case 'd':
    output(1,1,0,0,1,0);
    break;
    case 'D':
    outputcap(1,1,0,0,1,0);
    break;
    case 'e':
    output(1,0,1,0,1,0);
    break;
    case 'E':
    outputcap(1,0,1,0,1,0);
    break;
    case 'f':
    output(1,1,0,0,0,0);
    break;
    case 'F':
    outputcap(1,1,0,0,0,0);
    break;
    case 'g':
   digitalWrite(control,LOW);
   digitalWrite(in1,0); 
   digitalWrite(in2,0);
   digitalWrite(in3,0);
   digitalWrite(out1,0);
   digitalWrite(out2,0);
   digitalWrite(out3,0);
   delay(375);
   digitalWrite(control,HIGH);
    break;
    case 'G':
     digitalWrite(control,LOW);
   digitalWrite(in1,0); 
   digitalWrite(in2,1);
   digitalWrite(in3,0);
   digitalWrite(out1,1);
   digitalWrite(out2,1);
 digitalWrite(out3,1); 
 delay(100);
 digitalWrite(in1,0); 
 digitalWrite(in2,0);
 digitalWrite(in3,0);
 digitalWrite(out1,0);
 digitalWrite(out2,0);
 digitalWrite(out3,0);
 delay(250);
 digitalWrite(in1,0); 
 digitalWrite(in2,1);
 digitalWrite(in3,0);
 digitalWrite(out1,0);
 digitalWrite(out2,0);
 digitalWrite(out3,1);
 delay(75);  
  
 digitalWrite(control,HIGH);
    break;
    case 'h':
    output(0,0,0,1,0,0);
    break;
    case 'H':
    outputcap(0,0,0,1,0,0);
    break;
    case 'i':
    output(1,0,1,0,0,1);
    break;
    case 'I':
    outputcap(1,0,1,0,0,1);
    break;
    case 'j':
    output(1,1,0,1,0,0);
    break;
    case 'J':
    outputcap(1,1,0,1,0,0);
    break;
    case 'k':
    output(1,1,0,0,0,1);
    break;
    case 'K':
    outputcap(1,1,0,0,0,1);
    break;
    case 'l':
    output(1,1,0,1,0,1);
    break;
    case 'L':
    outputcap(1,1,0,1,0,1);
    break;
    case 'm':
    output(1,0,0,1,0,0);
    break;
    case 'M':
    outputcap(1,0,0,1,0,0);
    break;
    case 'n':
    output(0,1,0,1,0,0);
    break;
    case 'N':
    outputcap(0,1,0,1,0,0);
    break;
    case 'o':
    output(0,1,0,1,0,1);
    break;
    case 'O':
    outputcap(0,1,0,1,0,1);
    break;
    case 'p':
    output(0,0,1,1,1,0);
    break;
    case 'P':
    outputcap(0,0,1,1,1,0);
    break;
    case 'q':
    output(1,0,1,1,1,1);
    break;
    case 'Q':
    outputcap(1,0,1,1,1,1);
    break;
    case 'r':
    output(1,0,1,0,0,0);
    break;
    case 'R':
    outputcap(1,0,1,0,0,0);
    break;
    case 's':
    output(1,1,0,0,1,1);
    break;
    case 'S':
    outputcap(1,1,0,0,1,1);
    break;
    case 't':
    output(0,0,1,0,0,0);
    break;
    case 'T':
    outputcap(0,0,1,0,0,0);
    break;
    case 'u':
    output(1,0,1,1,0,0);
    break;
    case 'U':
    outputcap(1,0,1,1,0,0);
    break;
    case 'v':
    output(1,0,0,0,0,0);
    break;
    case 'V':
    outputcap(1,0,0,0,0,0);
    break;
    case 'w':
    output(1,0,1,0,1,1);
    break;
    case 'W':
    outputcap(1,0,1,0,1,1);
    break;
    case 'x':
    output(1,0,0,0,1,1);
    break;
    case 'X':
    outputcap(1,0,0,0,1,1);
    break;
    case 'y':
    output(0,0,1,1,0,0);
    break;
    case 'Y':
    outputcap(0,0,1,1,0,0);
    break;
    case 'z':
    output(1,0,0,1,1,1);
    break;
    case 'Z':
    outputcap(1,0,0,1,1,1);
    break;
    case '0':
    output(1,1,1,1,1,0);
    break;
    case '1':
    output(1,1,1,1,1,1);
    break;
    case '2':
    output(1,1,1,0,1,1);
    break;
    case '3':
    output(1,1,1,0,1,0);
    break;
    case '4':
    output(1,1,1,0,0,0);
    break;
    case '5':
    output(0,1,1,0,0,0);
    break;
    case '6':
    output(0,1,1,1,0,0);
    break;
    case '7':
    output(1,1,1,1,0,0);
    break;
    case '8':
    output(1,1,1,0,0,1);
    break;
    case '9':
    output(1,1,1,1,0,1);
    break;
    case ')':
    outputcap(1,1,1,1,1,0);
    break;
    case '!':
    outputcap(1,1,1,1,1,1);
    break;
    case '@':
    outputcap(1,1,1,0,1,1);
    break;
    case '#':
    outputcap(1,1,1,0,1,0);
    break;
    case '$':
    outputcap(1,1,1,0,0,0);
    break;
    case '%':
    output(0,1,1,0,0,0);
    break;
    case '&':
    outputcap(1,1,1,1,0,0);
    break;
    case '*':
    outputcap(1,1,1,0,0,1);
    break;
    case '(':
    outputcap(1,1,1,1,0,1);
    break;
    case ',':
    output(1,0,0,0,0,1);
    break;
    case '.':
    output(1,0,0,1,0,1);
    break;
    case '=':
    output(0,1,1,1,0,1);
    break;
    case '+':
    outputcap(0,1,1,1,0,1);
    break;
    case '-':
    output(0,1,1,1,1,0);
    break;
    case '_':
    outputcap(0,1,1,1,1,0);
    break;
    case ';':
    output(1,1,0,1,1,0);
    break;
    case ':':
    outputcap(1,1,0,1,1,0);
    break;
    case '\'':
    output(0,1,0,1,1,0);
    break;
    case '"':
    outputcap(0,1,0,1,1,0);
    break;
    case '/':
    output(1,0,0,1,1,0);
    break;
    case '?':
    outputcap(1,0,0,1,1,0);
    break;
    case '\n':
    counter=0;
    output(0,0,1,0,1,0);
    break;
    case '\0':
    break;
  }
  delay(75);
}

void newline()
{
  if (counter>=64)
  {
    output(0,0,1,0,1,0);
    counter=0;
  }
  else
  {
    counter++;
  }
}

void output(int con1,int con2,int con3, int con4, int con5, int con6)
{
 digitalWrite(control,LOW);
  
 digitalWrite(in1,con1); 
 digitalWrite(in2,con2);
 digitalWrite(in3,con3);
 digitalWrite(out1,con4);
 digitalWrite(out2,con5);
 digitalWrite(out3,con6);
 delay(150);
 
 digitalWrite(control,HIGH);
}

void outputcap(int con1,int con2,int con3, int con4, int con5, int con6)
{
 digitalWrite(control,LOW);
 
 digitalWrite(in1,0); 
 digitalWrite(in2,1);
 digitalWrite(in3,0);
 digitalWrite(out1,1);
 digitalWrite(out2,1);
 digitalWrite(out3,1); 
 delay(100);

 digitalWrite(in1,con1); 
 digitalWrite(in2,con2);
 digitalWrite(in3,con3);
 digitalWrite(out1,con4);
 digitalWrite(out2,con5);
 digitalWrite(out3,con6);
 delay(100);
  
 digitalWrite(in1,0); 
 digitalWrite(in2,1);
 digitalWrite(in3,0);
 digitalWrite(out1,0);
 digitalWrite(out2,0);
 digitalWrite(out3,1);
 delay(75);  
  
 digitalWrite(control,HIGH);
  
}

