#include "Types.h"
#include "Keyboard.h"

void kPrintString(int iX, int iY, const char* pcString);

void Main(void)
{
	char vcTemp[2] = { 0, };
	BYTE bFlags, bTemp;
	int i = 0;
	kPrintString(0, 10, "Switch To IA-32e Mode Success!");
	kPrintString(0, 11, "IA-32e C Language Kernel Start.......[PASS]");
	kPrintString(0, 12, "Keyboard Activate....................[    ]");

	if (kActivateKeyboard() == TRUE)
	{
		kPrintString(38, 12, "PASS");
		kChangeKeyboardLED(FALSE, FALSE, FALSE);
	}
	else
	{
		kPrintString(38, 12, "FAIL");
		while (1);
	}

	while (1)
	{
		if (kIsOutputBufferFull() == TRUE)
		{
			bTemp = kGetKeyboardScanCode();

			if (kConvertScanCodeToASCIICode(bTemp, &(vcTemp[0]), &bFlags) == TRUE)
			{
				if (bFlags & KEY_FLAGS_DOWN)
				{
					kPrintString(i++, 13, vcTemp);
				}
			}
		}
	}
}

void kPrintString(int iX, int iY, const char* pcString)
{
	CHARACTER* pstScreen = (CHARACTER*)0xB8000;
	int i;

	pstScreen += (iY * 80) + iX;

	for (i = 0; pcString[i] != 0; i++)
	{
		pstScreen[i].bCharacter = pcString[i];
	}
}