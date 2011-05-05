@echo off
cd content
..\mkisofs -r -b boot.bin -c boot.catalog -o ../basic.iso -V AiR-BOOT .
cd ..
