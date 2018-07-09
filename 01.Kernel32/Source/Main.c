#include "Types.h"
#include "Page.h"
#include "ModeSwitch.h"

void kPrintString(int iX, int iY, const char *pcString);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);
void kCopyKernel64ImageTo2MByte(void);
void main(void)
{
	DWORD i;
	DWORD dwEAX, dwEBX, dwECX, dwEDX;
	char vcVendorString[13] = { 0, };

	kPrintString(0,3,"Protected Mode C Language Kernel Start.....[Pass]~!!!");

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

	// Read Processor Vendor Information
	kReadCPUID(0x00, &dwEAX, &dwEBX, &dwECX, &dwEDX);
	*(DWORD*)vcVendorString = dwEBX;
	*((DWORD*)vcVendorString + 1) = dwEDX;
	*((DWORD*)vcVendorString + 2) = dwECX;
	kPrintString(0, 7, "Processor Vendor String.........[            ]");
	kPrintString(33, 7, vcVendorString);

	// check 64 bit support
	kReadCPUID(0x80000001, &dwEAX, &dwEBX, &dwECX, &dwEDX);
	kPrintString(0, 8, "64bit Mode Support Check........[    ]");
	if (dwEDX & (1 << 29))
	{
		kPrintString(33, 8, "PASS");
	}
	else
	{
		kPrintString(33, 8, "FAIL");
		kPrintString(0, 9, "This processor does not support 64bit mode!!");
		while (1);
	}
	// Move IA-32e mode kernel to 0x200000(2MByte) address
	kPrintString(0, 9, "Copy IA-32e Kernel To 2M Address.....[    ]");
	kCopyKernel64ImageTo2MByte();
	kPrintString(38, 9, "PASS");

	// switch to IA-32e mode
	kPrintString(0, 10, "Switch To IA-32e Mode");
	kSwitchAndExecute64bitKernel();


	while (1);
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

void kCopyKernel64ImageTo2MByte(void)
{
	WORD wKernel32SectorCount, wTotalKernelSectorCount;
	DWORD* pdwSourceAddress,* pdwDestinationAddress;
	int i;

	wTotalKernelSectorCount = *((WORD*)0x7C05);
	wKernel32SectorCount = *((WORD*)0x7C07);

	pdwSourceAddress = (DWORD*)(0x10000 + (wKernel32SectorCount * 512));
	pdwDestinationAddress = (DWORD*)0x200000;

	for (i = 0; i < 512 * (wTotalKernelSectorCount - wKernel32SectorCount) / sizeof(DWORD); i++)
	{
		*pdwDestinationAddress++ = *pdwSourceAddress++;
	}
}
