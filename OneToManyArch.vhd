LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY OneToManyArch IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;

    pull : OUT std_logic;
    enable_pull : IN std_logic;

    input_1 : IN std_logic;
    input_2 : IN std_logic;
    input_3 : IN std_logic;
    input_4 : IN std_logic;

    enable_1 : OUT std_logic;
    enable_2 : OUT std_logic;
    enable_3 : OUT std_logic;
    enable_4 : OUT std_logic;

    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END OneToManyArch;

ARCHITECTURE arch OF OneToManyArch IS
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

  -- Copy input to internal signals
  PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      IF (enable_pull = '1') THEN
        data <= data_in;
      END IF;
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
  PROCESS (present_state, enable_pull, input_1, input_2, input_3, input_4)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (input_1 = '1') THEN
          next_state <= a_init;
        ELSIF (input_2 = '1') THEN
          next_state <= b_init;
        ELSIF (input_3 = '1') THEN
          next_state <= c_init;
        ELSIF (input_4 = '1') THEN
          next_state <= d_init;
        ELSE
          next_state <= idle;
        END IF;

      WHEN a_init | a_wait => next_state <= ifElse(enable_pull, a_end, a_wait);
      WHEN b_init | b_wait => next_state <= ifElse(enable_pull, b_end, b_wait);
      WHEN c_init | c_wait => next_state <= ifElse(enable_pull, c_end, c_wait);
      WHEN d_init | d_wait => next_state <= ifElse(enable_pull, d_end, d_wait);

      WHEN a_end | b_end | c_end | d_end => next_state <= idle;

      WHEN OTHERS => next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data)
  BEGIN
    pull <= '0';
    enable_1 <= '0';
    enable_2 <= '0';
    enable_3 <= '0';
    enable_4 <= '0';
    data_out <= (OTHERS => '0');

    CASE present_state IS
      WHEN a_init | b_init | c_init | d_init => pull <= '1';
      WHEN a_wait | b_wait | c_wait | d_wait => NULL;

      WHEN a_end =>
        enable_1 <= '1';
        data_out <= data;

      WHEN b_end =>
        enable_2 <= '1';
        data_out <= data;

      WHEN c_end =>
        enable_3 <= '1';
        data_out <= data;

      WHEN d_end =>
        enable_4 <= '1';
        data_out <= data;

      WHEN idle => NULL;
    END CASE;
  END PROCESS;
END arch;