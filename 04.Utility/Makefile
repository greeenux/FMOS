
all: imagemaker

imagemaker:
	@echo
	@echo ==================== Build ImageMaker ====================
	@echo

	make -C 00.ImageMaker
	mv 00.ImageMaker/ImageMaker ./ImageMaker.exe

	@echo
	@echo ==================== Build ImageMaker Complete ====================
	@echo

clean:
	make -C 00.ImageMaker clean
	rm -f ImageMaker.exe