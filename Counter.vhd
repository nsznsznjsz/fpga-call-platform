LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Counter IS
  GENERIC (
    RAM_WIDTH : NATURAL := 8
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END Counter;

ARCHITECTURE arch OF Counter IS
  SIGNAL data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
BEGIN
  data_out <= data;

  heartbeat : PROCESS (clock, reset)
  BEGIN
    IF (reset = '1') THEN
      data <= (OTHERS => '0');
    ELSIF (clock'event AND clock = '1') THEN
      data <= std_logic_vector(to_unsigned(to_integer(unsigned(data)) + 1, RAM_WIDTH));
    END IF;
  END PROCESS;
END arch;