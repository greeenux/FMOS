#include "Page.h"

//generate page table for ia-32e mode kernel 
void kInitializePageTables(void)
{
	PML4TENTRY *pstPML4TEntry;
	PDPTENTRY *pstPDPTEntry;
	PDENTRY *pstPDEntry;
	DWORD dwMappingAddress;
	int i;

	//generate PML4table
	//initiate every entry except first one with 0
	pstPML4TEntry = (PML4TENTRY *)0x100000;
	kSetPageEntryData(&(pstPML4TEntry[0]),0x00,0x101000,PAGE_FLAGS_DEFAULT,0);
	for(i=1;i<PAGE_MAXENTRYCOUNT;i++)
	{
		kSetPageEntryData(&(pstPML4TEntry[i]),0,0,0,0);
	}
	//generate page directory pointer table
	//one PDPT is enough,up to 512GB
	//set 64 entry and be mapped up to 64gb
	pstPDPTEntry =(PDPTENTRY *)0x101000;
	for (i = 0; i < 64; i++)
	{
		kSetPageEntryData(&(pstPDPTEntry[i]), 0, 0x102000 + (i * PAGE_TABLESIZE),
				PAGE_FLAGS_DEFAULT, 0);
	}
	for (i = 64; i < PAGE_MAXENTRYCOUNT; i++)
	{
		kSetPageEntryData(&(pstPDPTEntry[i]), 0, 0, 0, 0);
	}
	//generate page directory table
	//one page directory could be mapped up to 64gb
	//generate 64 page directory and support 64GB
	pstPDEntry = (PDENTRY*)0x102000;
	dwMappingAddress = 0;
	for (i = 0; i < PAGE_MAXENTRYCOUNT * 64; i++)
	{
		kSetPageEntryData(&(pstPDEntry[i]), (i * (PAGE_DEFAULTSIZE >> 20)) >> 12,
				dwMappingAddress, PAGE_FLAGS_DEFAULT | PAGE_FLAGS_PS, 0);
		dwMappingAddress += PAGE_DEFAULTSIZE;
	}
}
//set page entry base address and attribyute flags.
void kSetPageEntryData(PTENTRY* pstEntry, DWORD dwUpperBaseAddress,DWORD dwLowerBaseAddress, DWORD dwLowerFlags, DWORD dwUpperFlags)
{
	pstEntry->dwAttributeAndLowerBaseAddress = dwLowerBaseAddress | dwLowerFlags;
	pstEntry->dwUpperBaseAddressAndEXB = (dwUpperBaseAddress & 0xFF) | dwUpperFlags;
}

