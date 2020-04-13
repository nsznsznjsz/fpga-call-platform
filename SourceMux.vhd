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

    empty : OUT std_logic; -- 所有数据源全空
    empty1 : IN std_logic; -- 数据源 data 1 为空
    empty2 : IN std_logic; -- 数据源 data 2 为空
    empty3 : IN std_logic; -- 数据源 data 3 为空
    empty4 : IN std_logic; -- 数据源 data 4 为空

    pull : IN std_logic; -- 下游请求拉数据
    pull1 : OUT std_logic; -- 请求从 data in 1 拉数据
    pull2 : OUT std_logic; -- 请求从 data in 2 拉数据
    pull3 : OUT std_logic; -- 请求从 data in 3 拉数据
    pull4 : OUT std_logic; -- 请求从 data in 4 拉数据

    enable_pull : OUT std_logic; -- 允许从 data out 拉数据
    enable_pull1 : IN std_logic; -- 允许从 data in 1 拉数据
    enable_pull2 : IN std_logic; -- 允许从 data in 2 拉数据
    enable_pull3 : IN std_logic; -- 允许从 data in 3 拉数据
    enable_pull4 : IN std_logic; -- 允许从 data in 4 拉数据

    data_in1 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in2 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in3 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in4 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END SourceMux;

-- TODO BUG: 在同一 clock 将取走
ARCHITECTURE arch OF SourceMux IS
  TYPE states IS(idle, a_init, a_wait, a_end, b_init, b_wait, b_end, c_init, c_wait, c_end, d_init, d_wait, d_end);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL active : INTEGER RANGE 0 TO 4 := 0;
  SIGNAL empty_i : std_logic;

  SIGNAL data1 : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data2 : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data3 : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data4 : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

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
    empty1 = '1' AND
    empty2 = '1' AND
    empty3 = '1' AND
    empty4 = '1'
    ) ELSE
    '0';

  -- Copy input to internal signals
  PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      copyOrNot(enable_pull1, data1, data_in1);
      copyOrNot(enable_pull2, data2, data_in2);
      copyOrNot(enable_pull3, data3, data_in3);
      copyOrNot(enable_pull4, data4, data_in4);
    END IF;
  END PROCESS;

  -- clock trigger
  PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (
    present_state, pull,
    enable_pull1, enable_pull2, enable_pull3, enable_pull4,
    empty_i, empty1, empty2, empty3, empty4
    )
  BEGIN
    CASE present_state IS
      WHEN idle =>
        next_state <= idle;
        IF (pull = '1' AND empty_i = '0') THEN
          IF (empty1 = '0') THEN
            next_state <= a_init;
          ELSIF (empty2 = '0') THEN
            next_state <= b_init;
          ELSIF (empty3 = '0') THEN
            next_state <= c_init;
          ELSIF (empty4 = '0') THEN
            next_state <= d_init;
          END IF;
        END IF;

      WHEN a_init =>
        waitOrNext(next_state, enable_pull1, a_wait, a_end);

      WHEN a_wait =>
        waitOrNext(next_state, enable_pull1, a_wait, a_end);

      WHEN a_end =>
        next_state <= idle;

      WHEN b_init =>
        waitOrNext(next_state, enable_pull2, b_wait, b_end);

      WHEN b_wait =>
        waitOrNext(next_state, enable_pull2, b_wait, b_end);

      WHEN b_end =>
        next_state <= idle;

      WHEN c_init =>
        waitOrNext(next_state, enable_pull3, c_wait, c_end);

      WHEN c_wait =>
        waitOrNext(next_state, enable_pull3, c_wait, c_end);

      WHEN c_end =>
        next_state <= idle;

      WHEN d_init =>
        waitOrNext(next_state, enable_pull4, d_wait, d_end);

      WHEN d_wait =>
        waitOrNext(next_state, enable_pull4, d_wait, d_end);

      WHEN d_end =>
        next_state <= idle;

      WHEN OTHERS =>
        next_state <= idle;

    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data1, data2, data3, data4)
  BEGIN
    enable_pull <= '0';
    pull1 <= '0';
    pull2 <= '0';
    pull3 <= '0';
    pull4 <= '0';
    data_out <= (OTHERS => '0');

    CASE present_state IS
      WHEN a_init =>
        pull1 <= '1';

      WHEN a_wait =>
        NULL;

      WHEN a_end =>
        enable_pull <= '1';
        data_out <= data1;

      WHEN b_init =>
        pull2 <= '1';

      WHEN b_wait =>
        NULL;

      WHEN b_end =>
        enable_pull <= '1';
        data_out <= data2;

      WHEN c_init =>
        pull3 <= '1';

      WHEN c_wait =>
        NULL;

      WHEN c_end =>
        enable_pull <= '1';
        data_out <= data3;

      WHEN d_init =>
        pull4 <= '1';

      WHEN d_wait =>
        NULL;

      WHEN d_end =>
        enable_pull <= '1';
        data_out <= data4;

      WHEN idle =>
        NULL;

    END CASE;
  END PROCESS;
END arch;