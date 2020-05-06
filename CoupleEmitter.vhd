LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config.ALL;

ENTITY CoupleEmitter IS
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;

    -- left
    push : IN std_logic;
    pushed : OUT std_logic;
    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

    -- right
    push_1 : OUT std_logic;
    pushed_1 : IN std_logic;
    push_2 : OUT std_logic;
    pushed_2 : IN std_logic;
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END CoupleEmitter;

ARCHITECTURE arch OF CoupleEmitter IS
  TYPE states IS(idle, wait_both, wait_1, wait_2, success);
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
  PROCESS (present_state, push, pushed_1, pushed_2)
  BEGIN
    CASE present_state IS
      WHEN idle => next_state <= ifElse(push, wait_both, idle);

      WHEN wait_both =>
        IF (pushed_1 = '1' AND pushed_2 = '1') THEN
          next_state <= success;
        ELSIF (pushed_1 = '1' AND pushed_2 = '0') THEN
          next_state <= wait_2;
        ELSIF (pushed_1 = '0' AND pushed_2 = '1') THEN
          next_state <= wait_1;
        ELSE
          next_state <= wait_both;
        END IF;

      WHEN wait_1 => next_state <= ifElse(pushed_1, success, wait_1);
      WHEN wait_2 => next_state <= ifElse(pushed_2, success, wait_2);
      WHEN success => next_state <= idle;
      WHEN OTHERS => next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in, data)
  BEGIN
    -- make latchs: data
    push_1 <= '0';
    push_2 <= '0';
    pushed <= '0';
    data_out <= (OTHERS => '0');

    CASE present_state IS
      WHEN idle =>
        data <= data_in;

      WHEN wait_both =>
        push_1 <= '1';
        push_2 <= '1';
        data_out <= data;

      WHEN wait_1 =>
        push_1 <= '1';
        data_out <= data;

      WHEN wait_2 =>
        push_2 <= '1';
        data_out <= data;

      WHEN success =>
        pushed <= '1';
        data <= (OTHERS => '0');

      WHEN OTHERS => next_state <= idle;
    END CASE;

  END PROCESS;
END arch;