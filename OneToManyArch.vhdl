LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY OneToManyArch IS
  GENERIC (
    RAM_WIDTH : NATURAL := 8
  );
  PORT (
    clock : IN std_logic;

    pull : OUT std_logic;
    enable_pull : IN std_logic;

    input1 : IN std_logic;
    input2 : IN std_logic;
    input3 : IN std_logic;
    input4 : IN std_logic;

    enable1 : OUT std_logic;
    enable2 : OUT std_logic;
    enable3 : OUT std_logic;
    enable4 : OUT std_logic;

    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END OneToManyArch;

ARCHITECTURE arch OF OneToManyArch IS
  TYPE states IS(idle, a_init, a_wait, a_end, b_init, b_wait, b_end, c_init, c_wait, c_end, d_init, d_wait, d_end);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL active : INTEGER RANGE 0 TO 4 := 0;
  SIGNAL data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

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
  -- wait enable
  PROCESS (enable_pull, data_in)
  BEGIN
    IF rising_edge(enable_pull) THEN
      data <= data_in;
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
  PROCESS (present_state, enable_pull, input1, input2, input3, input4)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (input1 = '1') THEN
          next_state <= a_init;
        ELSIF (input2 = '1') THEN
          next_state <= b_init;
        ELSIF (input3 = '1') THEN
          next_state <= c_init;
        ELSIF (input4 = '1') THEN
          next_state <= d_init;
        ELSE
          next_state <= idle;
        END IF;

      WHEN a_init =>
        waitOrNext(next_state, enable_pull, a_wait, a_end);

      WHEN a_wait =>
        waitOrNext(next_state, enable_pull, a_wait, a_end);

      WHEN a_end =>
        next_state <= idle;

      WHEN b_init =>
        waitOrNext(next_state, enable_pull, b_wait, b_end);

      WHEN b_wait =>
        waitOrNext(next_state, enable_pull, b_wait, b_end);

      WHEN b_end =>
        next_state <= idle;

      WHEN c_init =>
        waitOrNext(next_state, enable_pull, c_wait, c_end);

      WHEN c_wait =>
        waitOrNext(next_state, enable_pull, c_wait, c_end);

      WHEN c_end =>
        next_state <= idle;

      WHEN d_init =>
        waitOrNext(next_state, enable_pull, d_wait, d_end);

      WHEN d_wait =>
        waitOrNext(next_state, enable_pull, d_wait, d_end);

      WHEN d_end =>
        next_state <= idle;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data)
  BEGIN
    pull <= '0';
    enable1 <= '0';
    enable2 <= '0';
    enable3 <= '0';
    enable4 <= '0';
    data <= data;
    data_out <= (OTHERS => '0');

    CASE present_state IS
      WHEN a_init =>
        pull <= '1';

      WHEN a_wait =>
        NULL;

      WHEN a_end =>
        enable1 <= '1';
        data_out <= data;

      WHEN b_init =>
        pull <= '1';

      WHEN b_wait =>
        NULL;

      WHEN b_end =>
        enable2 <= '1';
        data_out <= data;

      WHEN c_init =>
        pull <= '1';

      WHEN c_wait =>
        NULL;

      WHEN c_end =>
        enable3 <= '1';
        data_out <= data;

      WHEN d_init =>
        pull <= '1';

      WHEN d_wait =>
        NULL;

      WHEN d_end =>
        enable4 <= '1';
        data_out <= data;

      WHEN idle =>
        NULL;

    END CASE;
  END PROCESS;
END arch;