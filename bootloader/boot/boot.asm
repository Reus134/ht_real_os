org 0x7c00
BaseOfStack equ 0x7c00
BaseofLoader equ 0x1000
OffsetOfLoader equ 0x00
RootDirSectors equ  14
SectorNumOfRootDirStart equ    19
SectorNumOfFAT1start equ    1
SectorBalance equ   17

    jmp short Label_start
    nop
    BS_OEMName  db 'MINEboot'
    BPB_BytesPerSec dw 512
    BPB_SecPerClus  db 1    
    BPB_RsvdSecCnt db 1     
    BPB_NumFATs db 2        
    BPB_RootEntCnt dw 224   
    BPB_TotSec16 dw 2880
    BPB_Media db 0xf0
    BPB_FATSz16 dw 9
    BPB_SecPerTrk dw 18
    BPB_NumHeads dw 2
    BPB_hiddSec dd 0
    BPB_TotSec32 dd 0
    BS_DrvNum db 0
    BS_Reserved1 db 0
    BS_BootSig db 29h
    BS_VolID dd 0
    BS_VolLab db 'boot loader'
    BS_FileSysType db 'FAT12   '

;=======   read one sector from floppy
Func_ReadOneSector:
    push bp
    mov bp,sp
    sub esp,2
    mov byte [bp-2],cl
    push bx
    mov bl,[BPB_SecPerTrk]
    div bl
    inc ah
    mov cl,ah
    mov dh,al
    shr al,1    ;Logical move right
    mov ch,al
    and dh,1
    pop bx
    mov dl,[BS_DrvNum]
Label_Go_On_Reading:
    mov ah,2
    mov al,byte [bp-2]
    int 13h
    jc Label_Go_On_Reading
        add esp,2
        pop bp
        ret

;===== search loader.bin
    mov word [SectorNo],SectorNumOfRootDirStart
Label_Search_In_Root_Dir_Begin:
    cmp word [RootDirSizeForloop],0
    jz Lable_No_LoaderBin
    dec word [RootDirSizeForloop]
    mov ax,00h
    mov es,ax
    mov bx,8000h
    mov ax,[SectorNo]
    mov cl,1
    call Func_ReadOneSector
    mov si,LoaderFileName
    mov di,8000h
    cld
    mov dx,10h
Label_Search_For_LoaderBin:
    cmp dx,0
    jz Label_Goto_Next_Sector_In_Root_Dir
    dec dx
    mov cx,11
Label_Cmp_FileName:
    cmp cx,0
    jz Label_FileName_Found
    dec cx
    lodsb
    cmp al,byte [es:di]
    jz Label_Go_On
    jmp Label_Different
Label_Go_On:
    inc di
    jmp Label_Cmp_FileName
Label_Different:
    and di,0ffeh
    add di,20h
    mov si,LoaderFileName
    jmp Label_Search_For_LoaderBin
Lebel_Goto_Next_Sector_In_Root_Dir:
    add word [SectorNo],1
    jmp Label_Search_In_Root_Dir_Begin

Label_start:
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,BaseOfStack

;======clear screen
    mov ax,0600h
    mov bx,0700h
    mov cx,0
    mov dx,0184fh
    int 10h
;======set focus 
    mov ax,0200h
    mov bx,0000h
    mov dx,0000h
    int 10h
;======display screen; Start Booting ht_os;
    mov ax,1301h
    mov bx,000fh
    mov dx,0000h
    mov cx,19
    push ax
    mov ax,ds
    mov es,ax
    pop ax
    mov bp,StartBootMessage
    int 10h

;======reset floppy
    xor ah,ah
    xor dl,dl
    int 13h
    jmp $

StartBootMessage: db "Start Booting ht_os"
;======fill zero untill whole sector
    times 510-($-$$) db 0
    dw 0xaa55

