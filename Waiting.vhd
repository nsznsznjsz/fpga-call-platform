LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- 数据源 -> 取号 -> 发射 -> 接收器
ENTITY Waiting IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16;
    FLAGS : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0') -- flag width
  );
  PORT (
    clock : IN std_logic;
    button : IN std_logic; -- 用户取号

    pull : OUT std_logic; -- 申请取号
    enable_pull : IN std_logic; -- 允许取号

    push : OUT std_logic; -- 申请发送
    pushed : IN std_logic; -- 已发送

    data_in : IN std_logic_vector(RAM_WIDTH - 9 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END Waiting;

ARCHITECTURE arch OF Waiting IS
  TYPE states IS(idle, pulling, pulled, pushing, success);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(RAM_WIDTH - 9 DOWNTO 0);

  -- jump next state
  PROCEDURE waitOrNext(
    SIGNAL next_state : OUT states;
    SIGNAL enable : IN std_logic;
    CONSTANT s_wait : IN states;
    CONSTANT s_next : IN states
  ) IS
  BEGIN
    IF (enable = '1') THEN
      next_state <= s_next;
      ELSE
      next_state <= s_wait;
    END IF;
  END PROCEDURE;
BEGIN
  -- clock trigger
  PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state, button, enable_pull, pushed)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        waitOrNext(next_state, button, idle, pulling);

      WHEN pulling =>
        waitOrNext(next_state, enable_pull, pulling, pulled);

      WHEN pulled =>
        next_state <= pushing;

      WHEN pushing =>
        waitOrNext(next_state, pushed, pushing, success);

      WHEN success =>
        next_state <= idle;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in, data)
  BEGIN
    -- make latches: data, data_out
    push <= '0';
    pull <= '0';

    CASE present_state IS
      WHEN idle => NULL;

      WHEN pulling =>
        pull <= '1';
        data <= data_in;

      WHEN pulled =>
        pull <= '0';

      WHEN pushing =>
        push <= '1';
        data_out <= FLAGS & data;

      WHEN success =>
        push <= '0';

      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;
END arch;