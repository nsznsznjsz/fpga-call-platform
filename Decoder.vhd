LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.config.ALL;

ENTITY Decoder IS
  PORT (
    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(WORD_WIDTH * 8 - 1 DOWNTO 0)
  );
END Decoder;

ARCHITECTURE arch OF Decoder IS
  SUBTYPE ASCII IS std_logic_vector(7 DOWNTO 0);

  CONSTANT A : ASCII := "01000001";
  CONSTANT B : ASCII := "01000010";
  CONSTANT C : ASCII := "01000011";
  CONSTANT D : ASCII := "01000100";
  CONSTANT E : ASCII := "01000101";
  CONSTANT F : ASCII := "01000110";
  CONSTANT G : ASCII := "01000111";
  CONSTANT H : ASCII := "01001000";
  CONSTANT I : ASCII := "01001001";
  CONSTANT J : ASCII := "01001010";
  CONSTANT K : ASCII := "01001011";
  CONSTANT L : ASCII := "01001100";
  CONSTANT M : ASCII := "01001101";
  CONSTANT N : ASCII := "01001110";
  CONSTANT O : ASCII := "01001111";
  CONSTANT P : ASCII := "01010000";
  CONSTANT Q : ASCII := "01010001";
  CONSTANT R : ASCII := "01010010";
  CONSTANT S : ASCII := "01010011";
  CONSTANT T : ASCII := "01010100";
  CONSTANT U : ASCII := "01010101";
  CONSTANT V : ASCII := "01010110";
  CONSTANT W : ASCII := "01010111";
  CONSTANT X : ASCII := "01011000";
  CONSTANT Y : ASCII := "01011001";
  CONSTANT Z : ASCII := "01011010";

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

  SUBTYPE NUM IS std_logic_vector((WORD_WIDTH - 3) * 8 - 1 DOWNTO 0);
  TYPE NUMBERS IS ARRAY(0 TO WORD_WIDTH - 4) OF ASCII;

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
    VARIABLE scan : INTEGER;
  BEGIN
    IF (data_in(FLAG_ERROR_HIGH DOWNTO FLAG_ERROR_LOW) = FLAG_ERROR_FREE) THEN
      CASE(data_in(FLAG_SCREEN_HIGH DOWNTO FLAG_SCREEN_LOW)) IS
        WHEN FLAG_SCREEN_WAITING => screen := W;
        WHEN FLAG_SCREEN_SERVICE => screen := S;
        WHEN OTHERS => screen := X;
      END CASE;

      CASE (data_in(FLAG_GROUP_HIGH DOWNTO FLAG_GROUP_LOW)) IS
        WHEN FLAG_GROUP_A => groups := G & A;
        WHEN FLAG_GROUP_B => groups := G & B;
        WHEN FLAG_GROUP_VIPA => groups := V & A;
        WHEN FLAG_GROUP_VIPB => groups := V & B;
        WHEN OTHERS => groups := X & X;
      END CASE;

      scan := to_integer(unsigned(data_in(DATA_WIDTH - 1 DOWNTO 0)));
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

    ELSIF (data_in(FLAG_ERROR_HIGH DOWNTO FLAG_ERROR_LOW) = FLAG_ERROR_QUEUE_FULL) THEN
      data_out <= F & U & L & L & L; -- TODO length locked at 5

    ELSIF (data_in(FLAG_ERROR_HIGH DOWNTO FLAG_ERROR_LOW) = FLAG_ERROR_QUEUE_EMPTY) THEN
      data_out <= E & M & P & T & Y; -- TODO length locked at 5

    ELSE
      data_out <= E & R & R & O & R; -- TODO length locked at 5
    END IF;
  END PROCESS;
END arch;