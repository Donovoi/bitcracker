all: bitcracker_hash

bitcracker_hash: bitcracker_hash.c
	gcc bitcracker_hash.c -o bitcracker_hash

clean:
	rm -rf *.o
	rm -rf bitcracker_hash
	rm -rf ../build/bitcracker_hash

.PHONY: all clean
