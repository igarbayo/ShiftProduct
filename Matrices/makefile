CC = gcc
OUTPUT_DIR = ensamblador
OBJECT_DIR = objeto

all: code generate_asm generate_object

generate_object:
	mkdir -p $(OBJECT_DIR)
	$(CC) -O0 code.c -o $(OBJECT_DIR)/O0.o
	$(CC) -O1 code.c -o $(OBJECT_DIR)/O1.o
	$(CC) -O2 code.c -o $(OBJECT_DIR)/O2.o
	$(CC) -O3 code.c -o $(OBJECT_DIR)/O3.o
	$(CC) -Os code.c -o $(OBJECT_DIR)/Os.o

generate_asm:
	mkdir -p $(OUTPUT_DIR)
	$(CC) -O0 -S code.c -o $(OUTPUT_DIR)/O0.s -fverbose-asm
	$(CC) -O1 -S code.c -o $(OUTPUT_DIR)/O1.s -fverbose-asm
	$(CC) -O2 -S code.c -o $(OUTPUT_DIR)/O2.s -fverbose-asm
	$(CC) -O3 -S code.c -o $(OUTPUT_DIR)/O3.s -fverbose-asm
	$(CC) -Os -S code.c -o $(OUTPUT_DIR)/Os.s -fverbose-asm

code: code.c
	$(CC) -O0 code.c -o P1_O0 -Wall
	$(CC) -O1 code.c -o P1_O1 -Wall
	$(CC) -O2 code.c -o P1_O2 -Wall
	$(CC) -O3 code.c -o P1_O3 -Wall
	$(CC) -Os code.c -o P1_Os -Wall
clean:
	rm -f P1*

