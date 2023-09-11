int main()
{
	//int i = 0;

	volatile unsigned int *LED_PIO = (unsigned int*)0x70; //make a pointer to access the PIO block
	volatile unsigned int *switches_PIO = (unsigned int*)0x60;
	volatile unsigned int *button_PIO = (unsigned int*)0x50;
	volatile unsigned int wait = 0;
	volatile unsigned int temp = 0;
	volatile unsigned int i = 0;
	*LED_PIO = 0; //clear all LEDs
	//*LED_PIO = *switches_PIO;

	while ( (1+1) != 3) //infinite loop
	{
		/*
		while(1==1){
			if(*button_PIO == 0 && wait != 1){
				*LED_PIO += *switches_PIO;
				wait = 1;
			}
			if(*LED_PIO > 255)
				*LED_PIO = *LED_PIO - 256;
			if(wait == 1)
			{
				for (i = 0; i< 100000; i++){
					temp = temp+temp;}
				wait = 0;
			}*/
		for (i = 0; i < 100000; i++) //software delay
			*LED_PIO |= 0x1; //set LSB
		for (i = 0; i < 100000; i++) //software delay
			*LED_PIO &= ~0x1; //clear LSB
		//}


		//*LED_PIO = 0;
	}
	return 1; //never gets here
}
