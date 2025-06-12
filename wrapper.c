#include <stdlib.h>
#include <unistd.h>

/* Simple binary wrapper for the killswitch.sh script.
 * Setuid cannot be set on the script itself, so this
 * binary will serve as the entrypoint to ensure the
 * necessary permissions are set.
 */
int main() {

    setuid(0);
    setgid(0);

    if (execl("PLACEHOLDER2",".killswitch",NULL)) {
        perror("execl failed");
        return 1;
    }

    return 0;
}
