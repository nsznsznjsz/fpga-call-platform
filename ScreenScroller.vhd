LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.config.ALL;
USE work.ascii.ALL;

ENTITY ScreenScroller IS
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;
    data_out : OUT std_logic_vector(WORD_WIDTH - 1 DOWNTO 0)
  );
END ScreenScroller;

ARCHITECTURE arch OF ScreenScroller IS
  CONSTANT HIGH : INTEGER := 12 * 8 - 1;
  CONSTANT LOW : INTEGER := HIGH - (WORD_WIDTH - 1);
  CONSTANT STUDENT_ID : unsigned(HIGH DOWNTO 0) := unsigned(d1 & d7 & d0 & d1 & d5 & d3 & d3 & d9 & d5 & X & X & X);
  SIGNAL cur : unsigned(HIGH DOWNTO 0) := STUDENT_ID;

  FUNCTION slice(id : unsigned) RETURN std_logic_vector IS
  BEGIN
    RETURN std_logic_vector(id(HIGH DOWNTO LOW));
  END FUNCTION;
BEGIN
  PROCESS (clock, reset)
  BEGIN
    IF (reset = '1') THEN
      data_out <= slice(STUDENT_ID);
      cur <= STUDENT_ID;
    ELSIF (clock'event AND clock = '1') THEN
      data_out <= std_logic_vector(cur(HIGH DOWNTO LOW));
      cur <= cur ROL 8;
    END IF;
  END PROCESS;
END arch;