sfr key = 0xc6;
sfr red = 0xc3;
sfr green = 0xc4;
sfr blue = 0xc5;
sfr control = 0xc2;

int number;
unsigned char key1_state = 0, key2_state = 0;

int main(void) {
		while(1) {
				number = key;
				if(number == 0x01) { //key[0]
						switch (key1_state) {
							case 0 : control = 0x01; break;
							case 1 : control = 0x02; break;
							case 2 : control = 0x03; break;
							case 3 : control = 0x04; break;
							case 4 : control = 0x05; break;
							case 5 : control = 0x06; break;
							case 6 : control = 0x07; break;
							case 7 : control = 0x08; break;
							default : control = 0x01; break;
						}
						key1_state++;
						key = 0x00;
				}else if(number == 0x10) { //key[1]
						switch (key2_state) {
							case 0 : 
								green = 0x01;
								red = 0x00;
								blue = 0x00;
								break;
							case 1 : 
								blue = 0x01;
								green = 0x00;
								red = 0x00;
								break;
							case 2 : 
								red = 0x01;
								blue = 0x00;
								green = 0x00;
							default : 
								red = 0x00;
								blue = 0x00;
								green = 0x00;
								break;
						}
						key2_state++;
						key = 0x00;
				}
				if(key1_state > 7) key1_state = 0;
				if(key2_state > 2) key2_state = 0;
		}
}