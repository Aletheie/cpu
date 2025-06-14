# CPU Dokumentace

## 1. Základní parametry

- **Datová šířka:** 16 bit
- **Délka instrukce:** 32 bit (6+5+5+16)
- **GPR (R1–R6):** 6 × 16 bit
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

- **R1–R6:** obecné 16 bit (3 × 16 bit)
- **PC:** 16 bit, adresuje ROM; po každé instrukci `PC ← PC + 1` (nebo skok)
- **Flags (Z, C):** 1 bit každý
  - `Z` = 1, pokud `ALU_out = 0`
  - `C` = CarryOut z ALU (přenesení při sčítání/odečítání)

## 3. Formát instrukce (32 bit)

```
[31…26] opcode (6 bit)
[25…21] RegX  (5 bit)
[20…16] RegY  (5 bit)
[15…0] Imm16 (16 bit, sign-extended)

```

- **RegX/RegY:** kódy R1–R6
- **Imm16:** konstanta/offset/port

## 4. Adresní režimy

1. **Reg-Reg:** oba operandy z registrů (např. ADD r1,r2)
2. **Reg-Imm:** druhý operand z Imm16 (např. ADDI r3,#5)
3. **PC-relative:** skok = PC + sign_ext(Imm16) (JUMP/JZ/JN/JC)
4. **Stack (implicit):** SP jako báze(PUSH/POP)
5. **I/O space:** port = adresováno registrem (IN/OUT)

# 5. Instrukční sada (5-bitové kódy)

## 5.1. Základní

| Mnemonika | Opcode (bin) | Hex  | Syntaxe | Chování     |
| :-------: | :----------: | :--: | :-----: | :---------- |
|  **NOP**  |   `00000`    | 0x00 |  `NOP`  | PC ← PC + 1 |

---

## 5.2. ALU operace

| Mnemonika | Opcode (bin) | Hex  |    Syntaxe     |           Chování            |
| :-------: | :----------: | :--: | :------------: | :--------------------------: |
|  **AND**  |   `00001`    | 0x01 |  `AND  Rx,Ry`  |  Rx ← Rx & Ry; Z,C; PC + 1   |
|  **OR**   |   `00010`    | 0x02 |  `OR  Rx,Ry`   |  Rx ← Rx & Ry; Z,C; PC + 1   |
| **SHRI**  |   `00100`    | 0x04 | `SHR  Rx,#Imm` |  Rx ← Rx » Imm; Z,C; PC + 1  |
| **SHLI**  |   `00101`    | 0x05 | `SHL  Rx,#Imm` |  Rx ← Rx « Imm; Z,C; PC + 1  |
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

## 7. Princip spouštění instrukcí v CPU

### 7.1 Kde leží strojový kód

- **Program ROM (32 bit slova):** Veškerý strojový kód se před synthézou/naprogramováním uloží do interní ROM.
- **Adresování:** Každé slovo má 16-bitovou adresu (stejně dlouhou jako registr **PC**).
- **Nahrání kódu:** Při konfiguraci FPGA / ASIC se ROM naplní obsahem hex/mif. Během běhu už ROM pouze čteme – není zapisovatelná.

### 7.2 Inicializace a výchozí adresa

- **RESET:** Po resetu se **PC** nastaví na `0x0000` (první instrukce programu).
- Pro víc programů/bootloader, stačí změnit resetovou hodnotu PC nebo přidat úvodní skok.

### 7.3 Načítání instrukcí (Fetch)

| Krok             | Signál/registr              | Co se děje                                                                  |
| ---------------- | --------------------------- | --------------------------------------------------------------------------- |
| **1. Fetch**     | `PC → ROM`                  | Z ROM se vyčte celé **32-bitové** slovo instrukce.                          |
| **2. Increment** | `PC ← PC + 1`               | Pokud aktuální instrukce **není skok**, PC se inkrementuje o 1 (slovo).     |
| **3. Skoky**     | `PC ← PC + sign_ext(Imm16)` | U `JMP/JZ/JC` se místo inkrementu přičte podepsaný offset z pole **Imm16**. |

> Všechny instrukce jsou jedno-slovní (32 bit), takže se nikdy nemusí číst „druhé slovo“. Řadič tedy jednoduše střídá cyklus _fetch → decode → execute_ bez speciální logiky pro víceslovní opkódy.

### 7.4 Tok instrukcí během běhu

1. **Fetch** – viz výše.
2. **Decode** – instrukce se rozkouskuje na `opcode`, `RegX`, `RegY`, `Imm16`.
3. **Execute / Memory / I/O** – ALU, RAM, I/O (podle opcode).
4. **Write-back** – výsledky se uloží do registrů/flagů.
5. **PC update** – už hotovo z kroku 1 / 3, takže další fetch.

## 8. Features (HW podpora)

### 8.1 Stack & volání funkcí

- **HW stack v RAM**
- **Volání funkce (konvence):**
  1. **Před voláním**: volající uloží potřebné registry (R1–R6) na stack (`STORE Rx,[SP]`, `SUBI SP,#2`).
  2. **Skok** na začátek funkce (`JMP` / `JZ` / `JC`).
  3. **Návratová adresa** se ukládá ručně (typicky na stack) – dedikované `CALL/RET` instrukce nejsou, ale lze je nahradit sekvencí `MOV Rx,PC`, `STORE`, … a později `LOAD PC,[SP]`.
  4. **Po návratu**: volající obnoví registry (`LOAD`, `ADDI SP,#2`).

---

### 8.2 Adresní režimy × instrukce

| Režim           | Instrukce (skupiny)                                                     | Poznámka                              |
| --------------- | ----------------------------------------------------------------------- | ------------------------------------- |
| **Reg-Reg**     | `AND`, `OR`, `ADD`, `SUB`, `MOV`, `STORE`, `LOAD`                       | oba operandy registry                 |
| **Reg-Imm**     | `SHRI`, `SHLI`, `ROTRI`, `ROTLI`, `ADDI`, `SUBI`, `MOVI`, `INP`, `OUTP` | druhý operand/funkční kód v **Imm16** |
| **PC-relative** | `JUMP`, `JZ`, `JC`                                                      | offset = sign-ext(**Imm16**)          |
| **Stack**       | všechny paměťové operace používající **SP**                             | `LOAD/STORE Rx,[SP±offset]`           |
| **I/O space**   | `INP`, `OUTP`                                                           | port číslo v **Imm16**                |

---

### 8.3 Periferie & komunikace

| Periferie            | Porty |  Čtení/Zápis  | Jak na to v kódu                                    | Co udělá CPU za tebe                                                                     |
| -------------------- | :---: | :-----------: | --------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| **Tlačítka** (1 bit) |  1-4  | jen **read**  | `INP R1,#1` – stav tlačítka „nahoru“ do **R1**      | Aktivuje **IORead**, přivede vstup na sběrnici, výsledek se zapíše do cílového registru. |
| **LED matice 3×16**  |  1-3  | jen **write** | `OUTP R2,#2` – odešle 16 bit sloupec na 2. řádek    | CPU na 1 T-cyklus vystaví **RegValX[7:0]** na io_data_out a nastaví **IOWrite**.         |
| **LED dioda**        |   4   | jen **write** | `OUTP R3,#4` – zapne/vypne LED podle bit 0 v **R3** | Totéž co u matice, jen vodič vede přímo na LEDku.                                        |

Interně probíhá přístup k periferiím paralelně s ALU operacemi:

1. **Decode** rozpozná `INP/OUTP` a nastaví `IORead`/`IOWrite`.
2. **Execute** vynechá RAM; adresa periférie = `Imm16[4:0]`.
3. **Write-back** (jen pro `INP`) uloží přečtenou hodnotu do registru, nastaví příznak **Z**.
