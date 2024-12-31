# cd ..

nasm "./bootloader.asm" -f bin -o "flp/bootloader.bin"

# nasm "Sector 2+/ExtendedProgram.asm" -f bin -o "flp/ExtendedProgram.bin"

# cat "flp/bootloader.bin" "flp/ExtendedProgram.bin" > "flp/main.img"
cat "flp/bootloader.bin" > "flp/main.img"

qemu-system-x86_64 "flp/main.img"