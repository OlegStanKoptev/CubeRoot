CC = fasm
file = app.asm
obj = app.o
output = app
bnr: app.asm
	$(CC) $(file)
	gcc $(obj) -o $(output) -lm
	./$(output)
dump: app.asm
	objdump -S -M intel -d $(output) > obj.dump