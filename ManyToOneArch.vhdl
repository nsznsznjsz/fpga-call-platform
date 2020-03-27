LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY ManyToOneArch IS
  PORT (
    clock : IN std_logic;
    clock_div : INOUT std_logic;

    enable_out : IN std_logic;

    enable1 : IN std_logic;
    enable2 : IN std_logic;
    enable3 : IN std_logic;
    enable4 : IN std_logic;

    emitted1 : OUT std_logic;
    emitted2 : OUT std_logic;
    emitted3 : OUT std_logic;
    emitted4 : OUT std_logic;

    data_in1 : IN std_logic_vector(7 DOWNTO 0); -- length
    data_in2 : IN std_logic_vector(7 DOWNTO 0); -- length
    data_in3 : IN std_logic_vector(7 DOWNTO 0); -- length
    data_in4 : IN std_logic_vector(7 DOWNTO 0); -- length
    data_out : OUT std_logic_vector(7 DOWNTO 0) -- length
  );
END ManyToOneArch;

ARCHITECTURE arch OF ManyToOneArch IS
  TYPE states IS(idle, disabled, a, b, c, d);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL active : INTEGER RANGE 0 TO 4 := 0;
BEGIN
  -- clock trigger
  PROCESS (clock)
  BEGIN
    IF (enable_out = '0') THEN
      present_state <= disabled;
    ELSIF (clock'event AND clock = '1') THEN
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

      WHEN disabled =>
        next_state <= idle;

      WHEN idle =>
        IF (enable1 = '1') THEN
          next_state <= a;
        ELSIF (enable2 = '1') THEN
          next_state <= b;
        ELSIF (enable3 = '1') THEN
          next_state <= c;
        ELSIF (enable4 = '1') THEN
          next_state <= d;
        ELSE
          next_state <= idle;
        END IF;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in1, data_in2, data_in3, data_in4)
  BEGIN
    -- TODO 当前实现会导致二分频
    clock_div <= '1';
    emitted1 <= '0';
    emitted2 <= '0';
    emitted3 <= '0';
    emitted4 <= '0';

    CASE present_state IS
      WHEN a =>
        data_out(7 DOWNTO 0) <= data_in1(7 DOWNTO 0);
        emitted1 <= '1';

      WHEN b =>
        data_out(7 DOWNTO 0) <= data_in2(7 DOWNTO 0);
        emitted2 <= '1';

      WHEN c =>
        data_out(7 DOWNTO 0) <= data_in3(7 DOWNTO 0);
        emitted3 <= '1';

      WHEN d =>
        data_out(7 DOWNTO 0) <= data_in4(7 DOWNTO 0);
        emitted4 <= '1';

      WHEN disabled =>
        clock_div <= '0';

      WHEN idle =>
        clock_div <= '0';
    END CASE;
  END PROCESS;
END arch;