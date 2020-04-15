LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config.ALL;

-- 数据源 -> 取号 -> 发射 -> 接收器
ENTITY Service IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;
    call : IN std_logic; -- 叫号
    recall : IN std_logic; -- 重新叫号

    pull : OUT std_logic; -- 申请取号
    empty : IN std_logic; -- 队列为空
    enable_pull : IN std_logic; -- 允许取号

    push : OUT std_logic; -- 申请发送
    pushed : IN std_logic; -- 已发送

    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END Service;

ARCHITECTURE arch OF Service IS
  TYPE states IS(idle, pulling, pulled, queue_empty, pushing);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  CONSTANT DATA_DEFAULT : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

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
  PROCESS (clock)
  BEGIN
    IF (reset = '1') THEN
      present_state <= idle;
    ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state, call, recall, enable_pull, pushed)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (call = '1') THEN
          next_state <= pulling;
        ELSIF (recall = '1') THEN
          next_state <= pushing;
        ELSE
          next_state <= idle;
        END IF;

      WHEN pulling =>
        next_state <= ifElse(enable_pull, pulled, pulling);

      WHEN pulled =>
        next_state <= ifElse(empty, queue_empty, pushing);

      WHEN queue_empty =>
        next_state <= pushing;

      WHEN pushing =>
        next_state <= ifElse(pushed, idle, pushing);

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in, data)
  BEGIN
    -- make latches: data
    push <= '0';
    pull <= '0';
    data_out <=
      FLAG_SCREEN_SERVICE &
      FLAG_GROUP_FREE &
      FLAG_ERROR_UNKNOWN &
      DATA_DEFAULT;

    CASE present_state IS
      WHEN idle => NULL;

      WHEN pulling =>
        pull <= '1';
        data <=
          FLAG_SCREEN_SERVICE &
          data_in(FLAG_SCREEN_LOW - 1 DOWNTO 0);

      WHEN pulled =>
        pull <= '0';

      WHEN queue_empty =>
        push <= '1';
        data <=
          FLAG_SCREEN_SERVICE &
          data(FLAG_GROUP_HIGH DOWNTO FLAG_GROUP_LOW) &
          FLAG_ERROR_QUEUE_EMPTY &
          data(DATA_WIDTH - 1 DOWNTO 0);

      WHEN pushing =>
        push <= '1';
        data_out <= data;

      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;
END arch;