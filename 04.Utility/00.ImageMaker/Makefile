all : ImageMaker.exe

#build ImageMaker
ImageMaker.exe : ImageMaker.c
	gcc -o $@ $<

#remove except source file
clean:
	rm -f ImageMaker.exe