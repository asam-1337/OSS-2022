#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	fork();
	sleep(5);
	return 0;
}
