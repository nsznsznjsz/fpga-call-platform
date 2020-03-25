LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- È¡ºÅÆ÷
ENTITY Waiting IS
  PORT (
    get : IN std_logic;

    en_in : OUT std_logic;

    data_in : IN std_logic_vector(7 DOWNTO 0);
    data_out : OUT std_logic_vector(7 DOWNTO 0)
  );
END Waiting;

ARCHITECTURE rtl OF Waiting IS
  SIGNAL s_en_in : std_logic;
  SIGNAL data : std_logic_vector(7 DOWNTO 0);
BEGIN
  -- È¡ºÅ
  get_number : PROCESS (get)
  BEGIN
    s_en_in <= '1';
  END PROCESS;

  -- ÊäÈë data
  data_receiver : PROCESS (s_en_in, data_in)
  BEGIN
    IF (data_in'event AND s_en_in = '1') THEN
      data <= data_in;
      s_en_in <= '0';
    END IF;
  END PROCESS;

  -- ¼àÌý data
  data_output : PROCESS (data)
  BEGIN
    data_out <= data;
  END PROCESS;

  -- ¼àÌý s_en_in
  output_en_in : PROCESS (s_en_in)
  BEGIN
    en_in <= s_en_in;
  END PROCESS;
END rtl;