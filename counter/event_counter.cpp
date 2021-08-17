#include <stdio.h>
#include <string.h>
#include <string>
#include <math.h>

int main(int argc, char* argv[]){
	FILE *in, *out;
	// char * result = new char[100];
	// memset(result, 0, 100);
	// strcat(result, argv[1]);
	// strcat(result, "_result");
	in=fopen(argv[1],"r");
	// out=fopen(result,"w+");
	int buffer;
	int rbyte=0;
	double allcount = 0;
	double callNum = 0;
	double endNum = 0;
	int lastone = 0;
	while((rbyte=fread(&buffer,4,1,in))==1){
		allcount++;
		if (buffer == 0xffffeeee) {
			endNum++;
		} else if (buffer & 0x80000000) {
			callNum++;
		} 
		lastone = buffer;
		// fprintf(out,"0x%x ",buffer);
		// printf("0x%x ",buffer);
	}
	// printf("allcount = %f; callNum = %f; endNum = %f\n",allcount, callNum, endNum);
	// printf("(callNum + allcount)/2 =  %f\n", (callNum + allcount)/2);
	printf("result =  %.0f\n", ceil((callNum + allcount)/2));
	// printf("lastone = %x\n", lastone);
	fclose(in);
	// fclose(out);
	return 0;
}
