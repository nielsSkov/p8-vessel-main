#include <stdio.h>
#include <string.h>

char buildtime[] =  __DATE__ " " __TIME__;
char gitcommit[sizeof(__GIT_COMMIT__)] = __GIT_COMMIT__;
char buildinfo[sizeof(buildtime)+sizeof(gitcommit)+2];

int i;

int main() {
    memcpy(buildinfo,buildtime,sizeof(buildtime)-1);
    for (i = sizeof(buildtime); i < sizeof(buildinfo); i++) {
	    buildinfo[i-1] = gitcommit[i-sizeof(buildtime)];
    }
 
   printf("%s", buildinfo);
}
