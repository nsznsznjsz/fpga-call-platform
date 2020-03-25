LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY CounterArch IS
  PORT (
    clock : IN std_logic;
    clock_div : INOUT std_logic;

    input1 : IN std_logic;
    input2 : IN std_logic;
    input3 : IN std_logic;
    input4 : IN std_logic;

    enable1 : OUT std_logic;
    enable2 : OUT std_logic;
    enable3 : OUT std_logic;
    enable4 : OUT std_logic;

    data_in : IN std_logic_vector(7 DOWNTO 0); -- length
    data_out : OUT std_logic_vector(7 DOWNTO 0) -- length
  );
END CounterArch;

ARCHITECTURE arch OF CounterArch IS
  TYPE states IS(idle, a, b, c, d);
  SIGNAL present_state : states;
  SIGNAL next_state : states;
  SIGNAL active : INTEGER RANGE 0 TO 4 := 0;

  -- SIGNAL lock : std_logic;
BEGIN

  PROCESS (data_in)
  BEGIN
    data_out <= data_in;
  END PROCESS;

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
      WHEN a =>
        next_state <= idle;
      WHEN b =>
        next_state <= idle;
      WHEN c =>
        next_state <= idle;
      WHEN d =>
        next_state <= idle;
      WHEN idle =>
        IF (input1 = '1') THEN
          next_state <= a;
        ELSIF (input2 = '1') THEN
          next_state <= b;
        ELSIF (input3 = '1') THEN
          next_state <= c;
        ELSIF (input4 = '1') THEN
          next_state <= d;
        ELSE
          next_state <= idle;
        END IF;
      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state)
  BEGIN
    -- TODO 当前实现会导致二分频
    clock_div <= '1';
    enable1 <= '0';
    enable2 <= '0';
    enable3 <= '0';
    enable4 <= '0';
    CASE present_state IS
      WHEN a =>
        enable1 <= '1';
      WHEN b =>
        enable2 <= '1';
      WHEN c =>
        enable3 <= '1';
      WHEN d =>
        enable4 <= '1';
      WHEN idle =>
        clock_div <= '0';
    END CASE;
  END PROCESS;
END arch;