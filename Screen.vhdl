LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Screen IS
  PORT (
    clock : IN std_logic;
    data_in : IN std_logic_vector(7 DOWNTO 0)
  );
END Screen;

ARCHITECTURE arch OF Screen IS
BEGIN
END arch;