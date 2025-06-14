# CPU Dokumentace

## 1. Základní parametry

- **Datová šířka:** 16 bit
- **Délka instrukce:** 32 bit (6+5+5+16)
- **GPR (R1–R5):** 5 × 16 bit (R4 = SP)
- **Temp registr pro ALU** 16 bit
- **PC:** 16 bit, automaticky +1 nebo skok
- **Flags:** Z (Zero), C (Carry) – 1 bit každý
- **RAM:** 16 bit dat, adresováno 16 bit
- **ROM (instrukce):** 32 bit slova, PC jako adresa
- **Stack:** v RAM, roste dolů, SP = R5
- **I/O prostor:** oddělený, IN/OUT instrukce
  - Port 1-4 → 4 tlačítka (1 bit)
  - Port 1–3 → LED matice (3 × 16 bit registrů)

## 2. Registry

- **R1–R5:** obecné 16 bit (3 × 16 bit)
- **R5 (SP):** stack pointer (16 bit)
  - **PUSH Rx:**
    1. `SP ← SP – 1`
    2. `M[SP] ← Rx`
  - **POP Rx:**
    1. `Rx ← M[SP]`
    2. `SP ← SP + 1`
- **PC:** 16 bit, adresuje ROM; po každé instrukci `PC ← PC + 1` (nebo skok)
- **Flags (Z, N, C):** 1 bit každý
  - `Z` = 1, pokud `ALU_out = 0`
  - `C` = CarryOut z ALU (přenesení při sčítání/odečítání)

## 3. Formát instrukce (32 bit)

```
[31…26] opcode (6 bit)
[25…21] RegX  (5 bit)
[20…16] RegY  (5 bit)
[15…0] Imm16 (16 bit, sign-extended)

```

- **RegX/RegY:** kódy R1–R5
- **Imm16:** konstanta/offset/port

## 4. Adresní režimy

1. **Reg-Reg:** oba operandy z registrů (např. ADD r1,r2)
2. **Reg-Imm:** druhý operand z Imm16 (např. ADDI r3,#5)
3. **Base+Offset:** adresa = RegY + sign_ext(Imm16) (LOAD/STORE)
4. **PC-relative:** skok = PC + sign_ext(Imm16) (JUMP/JZ/JN/JC)
5. **Stack (implicit):** SP jako báze(PUSH/POP)
6. **I/O space:** port = Imm16[2:0] (IN/OUT)

# 5. Instrukční sada (5-bitové kódy)

## 5.1. Základní

| Mnemonika | Opcode (bin) | Hex  | Syntaxe | Chování     |
| :-------: | :----------: | :--: | :-----: | :---------- |
|  **NOP**  |   `00000`    | 0x00 |  `NOP`  | PC ← PC + 1 |

---

## 5.2. ALU operace

| Mnemonika | Opcode (bin) | Hex  |    Syntaxe     |           Chování            |
| :-------: | :----------: | :--: | :------------: | :--------------------------: |
|  **AND**  |   `00010`    | 0x02 |  `AND  Rx,Ry`  |  Rx ← Rx & Ry; Z,C; PC + 1   |
|  **OR**   |   `00011`    | 0x03 |  `OR  Rx,Ry`   |  Rx ← Rx & Ry; Z,C; PC + 1   |
|  **SHR**  |   `00100`    | 0x04 | `SHR  Rx,#Imm` |  Rx ← Rx » Imm; Z,C; PC + 1  |
|  **SHL**  |   `00101`    | 0x05 | `SHL  Rx,#Imm` |  Rx ← Rx « Imm; Z,C; PC + 1  |
| **ROTRI** |   `00110`    | 0x06 | `ROTR Rx,#Imm` | Rx ← Rx ROR Imm; Z,C; PC + 1 |
| **ROTLI** |   `00111`    | 0x07 | `ROTL Rx,#Imm` | Rx ← Rx ROL Imm; Z,C; PC + 1 |
|  **ADD**  |   `01000`    | 0x08 |  `ADD  Rx,Ry`  |  Rx ← Rx + Ry; Z,C; PC + 1   |
|  **SUB**  |   `01001`    | 0x09 |  `SUB  Rx,Ry`  |  Rx ← Rx − Ry; Z,C; PC + 1   |
| **ADDI**  |   `01100`    | 0x0C | `ADDI Rx,#Imm` |  Rx ← Rx + Imm; Z,C; PC + 1  |
| **SUBI**  |   `01101`    | 0x0D | `SUBI Rx,#Imm` |  Rx ← Rx − Imm; Z,C; PC + 1  |

---

## 5.3. Paměťové operace

| Mnemonika | Opcode (bin) | Hex  |     Syntaxe     |       Chování       |
| :-------: | :----------: | :--: | :-------------: | :-----------------: |
| **LOAD**  |   `10000`    | 0x10 | `LOAD Rx,[Ry]`  | Rx ← M[Ry]; Z; PC+1 |
| **STORE** |   `10001`    | 0x11 | `STORE Rx,[Ry]` |  M[Ry] ← Rx; PC+1   |

---

## 5.4. Vstup/Výstup

| Mnemonika | Opcode (bin) | Hex  |     Syntaxe     |             Chování              |
| :-------: | :----------: | :--: | :-------------: | :------------------------------: |
|  **INP**  |   `10010`    | 0x12 | `INP  Rx,#port` |    Rx ← I/O[port]; Z; PC + 1     |
| **OUTP**  |   `10011`    | 0x13 | `OUTP Rx,#port` | LED_row[port] ← Rx[7..0]; PC + 1 |

---

## 5.5. Řízení toku

| Mnemonika | Opcode (bin) | Hex  |  Syntaxe   |              Chování              |
| :-------: | :----------: | :--: | :--------: | :-------------------------------: |
| **JUMP**  |   `10100`    | 0x14 | `JMP #off` |      PC ← PC + sign_ext(off)      |
|  **JZ**   |   `10101`    | 0x15 | `JZ #off`  | pokud Z=1 → PC←PC+off; jinak PC+1 |
|  **JC**   |   `10110`    | 0x16 | `JC #off`  | pokud C=1 → PC←PC+off; jinak PC+1 |

---

## 5.6. Přenos dat

| Mnemonika | Opcode (bin) | Hex  |    Syntaxe     |      Chování       |
| :-------: | :----------: | :--: | :------------: | :----------------: |
|  **MOV**  |   `10111`    | 0x17 |  `MOV  Rx,Ry`  |  Rx ← Ry; PC + 1   |
| **MOVI**  |   `11000`    | 0x18 | `MOVI Rx,#Imm` | Rx ← Imm16; PC + 1 |

## 6. Princip spuštění (Fetch-Execute)

1. **Fetch:**

   - PC → ROM → Instrukce (24 bit)
   - (Volitelně IR ← rom_out)

2. **Decode:**

   - Splitter → opcode, RegX, RegY, Imm16
   - Dekodér → jednoznačná instrukce
   - Příznaky (Z,N,C) + dekodér → řídicí signály

3. **Read Operands:**

   - RegValX = GPR[RegX]
   - RegValY = GPR[RegY]
   - Imm_ext16 = sign_extend(Imm16)

4. **Execute:**

   - A = (ALU_A_sel=0)? RegValX : PC
   - B = (ALU_B_sel=0)? RegValY : Imm_ext16
   - Pokud Sub=1: B ← ¬B, Cin=1; jinak Cin=0
   - ALU_out = A ± B, CarryOut → C_flag, Z_flag, N_flag

5. **Memory / I/O:**

   - Pokud MemRead=1: RAM_out = RAM[ALU_out]
   - Pokud MemWrite=1: RAM[ALU_out] ← RegValX
   - Pokud IORead=1: IO_In_Data = (Imm16[0]=0)? Button : Joystick
   - Pokud IOWrite=1: LED_row[Imm16[2..0]] ← RegValX[7:0]

6. **Writeback:**

   - Pokud RegWrite=1:
     - DataWB = MUX_Writeback(ALU_out, RAM_out, IO_In_Data)
     - Cílový registr = dekodér(RegDst_mux)
     - GPR[target] ← DataWB
   - Pokud FlagWrite=1:
     - Z ← Z_flag, N ← N_flag, C ← C_flag

7. **Update PC:**

   - PC ← (PCSrc=1)? ALU_out : PC + 1

8. **Další cyklus.**

---

## 7. Periferie

- **4 Buttony (1 bit):**

  - Port 0 = nic
  - Port 1 = nahoru
  - Port 2 = vlevo
  - Port 3 = dolů
  - Port 4 = vpravo

- **LED matice 3×16:**
  - Port 1-3
