#include <stdlib.h>
#include <unistd.h>
int main(){setuid(0);execl("PLACEHOLDER2","killswitch.sh",NULL);return 1;}
