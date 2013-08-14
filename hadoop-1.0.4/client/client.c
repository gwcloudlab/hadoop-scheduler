#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include "myheader.h"

int main(int argc, char *argv[])
{
    int sockfd = 0, n = 0;
    char buf[LINE_MAX];
    struct sockaddr_in serv_addr;
    FILE *fp;
    
    memset(buf, 0, sizeof(buf));
    if((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("socket error");
        exit(1);
    }
    
    memset(&serv_addr, 0, sizeof(serv_addr));
    
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    if(inet_pton(AF_INET, SERVERIP, &serv_addr.sin_addr) <= 0)
    {
        perror("inet_pton error");
        exit(1);
    }

    if((connect(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr))) < 0)
    {
        perror("connetc error");
        exit(1);
    }

    while(1)
    {
        if (system("bash monitor.sh") == -1)
        {
           perror("system error");
           exit(1);
        }

        if ((fp = fopen("monitor.txt", "r")) == NULL)
        {
            perror("open monitor.txt error");
            exit(1);
        }


        while(fgets(buf, LINE_MAX, fp) != NULL)
        {
            printf("buf:%s len:%d\n", buf, (int) strlen(buf));
            if (send(sockfd, buf, strlen(buf), 0) == -1)
            {
                perror("send error");
                exit(1);
            }
            memset(buf, 0, sizeof(buf));
        }
       fclose(fp);       
       sleep(20);  
    }


}

