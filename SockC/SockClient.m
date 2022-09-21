//
//  SockClient.m
//  Sock
//
//  Created by stoicer on 2022/9/21.
//

#import "SockClient.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
static int fd;
@implementation SockClient
- (void)buildClient
{
    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd == -1) {
        NSLog(@"[client]:socket create failed!");
        return;
    }
    
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    addr.sin_port = htons(8888);
    
    int result = connect(fd, (struct sockaddr *)&addr, sizeof(addr));
    if (result == -1) {
        NSLog(@"[client]:socket connect failed!");
        return;
    }
    
    //send
    [self sendData:@"123"];
    
    //recive
    [NSThread detachNewThreadSelector:@selector(threadRecvData) toTarget:self withObject:nil];
}

- (void)threadRecvData
{
    char buf[32];
    while (1) {
        size_t result = recv(fd, buf, 32, MSG_WAITALL);
        if (result <0) {
            NSLog(@"recv failed!");
            break;
        }
        
        buf[result] = 0;
        NSLog(@"%s",buf);
    }
    
    close(fd);
}

- (void)sendData:(NSString *)str
{
    __weak typeof(self) weakSelf = self;
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        [weakSelf sendData:str];
    }];
    [thread start];
}

- (void)theadSendData:(NSString *)str
{
    if (str.length == 0) {
        return;
    }
    
    const char * contC  = [str UTF8String];
    ssize_t result = send(fd, contC, sizeof(contC), 0);
    if (result <0) {
        NSLog(@"[client]send failed!");
    }
}
@end
