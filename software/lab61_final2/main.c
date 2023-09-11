int main()
{
	//int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x70; //make a pointer to access the PIO block
	volatile unsigned int *switches_PIO = (unsigned int*)0x60;
	volatile unsigned int *button_PIO = (unsigned int*)0x50;


	*LED_PIO = 0; //clear all LEDs


	while ( (1+1) != 3) //infinite loop
	{
		while(*LED_PIO < 255){
			if(*button_PIO == 0)
				*LED_PIO += *switches_PIO;
		}
		/*
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO |= 0x1; //set LSB
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO &= ~0x1; //clear LSB*/
		*LED_PIO = 0;
	}
	return 1; //never gets here
}
