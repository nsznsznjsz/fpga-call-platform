LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY NumberGetter IS
  PORT (
    clock : IN std_logic;

    get : IN std_logic;
    enable_read : IN std_logic;
    enable_next : OUT std_logic;

    data_in : IN std_logic_vector(7 DOWNTO 0);
    data_out : OUT std_logic_vector(7 DOWNTO 0)
  );
END NumberGetter;

ARCHITECTURE arch OF NumberGetter IS
  TYPE states IS(idle, waiting, receive, received);
  SIGNAL present_state : states;
  SIGNAL next_state : states;
BEGIN
  -- clock trigger
  PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (get = '1') THEN
          next_state <= idle;
        ELSE
          next_state <= waiting;
        END IF;

      WHEN waiting =>
        IF (enable_read = '1') THEN
          next_state <= receive;
        ELSE
          next_state <= waiting;
        END IF;

      WHEN received =>
        next_state <= idle;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state change
  PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        enable_next <= '0';

      WHEN waiting =>
        enable_next <= '1';

      WHEN received =>
        data_out(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
        enable_next <= '0';
    END CASE;
  END PROCESS;
END arch;