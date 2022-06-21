/*==============================================================================

Copyright 2003-2004 Pierre-Alain Fayolle, Benjamin Schmitt
Copyright 2007-2008 Oleg Fryazinov, Denis Kravtsov
Copyright 2018-2019 Dmitry Popov

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



#include "main.h"


CMainApp *edi;

int vn_t;

void freeRessources (void) 
{
    if(edi!=NULL){
        delete (edi);
        edi=NULL;
    }
}

int main(int argc, char ** argv) 
{

    edi = new CMainApp (argc, argv);
    
    vn_t = edi->init();
    if (vn_t == 0) {
        if (edi != NULL) {
            delete(edi);
            edi=NULL;
        }
        cout << "Isosurface not generated.\n";
        exit(0);
    }
    
    freeRessources();
}

