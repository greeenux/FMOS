#include "Types.h"
#include "Page.h"

void kPrintString(int iX, int iY, const char *pcString);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);
void main(void)
{
	DWORD i;
	kPrintString(0,3,"C Language Kernel Started~!!!");

	//check minimum memory size
	kPrintString(0,4,"Minimum memory size check ......[    ]");
	if(kIsMemoryEnough()==FALSE)
	{
		kPrintString(33,4,"FAIL");
		kPrintString(0,5,"Not enough memory ~~FMOS Requires over 64MByte memory");
		while(1);
	}
	else
	{
		kPrintString(33,4,"PASS");
	}
	//initialize ia-32e mode kernel area
	kPrintString(0,5,"ia-32ekernel area initialize....[    ]");
	if(kInitializeKernel64Area()==FALSE)
	{
		kPrintString(33,5,"FAIL");
		kPrintString(0,6,"kernel Area initialization fail");
		while(1);
	}
	kPrintString(33,5,"PASS");
	//generate page table for IA-32e mode kernel
	kPrintString(0,6,"ia-32e Page Tables Initialize...[    ]");
	kInitializePageTables();
	kPrintString(33,6,"PASS");

	while(1);
}
//function which print character strings
void kPrintString(int iX, int iY,const char *pcString)
{
	CHARACTER *pstScreen=(CHARACTER *) 0xb8000;
	int i;
	pstScreen += (iY*80) +iX;
	for(i=0; pcString[i] != 0 ;i++ )
	{
		pstScreen[i].bCharactor=pcString[i];
	}
}
BOOL kInitializeKernel64Area(void)
{
	DWORD *pdwCurrentAddress;

	//initialize allocated address 0x10000
	pdwCurrentAddress=(DWORD *)0x100000;
	while((DWORD)pdwCurrentAddress< 0x600000)
	{
		*pdwCurrentAddress=0x00;
		if(*pdwCurrentAddress!=0)
		{
			return FALSE;
		}
		pdwCurrentAddress++;
	}
	return TRUE;
}
BOOL kIsMemoryEnough(void)
{
	DWORD *pdwCurrentAddress;
	//starting point 0x100000(1MB)
	pdwCurrentAddress=(DWORD *)0x100000;
	//upto 64MB
	while((DWORD)pdwCurrentAddress<0x400000)
	{
		*pdwCurrentAddress=0x12345678;
		if(*pdwCurrentAddress!=0x12345678)
		{
			return FALSE;
		}
		pdwCurrentAddress+=(0x100000/4);
	}
	return TRUE;
}