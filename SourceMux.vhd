LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config.ALL;

ENTITY SourceMux IS
  -- GENERIC (
  --   RAM_WIDTH : NATURAL := 16
  -- );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;

    empty : OUT std_logic; -- 所有数据源全空
    empty_1 : IN std_logic; -- 数据源 data 1 为空
    empty_2 : IN std_logic; -- 数据源 data 2 为空
    empty_3 : IN std_logic; -- 数据源 data 3 为空
    empty_4 : IN std_logic; -- 数据源 data 4 为空

    pull : IN std_logic; -- 下游请求拉数据
    pull_1 : OUT std_logic; -- 请求从 data in 1 拉数据
    pull_2 : OUT std_logic; -- 请求从 data in 2 拉数据
    pull_3 : OUT std_logic; -- 请求从 data in 3 拉数据
    pull_4 : OUT std_logic; -- 请求从 data in 4 拉数据

    enable_pull : OUT std_logic; -- 允许从 data out 拉数据
    enable_pull_1 : IN std_logic; -- 允许从 data in 1 拉数据
    enable_pull_2 : IN std_logic; -- 允许从 data in 2 拉数据
    enable_pull_3 : IN std_logic; -- 允许从 data in 3 拉数据
    enable_pull_4 : IN std_logic; -- 允许从 data in 4 拉数据

    data_in_1 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_2 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_3 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_4 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END SourceMux;

-- TODO BUG: 在同一 clock 将取走
ARCHITECTURE arch OF SourceMux IS
  TYPE states IS(
  idle,
  a_init, a_wait, a_end,
  b_init, b_wait, b_end,
  c_init, c_wait, c_end,
  d_init, d_wait, d_end
  );
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL active : INTEGER RANGE 0 TO 4 := 0;
  SIGNAL empty_i : std_logic;

  SIGNAL data_1 : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data_2 : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data_3 : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data_4 : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

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

  -- copy data_in to data if enable
  PROCEDURE copyOrNot(
    SIGNAL enable : IN std_logic;
    SIGNAL data : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    SIGNAL data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  ) IS
  BEGIN
    IF (enable = '1') THEN
      data <= data_in;
    END IF;
  END PROCEDURE;

BEGIN
  -- Copy internal signals to output
  empty <= empty_i;

  -- Set the flags
  empty_i <= '1' WHEN (
    empty_1 = '1' AND
    empty_2 = '1' AND
    empty_3 = '1' AND
    empty_4 = '1'
    ) ELSE
    '0';

  -- Copy input to internal signals
  PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      copyOrNot(enable_pull_1, data_1, data_in_1);
      copyOrNot(enable_pull_2, data_2, data_in_2);
      copyOrNot(enable_pull_3, data_3, data_in_3);
      copyOrNot(enable_pull_4, data_4, data_in_4);
    END IF;
  END PROCESS;

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
  PROCESS (
    present_state, pull,
    enable_pull_1, enable_pull_2, enable_pull_3, enable_pull_4,
    empty_i, empty_1, empty_2, empty_3, empty_4
    )
  BEGIN
    CASE present_state IS
      WHEN idle =>
        next_state <= idle;
        IF (pull = '1' AND empty_i = '0') THEN
          IF (empty_1 = '0') THEN
            next_state <= a_init;
          ELSIF (empty_2 = '0') THEN
            next_state <= b_init;
          ELSIF (empty_3 = '0') THEN
            next_state <= c_init;
          ELSIF (empty_4 = '0') THEN
            next_state <= d_init;
          END IF;
        END IF;

      WHEN a_init =>
        next_state <= ifElse(enable_pull_1, a_end, a_wait);

      WHEN a_wait =>
        next_state <= ifElse(enable_pull_1, a_end, a_wait);

      WHEN a_end =>
        next_state <= idle;

      WHEN b_init =>
        next_state <= ifElse(enable_pull_2, b_end, b_wait);

      WHEN b_wait =>
        next_state <= ifElse(enable_pull_2, b_end, b_wait);

      WHEN b_end =>
        next_state <= idle;

      WHEN c_init =>
        next_state <= ifElse(enable_pull_3, c_end, c_wait);

      WHEN c_wait =>
        next_state <= ifElse(enable_pull_3, c_end, c_wait);

      WHEN c_end =>
        next_state <= idle;

      WHEN d_init =>
        next_state <= ifElse(enable_pull_4, d_end, d_wait);

      WHEN d_wait =>
        next_state <= ifElse(enable_pull_4, d_end, d_wait);

      WHEN d_end =>
        next_state <= idle;

      WHEN OTHERS =>
        next_state <= idle;

    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_1, data_2, data_3, data_4)
  BEGIN
    enable_pull <= '0';
    pull_1 <= '0';
    pull_2 <= '0';
    pull_3 <= '0';
    pull_4 <= '0';
    data_out <= (OTHERS => '0');

    CASE present_state IS
      WHEN a_init =>
        pull_1 <= '1';

      WHEN a_wait => NULL;

      WHEN a_end =>
        enable_pull <= '1';
        data_out <= data_1;

      WHEN b_init =>
        pull_2 <= '1';

      WHEN b_wait => NULL;

      WHEN b_end =>
        enable_pull <= '1';
        data_out <= data_2;

      WHEN c_init =>
        pull_3 <= '1';

      WHEN c_wait => NULL;

      WHEN c_end =>
        enable_pull <= '1';
        data_out <= data_3;

      WHEN d_init =>
        pull_4 <= '1';

      WHEN d_wait => NULL;

      WHEN d_end =>
        enable_pull <= '1';
        data_out <= data_4;

      WHEN idle => NULL;

    END CASE;
  END PROCESS;
END arch;