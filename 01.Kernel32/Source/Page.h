#ifndef __PAGE_H__
#define __PAGE_H__

#include "Types.h"

#define PAGE_FLAGS_P		0x00000001		//present
#define PAGE_FLAGS_RW		0x00000002		//readWrite
#define PAGE_FLAGS_US		0x00000004		//userSupervisor
#define PAGE_FLAGS_PWT		0x00000008		//page level write-through
#define PAGE_FLAGS_PCD		0x00000010 		//page level cache disable
#define PAGE_FLAGS_A		0x00000020 		//Accessed
#define PAGE_FLAGS_D		0x00000040		//dirty
#define PAGE_FLAGS_PS		0x00000080		//page Size
#define PAGE_FLAGS_G		0x00000100		//global
#define PAGE_FLAGS_PAT		0x00001000		//page Attribuet Table Index
#define PAGE_FLAGS_EXB		0x80000000		//execute Disable bit
#define PAGE_FLAGS_DEFAULT	( PAGE_FLAGS_P | PAGE_FLAGS_RW )
#define PAGE_TABLESIZE		0x1000
#define PAGE_MAXENTRYCOUNT	512
#define PAGE_DEFAULTSIZE	0x200000
//data structure for page entry
#pragma pack( push, 1 )
typedef struct kPageTableEntryStruct
{
	//About PML4T and PDPTE entry
	//1 bit => P,RW,US,PWT,PCD,A
	//3 bit => Reserved, Avail.
	//20 bit => Base Address
	//About PDE entry 
	//1 bit => P,RW,US,PWT,PCD,A,D,ps1,G,PAT
	//3bit => Avail
	//8bit => Reserved
	//11bit => Base Address 
	DWORD dwAttributeAndLowerBaseAddress;
	DWORD dwUpperBaseAddressAndEXB;
}PML4TENTRY, PDPTENTRY, PDENTRY, PTENTRY;
#pragma pack(pop)

void kInitializePageTables(void);
void kSetPageEntryData(PTENTRY* pstEntry, DWORD dwUpperBaseAddress, DWORD dwLowerBaseAddress, DWORD dwLowerFlags, DWORD dwUpperFlags);

#endif
