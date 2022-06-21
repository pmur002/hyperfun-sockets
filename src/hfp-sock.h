
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#include <sys/types.h>

#ifdef _WIN32

#include <winsock2.h>
#include <windows.h>
#include <ws2tcpip.h>

#else

#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#endif


