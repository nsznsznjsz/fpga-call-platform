LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- 多个数据依次进入一个队列, 1 -> 2 -> 3 -> 4
ENTITY ManyToOneArch IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16
  );
  PORT (
    clock : IN std_logic;

    push : OUT std_logic;
    enable_push : IN std_logic;

    enable_1 : IN std_logic;
    enable_2 : IN std_logic;
    enable_3 : IN std_logic;
    enable_4 : IN std_logic;

    emitted_1 : OUT std_logic;
    emitted_2 : OUT std_logic;
    emitted_3 : OUT std_logic;
    emitted_4 : OUT std_logic;

    data_in_1 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_2 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_3 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_4 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END ManyToOneArch;

ARCHITECTURE arch OF ManyToOneArch IS
  TYPE states IS(idle, disabled, a, b, c, d);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL active : INTEGER RANGE 0 TO 4 := 0;
BEGIN
  -- clock trigger
  PROCESS (clock, enable_push)
  BEGIN
    IF (enable_push = '0') THEN
      present_state <= disabled;
      ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state, enable_1, enable_2, enable_3, enable_4)
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
        IF (enable_1 = '1') THEN
          next_state <= a;
        ELSIF (enable_2 = '1') THEN
          next_state <= b;
        ELSIF (enable_3 = '1') THEN
          next_state <= c;
        ELSIF (enable_4 = '1') THEN
          next_state <= d;
        ELSE
          next_state <= idle;
        END IF;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in_1, data_in_2, data_in_3, data_in_4)
  BEGIN
    push <= '1';
    emitted_1 <= '0';
    emitted_2 <= '0';
    emitted_3 <= '0';
    emitted_4 <= '0';
    data_out <= (OTHERS => '0');

    CASE present_state IS
      WHEN a =>
        data_out <= data_in_1;
        emitted_1 <= '1';

      WHEN b =>
        data_out <= data_in_2;
        emitted_2 <= '1';

      WHEN c =>
        data_out <= data_in_3;
        emitted_3 <= '1';

      WHEN d =>
        data_out <= data_in_4;
        emitted_4 <= '1';

      WHEN disabled =>
        push <= '0';

      WHEN idle =>
        push <= '0';
    END CASE;
  END PROCESS;
END arch;