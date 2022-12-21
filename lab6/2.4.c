#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	int pid = fork();
	for(int j = 0; j < 50; j++)
		if(pid)
			fork();
	sleep(5);
	return 0;

	// Yes, it is restricted!
}
