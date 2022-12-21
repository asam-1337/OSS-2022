#include <stdio.h>

extern char **environ;

int main(int argc, char *argv[])
{
	char **p;
	for(p = environ; *p && p - environ < 10; p++)
		printf("%s\n", *p);
	return 0;
}
