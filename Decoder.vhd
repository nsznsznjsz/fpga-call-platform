LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Decoder IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16;
    WORD_LENGTH : NATURAL := 5
  );
  PORT (
    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(WORD_LENGTH * 8 - 1 DOWNTO 0)
  );
END Decoder;

ARCHITECTURE arch OF Decoder IS
  -- If you are updating flags, you need: 
  -- 1. Update README
  -- 2. Synchronous update `Waiting`, `Service` and `Decoder`
  -- 3. Check groups flag is right, vip_flags = bit_xor(vip, group)
  --
  -- I try my best to maintain the consistency of the flags, but we
  -- need a better way to replace the manual operation. 

  CONSTANT FLAG_SCREEN_WAITING : std_logic_vector(1 DOWNTO 0) := "10";
  CONSTANT FLAG_SCREEN_SERVICE : std_logic_vector(1 DOWNTO 0) := "11";

  CONSTANT FLAG_GROUP_FREE : std_logic_vector(3 DOWNTO 0) := "0000";
  CONSTANT FLAG_GROUP_A : std_logic_vector(3 DOWNTO 0) := "0001";
  CONSTANT FLAG_GROUP_B : std_logic_vector(3 DOWNTO 0) := "0010";
  CONSTANT FLAG_GROUP_VIPA : std_logic_vector(3 DOWNTO 0) := "1001";
  CONSTANT FLAG_GROUP_VIPB : std_logic_vector(3 DOWNTO 0) := "1010";

  CONSTANT FLAG_ERROR_FREE : std_logic_vector(1 DOWNTO 0) := "00";
  CONSTANT FLAG_ERROR_QUEUE_EMPTY : std_logic_vector(1 DOWNTO 0) := "10";
  CONSTANT FLAG_ERROR_QUEUE_FULL : std_logic_vector(1 DOWNTO 0) := "11";
  CONSTANT FLAG_ERROR_UNKNOWN : std_logic_vector(1 DOWNTO 0) := "01";

  SUBTYPE ASCII IS std_logic_vector(7 DOWNTO 0);

  CONSTANT A : ASCII := "01000001";
  CONSTANT B : ASCII := "01000010";
  CONSTANT E : ASCII := "01000101";
  CONSTANT G : ASCII := "01000111";
  CONSTANT O : ASCII := "01001111";
  CONSTANT R : ASCII := "01010010";
  CONSTANT S : ASCII := "01010011";
  CONSTANT V : ASCII := "01010110";
  CONSTANT W : ASCII := "01010111";
  CONSTANT X : ASCII := "01011000";

  CONSTANT d0 : ASCII := "00110000";
  CONSTANT d1 : ASCII := "00110001";
  CONSTANT d2 : ASCII := "00110010";
  CONSTANT d3 : ASCII := "00110011";
  CONSTANT d4 : ASCII := "00110100";
  CONSTANT d5 : ASCII := "00110101";
  CONSTANT d6 : ASCII := "00110110";
  CONSTANT d7 : ASCII := "00110111";
  CONSTANT d8 : ASCII := "00111000";
  CONSTANT d9 : ASCII := "00111001";

  SUBTYPE NUM IS std_logic_vector((WORD_LENGTH - 3) * 8 - 1 DOWNTO 0);
  TYPE NUMBERS IS ARRAY(0 TO WORD_LENGTH - 4) OF ASCII;

  FUNCTION to_number(num : NUMBERS) RETURN STD_LOGIC_VECTOR IS
    VARIABLE number : STD_LOGIC_VECTOR((num'length * 8) - 1 DOWNTO 0);
  BEGIN
    FOR i IN num'RANGE LOOP
      number((i * 8) + 7 DOWNTO (i * 8)) := num(i);
    END LOOP;
    RETURN number;
  END FUNCTION;

BEGIN
  PROCESS (data_in)
    VARIABLE screen : ASCII;
    VARIABLE groups : std_logic_vector(15 DOWNTO 0);
    VARIABLE numbers : NUMBERS;
    VARIABLE number : NUM;
    VARIABLE scan : INTEGER; -- TODO range refactor needed
  BEGIN
    IF (data_in(RAM_WIDTH - 7 DOWNTO RAM_WIDTH - 8) = FLAG_ERROR_FREE) THEN
      CASE(data_in(RAM_WIDTH - 1 DOWNTO RAM_WIDTH - 2)) IS
      WHEN FLAG_SCREEN_WAITING => screen := W;
      WHEN FLAG_SCREEN_SERVICE => screen := S;
      WHEN OTHERS => screen := X;
      END CASE;

      CASE (data_in(RAM_WIDTH - 3 DOWNTO RAM_WIDTH - 6)) IS
        WHEN FLAG_GROUP_A => groups := G & A;
        WHEN FLAG_GROUP_B => groups := G & B;
        WHEN FLAG_GROUP_VIPA => groups := V & A;
        WHEN FLAG_GROUP_VIPB => groups := V & B;
        WHEN OTHERS => groups := X & X;
      END CASE;

      scan := to_integer(unsigned(data_in(RAM_WIDTH - 9 DOWNTO 0)));
      FOR i IN numbers'RANGE LOOP
        CASE (scan MOD 10) IS
          WHEN 0 => numbers(i) := d0;
          WHEN 1 => numbers(i) := d1;
          WHEN 2 => numbers(i) := d2;
          WHEN 3 => numbers(i) := d3;
          WHEN 4 => numbers(i) := d4;
          WHEN 5 => numbers(i) := d5;
          WHEN 6 => numbers(i) := d6;
          WHEN 7 => numbers(i) := d7;
          WHEN 8 => numbers(i) := d8;
          WHEN 9 => numbers(i) := d9;
          WHEN OTHERS => numbers(i) := d0;
        END CASE;
        scan := scan / 10;
      END LOOP;

      number := to_number(numbers);
      data_out <= screen & groups & number;
    ELSE
      data_out <= E & R & R & O & R; -- TODO length error
    END IF;
  END PROCESS;
END arch;