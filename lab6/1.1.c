#include <stdio.h>


extern char **environ;
int main(int argc, char *argv[])
{
	char **p;
	int i = 0;
	for(p = environ; *p != NULL; p++)
		i++;
	printf("Number of environment variables: %d\n", i);
	return 0;
}
