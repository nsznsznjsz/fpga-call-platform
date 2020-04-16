LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config.ALL;

-- 数据源 -> Waiting -> 发射器 -> 接收器
-- 不处理 队列为满 的错误, 交由发射器处理
ENTITY Waiting IS
  GENERIC (
    GROUP_FLAG : STD_LOGIC_VECTOR(FLAG_GROUP_WIDTH - 1 DOWNTO 0) := (OTHERS => '0')
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;
    button : IN std_logic; -- 用户取号

    pull : OUT std_logic; -- 申请取号
    enable_pull : IN std_logic; -- 允许取号

    push : OUT std_logic; -- 申请发送
    pushed : IN std_logic; -- 已发送

    data_in : IN std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END Waiting;

ARCHITECTURE arch OF Waiting IS
  TYPE states IS(idle, pulling, pushing);
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
  PROCESS (clock, reset)
  BEGIN
    IF (reset = '1') THEN
      present_state <= idle;
    ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state, button, enable_pull, pushed)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        next_state <= ifElse(button, pulling, idle);

      WHEN pulling =>
        next_state <= ifElse(enable_pull, pushing, pulling);

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
      FLAG_SCREEN_WAITING &
      FLAG_ERROR_UNKNOWN &
      GROUP_FLAG &
      DATA_DEFAULT;

    CASE present_state IS
      WHEN idle => NULL;

      WHEN pulling =>
        pull <= '1';
        data <=
          FLAG_SCREEN_WAITING &
          FLAG_ERROR_FREE &
          GROUP_FLAG &
          data_in;

      WHEN pushing =>
        push <= '1';
        data_out <= data;

      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;
END arch;