#include <stdio.h>
#include <stdint.h>

uint8_t rmc_cut(char rmc[], char data[]) {
	uint8_t i = 0;
	uint8_t split = 0;

	if (rmc[18] == 'A') { // RMC sentence is valid
		i = 7;
		while (split < 7) {
			if ((rmc[i] == ',') & (split != 7))
				split++;
			data[i-7] = rmc[i];
			i++;
		}
		data[i-8] = 0;
		return 0;
	} else {
		return 1;
	}
}

int main (void) {
//	char rmcstring[] = "$GPRMC,122001.847,V,,,,,0.08,81.25,081212,,,N*78\r\n";
	char rmcstring[] = "$GPRMC,122002.093,A,5703.5754,N,00953.7099,E,0.05,81.25,081212,,,A*5E\r\n";
	char data[200];


	if (rmc_cut(rmcstring,data)) {
		printf("Invalid RMC");
	} else {

	 	printf("%s",data);
	}
}
