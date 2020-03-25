LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Counter IS
  PORT (
    clock : IN std_logic;
    data_out : OUT std_logic_vector(7 DOWNTO 0)
  );
END Counter;

ARCHITECTURE arch OF Counter IS
  SIGNAL data : INTEGER RANGE 0 TO 127;
BEGIN
  data <= 0;

  heartbeat : PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      data <= data + 1;
    END IF;
  END PROCESS;

  data_output : PROCESS (data)
  BEGIN
    IF (data'event) THEN
      data_out <= conv_std_logic_vector(data, 7);
    END IF;
  END PROCESS;
END arch;