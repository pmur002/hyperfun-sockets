/*==============================================================================

 Copyright 2022 Paul Murrell

 This Work or file is part of the greater total Work, software or group of
 files named HyperFun Polygonizer.

 HyperFun Polygonizer can be redistributed and/or modified under the terms 
 of the CGPL, The Common Good Public License as published by and at CGPL.org
 (http://CGPL.org).  It is released under version 1.0 Beta of the License
 until the 1.0 version is released after which either version 1.0 of the
 License, or (at your option) any later version can be applied.

 THIS WORK, OR SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED (See the
 CGPL, The Common Good Public License for more information.)

 You should have received a copy of the CGPL along with HyperFun Polygonizer;  
 if not, see -  http://CGPL.org to get a copy of the License.

==============================================================================*/

/* 
 * Send on socket connection to calculate value from an external program
 *
 * Will only work when running hfp-client from external program that has
 * created a socket.
 
  Call: hfExternal(x, index);

  Parameters:
  x - point coordinates array
  index - index into list of R functions

  C-parameters:
        f_a[0]   corresponds to index
        f_a[1]   corresponds to array x 

*/

#include "hfp-sock.h"
#include "hfp-sockdata.h"

#include "general.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

extern int HF_Get_Runtime_Array(int index, double** array, int* size);
void HF_Fill_Error(PN_T* p_pn, int er_index, Error_Info_T* EI, int ic);

double hfExternal(double* f_a, String_Array_T* str_param)
{
    double* x;
    int funIndex, array_index, dim;
    double f;
    int numbytes;  
    char *eptr;

    if (HF_sockfd < 0) {
        printf("Socket connection required (are you using hfp-client?)\n");
        exit(1);
    }

    funIndex = f_a[0];

    array_index = (int)f_a[1];
    HF_Get_Runtime_Array(array_index, &x, &dim);

    if (dim != 3) return -1111111111111.0;

    char buffer[MAXDATASIZE];
    sprintf(buffer, "%d %f %f %f", funIndex, x[0], x[1], x[2]);
    int len = strlen(buffer);

    // Send request for value
    if (send(HF_sockfd, buffer, len, 0) == -1) {
        perror("send");
        exit(1);
    }
    
    // Receive value
    if ((numbytes = recv(HF_sockfd, buffer, MAXDATASIZE-1, 0)) == -1) {
        perror("recv");
        exit(1);
    }

    f = strtod(buffer, &eptr);

    return f;
}
