#include <stdio.h>
#include <stdlib.h>

extern char **environ;

int main(int argc, char *argv[])
{
	char **p;
	int i = atoi(argv[1]);
	for(p = environ; *p && p - environ < i; p++)
		printf("%s\n", *p);
	return 0;
}
