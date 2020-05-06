LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config.ALL;

-- 数据源 -> 取号 -> 发射 -> 接收器
ENTITY Service IS
  GENERIC (
    RETRY : BOOLEAN := true
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
  TYPE states IS(idle, init, queue_empty, pulling, judge, pushing);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data_next : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  CONSTANT DATA_DEFAULT : std_logic_vector(DATA_HIGH DOWNTO DATA_LOW) := (OTHERS => '0');

  FUNCTION neeeRetry(
    data : std_logic_vector
  ) RETURN std_logic IS
  BEGIN
    IF (RETRY = true AND data(FLAG_ERROR_HIGH DOWNTO FLAG_ERROR_LOW) = FLAG_ERROR_QUEUE_RETRY) THEN
      RETURN '1';
    ELSE
      RETURN '0';
    END IF;
  END FUNCTION;

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
      data <= (OTHERS => '0');
    ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;
      data <= data_next;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (ALL)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (call = '1') THEN
          next_state <= init;
        ELSIF (recall = '1') THEN
          next_state <= pushing;
        ELSE
          next_state <= idle;
        END IF;

      WHEN init =>
        next_state <= ifElse(empty, queue_empty, pulling);

      WHEN queue_empty =>
        next_state <= pushing;

      WHEN pulling =>
        next_state <= ifElse(enable_pull, judge, pulling);

      WHEN judge =>
        next_state <= ifElse(neeeRetry(data), init, pushing);

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
    data_next <= data;
    data_out <=
      FLAG_SCREEN_SERVICE & -- screen: service
      FLAG_ERROR_UNKNOWN & -- error: unknown
      FLAG_GROUP_FREE & -- group: non
      DATA_DEFAULT; -- data: zero

    CASE present_state IS
      WHEN pulling =>
        pull <= '1';
        data_next <=
          FLAG_SCREEN_SERVICE & -- screen: service
          data_in(FLAG_ERROR_HIGH DOWNTO FLAG_ERROR_LOW) & -- error: copy
          data_in(FLAG_GROUP_HIGH DOWNTO FLAG_GROUP_LOW) & -- group: copy
          data_in(DATA_HIGH DOWNTO DATA_LOW); -- data: copy

      WHEN queue_empty =>
        data_next <=
          FLAG_SCREEN_SERVICE & -- screen: service
          FLAG_ERROR_QUEUE_EMPTY & -- error: empty
          FLAG_GROUP_FREE & -- group: non
          DATA_DEFAULT; -- data: zero

      WHEN pushing =>
        push <= '1';
        data_out <= data;

      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;
END arch;