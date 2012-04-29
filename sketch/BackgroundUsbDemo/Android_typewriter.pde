#include <Max3421e.h>
#include <Usb.h>
#include <AndroidAccessory.h>

/*
*	Android Typewriter Arduino interface
*	Provides an interface to the Android app through the Android accessory interface,
*	and maps bytes sent from the app to toggle a pair of 4051 multiplexer/demultiplexers
*	emulating the behaviour of keyboard presses on the typewriter
*/
AndroidAccessory acc("Tony Du",
		"AndroidTypewriter",
		"Android Typewriter",
		"0.1",
		"http://git.io/lRD2Hw/",
		"0000000000000001");

boolean flag=false;

//Define pins for keyboard spoofer multiplexers, character counter for moving to the next line
int in1=A3;
int in2=A4;
int in3=A5;
int out1=A0;
int out2=A1;
int out3=A2;
int control=2;
int counter;

//initalize 
void setup() {
	//set all keyboard spoofer as output, disable multiplexers, and enable ADK interface
	pinMode(in1,OUTPUT);
	pinMode(in2,OUTPUT);
	pinMode(in3,OUTPUT);
	pinMode(out1,OUTPUT);
	pinMode(out2,OUTPUT);
	pinMode(out3,OUTPUT);
	pinMode(control,OUTPUT);
	digitalWrite(control,1); 
	acc.powerOn();  
}

void loop() {
	byte msg[1];
	//if connected via ADK, get a byte from the app, and map character to spoofer pin states
	if (acc.isConnected()) {
		byte len = acc.read(msg, sizeof(msg), 1);
		if (len == 1) {
            printchar(msg[0]);
		}

		delay(1);
	}
}

//Sets the multiplexers to the state defined by the character mapping in printchar
void output(int con1,int con2,int con3, int con4, int con5, int con6)
{
	//enable multiplexer output
	digitalWrite(control,LOW);

	//set multiplexer to emulate the behaviour of pressing the parameter key
	digitalWrite(in1,con1); 
	digitalWrite(in2,con2);
	digitalWrite(in3,con3);
	digitalWrite(out1,con4);
	digitalWrite(out2,con5);
	digitalWrite(out3,con6);
	//hold key state, so that the typewriter will scan through
	//the pressed key
	delay(150);
	
	//disable multiplexer output
	digitalWrite(control,HIGH);
}

//Output the shifted version of the character key
void outputcap(int con1,int con2,int con3, int con4, int con5, int con6)
{	
	//enable multiplexer output
	digitalWrite(control,LOW);

	//set multiplexer state to the shift key, hold until scanned
	digitalWrite(in1,0); 
	digitalWrite(in2,1);
	digitalWrite(in3,0);
	digitalWrite(out1,1);
	digitalWrite(out2,1);
	digitalWrite(out3,1); 
	delay(100);

	//set multiplexer state to the parameter key
	digitalWrite(in1,con1); 
	digitalWrite(in2,con2);
	digitalWrite(in3,con3);
	digitalWrite(out1,con4);
	digitalWrite(out2,con5);
	digitalWrite(out3,con6);
	delay(100);

	//set multiplexer state to the shift key to disable shift,
	//hold until scanned
	digitalWrite(in1,0); 
	digitalWrite(in2,1);
	digitalWrite(in3,0);
	digitalWrite(out1,0);
	digitalWrite(out2,0);
	digitalWrite(out3,1);
	delay(75);  

	//disable multiplexer output
	digitalWrite(control,HIGH);

}

//checks if the typewriter has reached EOL, writes newline character
//if EOL
void newline()
{
	//if counter is at 64 characters, write newline character,
	//reset counter
	if (counter>=64)
	{
		output(0,0,1,0,1,0);
		counter=0;
	}
	//otherwise, just increment counter
	else
	{
		counter++;
	}
}

//function to map the character to the multiplexer state
void printchar(char type)
{
	//do a character count check before printing the character
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
	//g/G is all zero, and requires special timing 
	case 'g':
		digitalWrite(control,LOW);
		digitalWrite(in1,0); 
		digitalWrite(in2,0);
		digitalWrite(in3,0);
		digitalWrite(out1,0);
		digitalWrite(out2,0);
		digitalWrite(out3,0);
		delay(250);
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
		counter=0;
		output(0,0,1,0,1,0);
		break;
        default:
                break;
	}
	delay(75);
}



