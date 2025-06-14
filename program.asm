
#bankdef main
{
    #bits 32
    #addr 0x0000
    #size 0xffff
    #outp 0
}

#bank main

#subruledef reg
{
    r1 => 0x1
    r2 => 0x2
    r3 => 0x3
    r4 => 0x4
    r5 => 0x5
    r6 => 0x6
}

#ruledef
{
    nop
      => 0b000000`6 @ 0b00000`5 @ 0b00000`5 @ 0b0000000000000000`16

    and   { r: reg }, { v: reg }
      => 0b000010`6 @ r`5 @ v`5 @ 0b0000000000000000`16

    or    { r: reg }, { v: reg }
      => 0b000011`6 @ r`5 @ v`5 @ 0b0000000000000000`16

    shri  { r: reg }, { val: i16 }
      => 0b000100`6 @ r`5 @ 0b00000`5 @ val`16

    shli  { r: reg }, { val: i16 }
      => 0b000101`6 @ r`5 @ 0b00000`5 @ val`16

    rotri { r: reg }, { val: i16 }
      => 0b000110`6 @ r`5 @ 0b00000`5 @ val`16

    rotli { r: reg }, { val: i16 }
      => 0b000111`6 @ r`5 @ 0b00000`5 @ val`16

    add   { r: reg }, { v: reg }
      => 0b001000`6 @ r`5 @ v`5 @ 0b0000000000000000`16

    sub   { r: reg }, { v: reg }
      => 0b001001`6 @ r`5 @ v`5 @ 0b0000000000000000`16

    addi  { r: reg }, { val: i16 }
      => 0b001100`6 @ r`5 @ 0b00000`5 @ val`16

    subi  { r: reg }, { val: i16 }
      => 0b001101`6 @ r`5 @ 0b00000`5 @ val`16

    load  { dst: reg }, { base: reg }
      => 0b010000`6 @ dst`5 @ base`5 @ 0b0000000000000000`16

    store { src: reg }, { addr: reg }
      => 0b010001`6 @ src`5 @ addr`5 @ 0b0000000000000000`16

    inp   { dst: reg }, { port: reg }
      => 0b010010`6 @ dst`5 @ port`5 @ 0b0000000000000000`16

    outp  { src: reg }, { port: reg }
      => 0b010011`6 @ src`5 @ port`5 @ 0b0000000000000000`16

    jmp  { off: i16 }
      => 0b010100`6 @ 0b00000`5 @ 0b00000`5 @ off`16

    jz   { off: i16 }
      => 0b010101`6 @ 0b00000`5 @ 0b00000`5 @ off`16

    jc   { off: i16 }
      => 0b010110`6 @ 0b00000`5 @ 0b00000`5 @ off`16

    mov   { dst: reg }, { src: reg }
      => 0b010111`6 @ dst`5 @ src`5 @ 0b0000000000000000`16

    movi  { dst: reg }, { val: i16 }
      => 0b011000`6 @ dst`5 @ 0b00000`5 @ val`16
}

#bank main

nop
movi  r1, 0x1234
mov   r2, r1
store r1, r2
load  r2, r1
add   r2, r1
sub   r2, r1
addi  r2, 1
subi  r2, 1
movi  r3, 0x00FF
and   r3, r1
or    r3, r1
shli  r3, 4            
shri  r3, 4            
rotli r3, 8           
rotri r3, 8            

movi  r4, 0x0100      
store r1, r4          
movi  r5, 0
load  r5, r4          

sub   r5, r5           
movi  r6, 0xDEAD     

; vynulovani
movi  r1, 0
movi  r2, 0
movi  r3, 0
movi  r4, 0
movi  r5, 0
movi  r6, 0

movi  r4, 1        ; PORT 1  (LED sloupec 0 + tlačítko ⬆)
movi  r5, 2        ; PORT 2  (LED sloupec 1 + tlačítko ⬅)
movi  r6, 3        ; PORT 3  (LED sloupec 2 + tlačítko ⬇)

movi  r1, 1        ; X-pozice (0–2) – start uprostřed
movi  r2, 1        ; bitová maska řádku – start nahoře

movi  r3, 0
outp  r3, r4
outp  r3, r5
outp  r3, r6

; === hlavní smyčka ===================================
main_loop:
    mov   r3, r1
    and   r3, r3
    jz    draw_x0          ; X == 0 → PORT 1

    mov   r3, r1
    subi  r3, 1
    and   r3, r3
    jz    draw_x1          ; X == 1 → PORT 2

    outp  r2, r6           ; LED do PORT 3
    movi  r3, 0
    outp  r3, r4           ; ostatní porty = 0
    outp  r3, r5
    jmp   inputs

draw_x0:
    outp  r2, r4           ; LED do PORT 1
    movi  r3, 0
    outp  r3, r5
    outp  r3, r6
    jmp   inputs

draw_x1:
    outp  r2, r5           ; LED do PORT 2
    movi  r3, 0
    outp  r3, r4
    outp  r3, r6
    ; fall-through

inputs:
    ; -------- tlačítko ⬆ (PORT 1) --------------------
    inp   r3, r4
    and   r3, r3
    jz    check_left
    rotli r2, 1            ; nahoru (wrap)

check_left:
    ; -------- tlačítko ⬅ (PORT 2) --------------------
    inp   r3, r5
    and   r3, r3
    jz    check_down
    mov   r3, r1
    and   r3, r3            ; X == 0 ?
    jz    check_down
    subi  r1, 1             ; X--

check_down:
    ; -------- tlačítko ⬇ (PORT 3) --------------------
    inp   r3, r6
    and   r3, r3
    jz    check_right
    rotri r2, 1             ; dolů (wrap)

check_right:
    ; -------- tlačítko ➡ (PORT 4) --------------------
    addi  r6, 1             ; r6 = 4 dočasně
    inp   r3, r6
    and   r3, r3
    jz    restore_r6
    mov   r3, r1
    subi  r3, 2             ; X == 2 ?
    and   r3, r3
    jz    restore_r6
    addi  r1, 1             ; X++

restore_r6:
    subi  r6, 1             ; zpět na 3

    nop                     ; malá pauza
    jmp   main_loop
