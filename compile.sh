# cd ..

nasm "./bootloader.asm" -f bin -o "flp/bootloader.bin"

nasm "./ExtendedProgram.asm" -f bin -o "flp/ExtendedProgram.bin"

# cat "flp/bootloader.bin" "flp/ExtendedProgram.bin" > "flp/main.img"
cat "flp/bootloader.bin" "flp/ExtendedProgram.bin" > "flp/main.bin"
# genisoimage -o flp/main.iso -b bootloader.bin -no-emul-boot -boot-load-size 4 -boot-info-table -R -J flp/

dd if=/dev/zero of=flp/floppy.img bs=512 count=2880 2>/dev/null
dd if=flp/bootloader.bin of=flp/floppy.img conv=notrunc 2>/dev/null
dd if=flp/ExtendedProgram.bin of=flp/floppy.img seek=1 conv=notrunc 2>/dev/null

qemu-system-x86_64 -fda flp/floppy.img -boot a