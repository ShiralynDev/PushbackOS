# cd ..

nasm "./bootloader.asm" -f bin -o "flp/bootloader.bin"

# nasm "Sector 2+/ExtendedProgram.asm" -f bin -o "flp/ExtendedProgram.bin"

# cat "flp/bootloader.bin" "flp/ExtendedProgram.bin" > "flp/main.img"
cat "flp/bootloader.bin" > "flp/main.iso"
# genisoimage -o flp/main.iso -b bootloader.bin -no-emul-boot -boot-load-size 4 -boot-info-table -R -J flp/

qemu-system-x86_64 "flp/main.iso" 