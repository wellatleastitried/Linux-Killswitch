#include <stdlib.h>
#include <unistd.h>
int main(){setuid(0);setgid(0);if (execl("PLACEHOLDER2",".killswitch",NULL)){perror("execl failed");return 1;}return 0;}
