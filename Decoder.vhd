LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.config.ALL;
USE work.ascii.ALL;

ENTITY Decoder IS
  PORT (
    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(WORD_WIDTH - 1 DOWNTO 0)
  );
END Decoder;

ARCHITECTURE arch OF Decoder IS

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
    VARIABLE error_flag : std_logic_vector(FLAG_ERROR_HIGH DOWNTO FLAG_ERROR_LOW);

    VARIABLE screen : ASCII;
    VARIABLE groups : std_logic_vector(15 DOWNTO 0);
    VARIABLE numbers : NUMBERS;
    VARIABLE number : NUM;
    VARIABLE scan : INTEGER;
  BEGIN
    error_flag := data_in(FLAG_ERROR_HIGH DOWNTO FLAG_ERROR_LOW);

    IF (error_flag = FLAG_ERROR_FREE) THEN
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

    ELSIF (error_flag = FLAG_ERROR_QUEUE_FULL) THEN
      data_out <= F & U & L & L & L; -- TODO length locked at 5

    ELSIF (error_flag = FLAG_ERROR_QUEUE_EMPTY) THEN
      data_out <= E & M & P & T & Y; -- TODO length locked at 5

    ELSIF (error_flag = FLAG_ERROR_NON_DATA) THEN
      data_out <= N & U & L & L & L; -- TODO length locked at 5

    ELSE
      data_out <= E & R & R & O & R; -- TODO length locked at 5

    END IF;
  END PROCESS;
END arch;