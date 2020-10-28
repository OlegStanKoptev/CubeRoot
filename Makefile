CC = fasm
bnr: app.asm
	$(CC) app.asm
	gcc app.o -o app -lm
	./$(output)
dump: app.asm
	objdump -S -M intel -d app > obj.dump