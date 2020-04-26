LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config.ALL;

-- ����Դ -> ȡ�� -> ���� -> ������
ENTITY Service IS
  GENERIC (
    RETRY : BOOLEAN := true
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;
    call : IN std_logic; -- �к�
    recall : IN std_logic; -- ���½к�

    pull : OUT std_logic; -- ����ȡ��
    empty : IN std_logic; -- ����Ϊ��
    enable_pull : IN std_logic; -- ����ȡ��

    push : OUT std_logic; -- ���뷢��
    pushed : IN std_logic; -- �ѷ���

    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END Service;

ARCHITECTURE arch OF Service IS
  TYPE states IS(idle, init, queue_empty, pulling, judge, pushing);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  CONSTANT DATA_DEFAULT : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

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
    ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;
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
    data_out <=
      FLAG_SCREEN_SERVICE &
      FLAG_ERROR_UNKNOWN &
      FLAG_GROUP_FREE &
      DATA_DEFAULT;

    CASE present_state IS
      WHEN pulling =>
        pull <= '1';
        data <=
          FLAG_SCREEN_SERVICE &
          data_in(FLAG_SCREEN_LOW - 1 DOWNTO 0);

      WHEN queue_empty =>
        data <=
          FLAG_SCREEN_SERVICE &
          FLAG_ERROR_QUEUE_EMPTY &
          data(FLAG_GROUP_HIGH DOWNTO 0);

      WHEN pushing =>
        push <= '1';
        data_out <= data;

      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;
END arch;