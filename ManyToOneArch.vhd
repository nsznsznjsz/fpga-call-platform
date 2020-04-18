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

    push_1 : IN std_logic;
    push_2 : IN std_logic;
    push_3 : IN std_logic;
    push_4 : IN std_logic;

    pushed_1 : OUT std_logic;
    pushed_2 : OUT std_logic;
    pushed_3 : OUT std_logic;
    pushed_4 : OUT std_logic;

    data_in_1 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_2 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_3 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_4 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END ManyToOneArch;

ARCHITECTURE arch OF ManyToOneArch IS
  TYPE states IS(
  idle,
  a_init, a_wait, a_end,
  b_init, b_wait, b_end,
  c_init, c_wait, c_end,
  d_init, d_wait, d_end
  );
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
  PROCESS (present_state, push_1, push_2, push_3, push_4, pushed)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (push_1 = '1') THEN
          next_state <= a_init;
        ELSIF (push_2 = '1') THEN
          next_state <= b_init;
        ELSIF (push_3 = '1') THEN
          next_state <= c_init;
        ELSIF (push_4 = '1') THEN
          next_state <= d_init;
        ELSE
          next_state <= idle;
        END IF;

      WHEN a_init => next_state <= a_wait;
      WHEN b_init => next_state <= b_wait;
      WHEN c_init => next_state <= c_wait;
      WHEN d_init => next_state <= d_wait;

      WHEN a_wait => next_state <= ifElse(pushed, a_end, a_wait);
      WHEN b_wait => next_state <= ifElse(pushed, b_end, b_wait);
      WHEN c_wait => next_state <= ifElse(pushed, c_end, c_wait);
      WHEN d_wait => next_state <= ifElse(pushed, d_end, d_wait);

      WHEN a_end | b_end | c_end | d_end => next_state <= idle;

      WHEN OTHERS => next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data, data_in_1, data_in_2, data_in_3, data_in_4)
  BEGIN
    -- make latchs: data
    push <= '0';
    pushed_1 <= '0';
    pushed_2 <= '0';
    pushed_3 <= '0';
    pushed_4 <= '0';
    data_out <= (OTHERS => '0');

    CASE present_state IS
      WHEN a_init => data <= data_in_1;
      WHEN b_init => data <= data_in_2;
      WHEN c_init => data <= data_in_3;
      WHEN d_init => data <= data_in_4;

      WHEN a_wait | b_wait | c_wait | d_wait =>
        push <= '1';
        data_out <= data;

      WHEN a_end => pushed_1 <= '1';
      WHEN b_end => pushed_2 <= '1';
      WHEN c_end => pushed_3 <= '1';
      WHEN d_end => pushed_4 <= '1';

      WHEN idle => NULL;
    END CASE;
  END PROCESS;
END arch;