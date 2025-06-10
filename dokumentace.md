# CPU Dokumentace

## 1. Základní parametry

- **Datová šířka:** 16 bit
- **Délka instrukce:** 24 bit+ (1 slovo)
- **GPR (R0–R4):** 5 × 16 bit (R4 = SP)
- **Temp registr pro ALU** 16 bit
- **PC:** 16 bit, automaticky +1 nebo skok
- **Flags:** Z (Zero), N (Negative), C (Carry) – 1 bit každý
- **RAM:** 16 bit dat, adresováno 16 bit
- **ROM (instrukce):** 24 bit slova, PC as adres
- **Stack:** v RAM, roste dolů, SP = R4
- **I/O prostor:** oddělený, IN/OUT instrukce
  - Port 0 → Button (1 bit)
  - Port 1 → Joystick (4 bit: ↑↓←→)
  - Port 0–7 → LED matice (8 × 8 bit registrů)

## 2. Registry

- **R0–R3:** obecné 16 bit (3 × 16 bit)
- **R4 (SP):** stack pointer (16 bit)
  - **PUSH Rx:**
    1. `SP ← SP – 1`
    2. `M[SP] ← Rx`
  - **POP Rx:**
    1. `Rx ← M[SP]`
    2. `SP ← SP + 1`
- **PC:** 16 bit, adresuje ROM; po každé instrukci `PC ← PC + 1` (nebo skok)
- **Flags (Z, N, C):** 1 bit každý
  - `Z` = 1, pokud `ALU_out = 0`
  - `N` = 1, pokud `ALU_out[15] = 1` (výsledek záporný)
  - `C` = CarryOut z ALU (přenesení při sčítání/odečítání)

## 3. Formát instrukce (32 bit)

```

[31…26] opcode (6 bit)
[25…21] RegX  (5 bit)
[20…16] RegY  (5 bit)
[15…0] Imm16 (16 bit, sign-extended)

```

- **RegX/RegY:** kódy R0–R4
- **Imm16:** konstanta/offset/port

## 4. Adresní režimy

1. **Reg-Reg:** oba operandy z registrů (např. ADD R1,R2)
2. **Reg-Imm:** druhý operand z Imm16 (např. ADDI R3,#5)
3. **Base+Offset:** adresa = RegY + sign_ext(Imm16) (LOAD/STORE)
4. **PC-relative:** skok = PC + sign_ext(Imm16) (JUMP/JZ/JN/JC)
5. **Stack (implicit):** SP jako báze, offset = 0 (PUSH/POP)
6. **I/O space:** port = Imm16[2:0] (IN/OUT)

## 5. Instrukční sada

| Mnemonika | Opcode | Syntaxe                | Chování                          |
| :-------- | :----- | :--------------------- | :------------------------------- |
| **NOP**   | 0x00   | `NOP`                  | PC←PC+1                          |
| **ADD**   | 0x01   | `ADD Rx,Ry`            | Rx←Rx+Ry; nastaví Z,N,C; PC+1    |
| **SUB**   | 0x02   | `SUB Rx,Ry`            | Rx←Rx–Ry; nastaví Z,N,C; PC+1    |
| **ADDI**  | 0x03   | `ADDI Rx,#Imm16`       | Rx←Rx+imm; nastaví Z,N,C; PC+1   |
| **SUBI**  | 0x04   | `SUBI Rx,#Imm16`       | Rx←Rx–imm; nastaví Z,N,C; PC+1   |
| **LOAD**  | 0x05   | `LOAD Rx,[Ry+#Imm16]`  | Rx←M[Ry+imm]; nastaví Z,N; PC+1  |
| **STORE** | 0x06   | `STORE Rx,[Ry+#Imm16]` | M[Ry+imm]←Rx; PC+1               |
| **JUMP**  | 0x07   | `JUMP #Imm16`          | PC←PC+imm                        |
| **JZ**    | 0x08   | `JZ #Imm16`            | pokud Z=1, PC←PC+imm, jinak PC+1 |
| **JN**    | 0x09   | `JN #Imm16`            | pokud N=1, PC←PC+imm, jinak PC+1 |
| **JC**    | 0x0A   | `JC #Imm16`            | pokud C=1, PC←PC+imm, jinak PC+1 |
| **INP**   | 0x0B   | `IN Rx,#port`          | Rx←I/O[port]; nastaví Z,N; PC+1  |
| **OUTP**  | 0x0C   | `OUT #port,Rx`         | LED_row[port]←Rx[7:0]; PC+1      |

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

- **Button (1 bit):**

  - Port 0, 1 = stisk, 0 = neuvolněno
  - `IN Rx,#0` → Rx[0]=tlačítko, Rx[15..1]=0

- **Joystick (4 bit):**

  - Port 1, bity: [3]=↑, [2]=↓, [1]=←, [0]=→
  - `IN Rx,#1` → Rx[3..0]=stav joysticku, Rx[15..4]=0

- **LED matice 8×8:**
  - Port 0–7, `OUT #i,Rx` → LED_row[i] ← Rx[7..0]
  - LED registre (8×8 bit) drží stav, až další OUT
