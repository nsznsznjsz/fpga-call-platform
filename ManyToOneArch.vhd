LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- 多个数据依次进入一个队列, 1 > 2 > 3 > 4
ENTITY ManyToOneArch IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;

    push : OUT std_logic;
    pushed : IN std_logic;

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
  TYPE states IS(idle, a, b, c, d, pushing);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

  -- jump next state
  FUNCTION ifElse(
    condition : std_logic;
    onTrue : states;
    onFalse : states
  ) RETURN states IS
  BEGIN
    IF (condition = '1') THEN
      RETURN onTrue;
    ELSE
      RETURN onFalse;
    END IF;
  END FUNCTION;
BEGIN
  -- clock trigger
  PROCESS (clock, reset)
  BEGIN
    IF (reset = '1') THEN
      present_state <= idle;
    ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state, enable_1, enable_2, enable_3, enable_4, pushed)
  BEGIN
    CASE present_state IS
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

      WHEN a | b | c | d =>
        next_state <= pushing;

      WHEN pushing =>
        next_state <= ifElse(pushed, idle, pushing);

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data, data_in_1, data_in_2, data_in_3, data_in_4)
  BEGIN
    -- make latchs: data
    push <= '0';
    emitted_1 <= '0';
    emitted_2 <= '0';
    emitted_3 <= '0';
    emitted_4 <= '0';
    data_out <= (OTHERS => '0');

    CASE present_state IS
      WHEN a =>
        emitted_1 <= '1';
        data <= data_in_1;

      WHEN b =>
        emitted_2 <= '1';
        data <= data_in_2;

      WHEN c =>
        emitted_3 <= '1';
        data <= data_in_3;

      WHEN d =>
        emitted_4 <= '1';
        data <= data_in_4;

      WHEN pushing =>
        push <= '1';
        data_out <= data;

      WHEN idle => NULL;
    END CASE;
  END PROCESS;
END arch;