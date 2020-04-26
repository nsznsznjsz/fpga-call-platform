LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.config.ALL;

ENTITY VipMixer IS
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;

    -- left
    pull_in_a : OUT std_logic;
    pull_in_b : OUT std_logic;
    pull_in_vip : OUT std_logic;

    enable_in_a : IN std_logic;
    enable_in_b : IN std_logic;
    enable_in_vip : IN std_logic;

    data_in_a : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_b : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_in_vip : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

    -- right
    pull_out_a : IN std_logic;
    pull_out_b : IN std_logic;
    pull_out_vip : IN std_logic;

    enable_out_a : OUT std_logic;
    enable_out_b : OUT std_logic;
    enable_out_vip : OUT std_logic;

    data_out_a : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out_b : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out_vip : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END VipMixer;

ARCHITECTURE arch OF VipMixer IS
  TYPE states IS(
  resetting, idle,
  a_pull, a_pulling, a_pushing,
  b_pull, b_pulling, b_pushing,
  vip_pull, vip_pulling, vip_judge, vip_pushing
  );
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL max_a : INTEGER;
  SIGNAL max_b : INTEGER;
  SIGNAL max_a_next : INTEGER;
  SIGNAL max_b_next : INTEGER;

  SIGNAL data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data_next : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

  FUNCTION sliceInt(
    data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  ) RETURN INTEGER IS
  BEGIN
    RETURN to_integer(unsigned(data(DATA_WIDTH - 1 DOWNTO 0)));
  END FUNCTION;

  FUNCTION needRedo(
    data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    max_a : INTEGER;
    max_b : INTEGER
  ) RETURN std_logic IS
    VARIABLE cur : INTEGER;
    VARIABLE max : INTEGER;
  BEGIN
    cur := sliceInt(data);

    CASE(data(FLAG_GROUP_HIGH DOWNTO FLAG_GROUP_LOW))IS
      WHEN FLAG_GROUP_A | FLAG_GROUP_VIPA => max := max_a;
      WHEN FLAG_GROUP_B | FLAG_GROUP_VIPB => max := max_b;
      WHEN OTHERS => max := 0;
    END CASE;

    IF (cur <= max) THEN
      RETURN '1';
    ELSE
      RETURN '0';
    END IF;
  END FUNCTION;

  PROCEDURE recordMax(
    SIGNAL data : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    SIGNAL max_a : OUT INTEGER;
    SIGNAL max_b : OUT INTEGER
  )IS
    VARIABLE cur : INTEGER;
  BEGIN
    cur := sliceInt(data);

    CASE(data(FLAG_GROUP_HIGH DOWNTO FLAG_GROUP_LOW))IS
      WHEN FLAG_GROUP_A | FLAG_GROUP_VIPA => max_a <= cur;
      WHEN FLAG_GROUP_B | FLAG_GROUP_VIPB => max_b <= cur;
      WHEN OTHERS => NULL;
    END CASE;
  END PROCEDURE;

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

      -- slove latchs
      max_a <= 0;
      max_b <= 0;
      data <= (OTHERS => '0');
    ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;

      -- slove latchs
      max_a <= max_a_next;
      max_b <= max_b_next;
      data <= data_next;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (ALL)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (pull_out_a = '1') THEN
          next_state <= a_pull;
        ELSIF (pull_out_b = '1') THEN
          next_state <= b_pull;
        ELSIF (pull_out_vip = '1') THEN
          next_state <= vip_pull;
        ELSE
          next_state <= idle;
        END IF;

      WHEN a_pull | a_pulling => next_state <= ifElse(enable_in_a, a_pushing, a_pulling);
      WHEN b_pull | b_pulling => next_state <= ifElse(enable_in_b, b_pushing, b_pulling);

      WHEN vip_pull | vip_pulling => next_state <= ifElse(enable_in_vip, vip_judge, vip_pulling);
      WHEN vip_judge => next_state <= ifElse(needRedo(data, max_a, max_b), vip_pull, vip_pushing);

      WHEN a_pushing | b_pushing | vip_pushing => next_state <= idle;

      WHEN OTHERS => next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (ALL)
  BEGIN
    pull_in_a <= '0';
    pull_in_b <= '0';
    pull_in_vip <= '0';

    enable_out_a <= '0';
    enable_out_b <= '0';
    enable_out_vip <= '0';

    data_out_a <= (OTHERS => '0');
    data_out_b <= (OTHERS => '0');
    data_out_vip <= (OTHERS => '0');

    -- slove latchs
    max_a_next <= max_a;
    max_b_next <= max_b;
    data_next <= data;

    CASE present_state IS
      WHEN a_pull => pull_in_a <= '1';
      WHEN a_pulling => data_next <= data_in_a;

      WHEN b_pull => pull_in_b <= '1';
      WHEN b_pulling => data_next <= data_in_b;

      WHEN vip_pull => pull_in_vip <= '1';
      WHEN vip_pulling => data_next <= data_in_vip;
      WHEN vip_judge => NULL;

      WHEN a_pushing =>
        recordMax(data, max_a_next, max_b_next);
        data_out_a <= data;
        enable_out_a <= '1';

      WHEN b_pushing =>
        recordMax(data, max_a_next, max_b_next);
        data_out_b <= data;
        enable_out_b <= '1';

      WHEN vip_pushing =>
        recordMax(data, max_a_next, max_b_next);
        data_out_vip <= data;
        enable_out_vip <= '1';

      WHEN idle =>
        data_next <= (OTHERS => '0');

      WHEN OTHERS => NULL;
    END CASE;

  END PROCESS;
END arch;