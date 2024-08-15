# usage: .\espdump.ps1 COMx [-dir esp-dump] [-filename espdump] [-chip auto] [-baud 1500000]

# notes, memmaps, prose

# esp32
# https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf#sysmem
# Memory Map:
# Data bus:
# SRAM2: 0x3FFAE000 - 0x3FFDFFFF - 0x31FFF - 200KB
# SRAM1: 0x3FFE0000 - 0x3FFFFFFF - 0x1FFFF - 128KB
# Instruction bus:
# SRAM0.0: 0x40070000 - 0x4007FFFF - 0xFFFF - 64KB
# SRAM0.1: 0x40080000 - 0x4009FFFF - 0x1FFFF - 128KB
# #SRAM1.0: 0x400A0000 - 0x400AFFFF - 0xFFFF - 64KB
# #SRAM1.1: 0x400B0000 - 0x400B7FFF - 0x7FFF - 32KB 
# #SRAM1.2: 0x400B8000 - 0x400BFFFF - 0x7FFF - 32KB
# RTCFAST: 0x400C0000 - 0x400C1FFF - 0x1FFF - 8KB
# Data instruction bus:
# RTCSLOW: 0x50000000 - 0x50001FFF - 0x1FFF - 8KB
# .\espdump.ps1 COM55 -dir esp32-classic-dump0 -chip esp32 -filename esp32-classic                                                                                               

# esp32c3
# FlashMate-Dump-seeed-xiao-esp32c3
# SRAM0 0x40040000 - 0x3FFC 
# SRAM1 0x3FC80000 - 0x5FFF0
# RTCFast 0x50000000 - 0x2000

# esp32c6
# HP-SRAM: 0x40800000 - 0x4087FFFF - 0x7FFFF 512KB
# LP-SRAM: 0x50000000 - 0x50003FFF - 0x3FFF  16KB

# esp32s3
# Name: Start - end - length (all hex bytes)
# SRAM0: 0x40370000 - 0x40377FFF - 0x7FFF 32KB
# SRAM1: 0x3FC88000 - 0x3FCEFFFF - 0x67FFF 416KB
## SRAM2: 0x3FCF0000 - 0x3FCFFFFF - 0xFFFF 64KB
# RTCSLOW: 0x50000000 - 0x50001FFF - 0x1FFF 8KB
# RTCFAST: 0x600FE000 - 0x600FFFFF - 0x1FFF 8KB

# .\espdump.ps1 COM54 -chip esp32c6 -dir esp-c6-dump5 -filename esp32c6
# .\espdump.ps1 COM8 -chip esp32s3 -dir esp-s3-dump0 -filename esp32s3


param ($comport, $dir='esp-dump', $filename='espdump', $chip='auto', $baud=1500000)

# set up environment
$outdir = "$dir-$filename"
New-item -itemtype directory -path "$outdir"
$outtxt = "$outdir\$chip-$filename-chip_info.txt"
echo "========== STARTNG =========="

# memdumps
function memdump-header {
    echo "==== Memory Dumps ====`nFormat: <name of region>: <start addr in bytes> <length in bytes> <filename>" >> $outtxt
}

function dump-esp32 {
    memdump-header

    $filei = "MemoryDump-SRAM0.0-$filename.bin"
    echo "`n`nDumping SRAM0.0 to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x40070000 0xFFFF "$outdir\$filei"
    echo "SRAM0.0: 0x40070000 0xFFFF (64KB) - $filei"# >> 
    echo $filei
    echo $outtxt
    echo "$outdir\$filei"
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-SRAM0.1-$filename.bin"
    echo "`n`nDumping SRAM0.1 to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x40080000 0x1FFFF "$outdir\$filei"
    echo "SRAM0.1: 0x40080000 0x1FFFF (128KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-SRAM1-$filename.bin"
    echo "`n`nDumping SRAM1 to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x3FFE0000 0x1FFFF "$outdir\$filei"
    echo "SRAM1: 0x3FFE00000 0x1FFFF (128KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-SRAM2-$filename.bin"
    echo "`n`nDumping SRAM2 to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x3FFAE000 0x31FFF "$outdir\$filei"
    echo "SRAM2: 0x3FFE00000 0x1FFFF (200KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-RTCFAST-$filename.bin"
    echo "`n`nDumping RTC Fast Memory to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x400C0000 0x1FFF "$outdir\$filei"
    echo "RTC Fast Memory: 0x3FFE00000 0x1FFFF (8KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-RTCSLOW-$filename.bin"
    echo "`n`nDumping RTC Slow Memory to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x50000000 0x1FFF "$outdir\$filei"
    echo "RTC Slow Memory: 0x50000000 0x1FFF (8KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1
}

function dump-esp32c3 {
    memdump-header

    $filei = "MemoryDump-SRAM0-$filename.bin"
    echo "`n`nDumping SRAM0 to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x40040000 0x3FFC "$outdir\$filei"
    echo "SRAM0: 0x4004000 0x3FFC (16KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-SRAM1-$filename.bin"
    echo "`n`nDumping SRAM1 to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x3FC88000 0x5FFF0 "$outdir\$filei"
    echo "SRAM1: 0x3FC80000 0x5FFF0 (400KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-RTCFAST-$filename.bin"
    echo "`n`nDumping RTC Fast Memory to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x50000000 0x2000 "$outdir\$filei"
    echo "RTC Fast Memory: 0x50000000 0x2000 (8KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1
}

function dump-esp32c6 {
    memdump-header
    
    $filei = "MemoryDump-HP-SRAM-$filename.bin"
    echo "`n`nDumping High Power SRAM to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x40800000 0x7FFFF "$outdir\$filei"
    echo "High Power SRAM: 0x40800000 0x7FFFF (512KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-LP-SRAM-$filename.bin"
    echo "`n`nDumping Low Power SRAM to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x50000000 0x3FFF "$outdir\$filei"
    echo "Low Power SRAM: 0x50000000 0x3FFF (16KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1
}

function dump-esp32s3 {
    memdump-header

    $filei = "MemoryDump-SRAM0-$filename.bin"
    echo "`n`nDumping SRAM0 to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x40370000 0x7FFF "$outdir\$filei"
    echo "`nSRAM0: 0x40370000 0x7FFF (32KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-SRAM1-$filename.bin"
    echo "`n`nDumping SRAM1 to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x3FC88000 0x67FFF "$outdir\$filei"
    echo "SRAM1: 0x3FC80000 0x63FFF (416KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-RTCSLOW-$filename.bin"
    echo "`n`nDumping RTC Slow Memory to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x50000000 0x1FFF "$outdir\$filei"
    echo "RTC Slow Memory: 0x50000000 0x1FFF (8KB) -  $filei"  >> $outtxt
    Start-Sleep -Seconds 1

    $filei = "MemoryDump-RTCFAST-$filename.bin"
    echo "`n`nDumping RTC Fast Memory to $filei . . .`n`n"
    python -m esptool --no-stub --port $comport --baud $baud --chip $chip dump_mem 0x600FE000 0x1FFF "$outdir\$filei"
    echo "RTC Fast Memory: 0x600FE000 0x1FFF (8KB) - $filei" >> $outtxt
    Start-Sleep -Seconds 1
}

switch ( $chip ) {
    'esp32'   { dump-esp32 }
    'esp32c3' { dump-esp32c3 }
    'esp32c6' { dump-esp32c6 }
    'esp32s3' { dump-esp32s3 }
    default   { continue }
}

# add Flash Dump header to txt file first
Start-Sleep -Seconds 3
$filei = "FlashDump-$filename.bin"
echo "`n==== Flash Dump ====`n$filei" >> $outtxt

# efuse dump
Start-Sleep -Seconds 3
$filei = "$chip-$filename-EFUSE.txt"
echo "Dumping EFUSE Table to $filei . . ."
python -m espefuse --port $comport --chip $chip --debug summary >> "$outdir\$filei"
#python -m espefuse --port $comport --chip $chip dump >> "$outdir\$filei"

# dump chip info to txt file
$chipinfo = "$chip-$filename-chip_info.txt"
echo "`n==== $chip - $filename Info ====`n" >> $outtxt
echo "Dumping Security Info to $chipinfo . . ."
# this one throws an error with --no-stub on esp32 classic
# weird, not seeming to cooperate anymore at all on esp23 classic
# failed - result was FF00: Command not implemented)
python -m esptool --port $comport --baud $baud --chip $chip get_security_info >> $outtxt
Start-Sleep -Seconds 1
# python -m esptool --port COM55 --chip esp32 get_security_info
echo "`nFlash ID:" >> $outtxt
echo "Dumping Flash ID to $chipinfo . . ."
python -m esptool --no-stub --port $comport --baud $baud --chip $chip flash_id  >> $outtxt
echo "`nFlash status:" >> $outtxt
Start-Sleep -Seconds 1
echo "Dumping Flash Status to $chipinfo . . ."
python -m esptool --no-stub --port $comport --baud $baud --chip $chip read_flash_status >> $outtxt
echo "`nChip ID:" >> $outtxt
Start-Sleep -Seconds 1
echo "Dumping Chip ID to $chipinfo . . ."
python -m esptool --no-stub --port $comport --baud $baud --chip $chip chip_id >> $outtxt
Start-Sleep -Seconds 1

# flash dump
echo "`n`nDumping Flash to $filei . . .`n`n"
python -m esptool --port $comport --baud $baud --chip $chip read_flash 0 ALL "$outdir\$filei" 

echo "`n`n========== DONE ==========`n`n"