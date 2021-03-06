LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config.ALL;
USE work.ascii.ALL;

ENTITY Screen IS
  GENERIC (
    BLINK : NATURAL := 3;
    CLK_DIV : NATURAL := 1
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;
    enable : IN std_logic;

    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(WORD_WIDTH - 1 DOWNTO 0);

    -- queue
    empty : IN std_logic;
    pull : OUT std_logic;
    enable_pull : IN std_logic
  );
END Screen;

ARCHITECTURE arch OF Screen IS
  COMPONENT Decoder IS
    PORT (
      data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
      data_out : OUT std_logic_vector(WORD_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT FD IS
    GENERIC (
      N : NATURAL := 5
    );
    PORT (
      clock : IN std_logic;
      reset : IN std_logic;
      clock_div : OUT std_logic
    );
  END COMPONENT;

  COMPONENT ScreenScroller IS
    PORT (
      clock : IN std_logic;
      reset : IN std_logic;
      data_out : OUT std_logic_vector(WORD_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT ScreenBlinker IS
    GENERIC (
      BLINK : NATURAL := 3
    );
    PORT (
      clock : IN std_logic;
      reset : IN std_logic;

      start : IN std_logic;
      finished : OUT std_logic;

      data_in : IN std_logic_vector(WORD_WIDTH - 1 DOWNTO 0);
      data_out : OUT std_logic_vector(WORD_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  TYPE states IS(disenable, idle, pulling, on_blink);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL origin : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL data : std_logic_vector(WORD_WIDTH - 1 DOWNTO 0);
  SIGNAL data_next : std_logic_vector(WORD_WIDTH - 1 DOWNTO 0);

  -- sub components
  SIGNAL clock_div : std_logic;

  -- scroller
  SIGNAL scroll_out : std_logic_vector(WORD_WIDTH - 1 DOWNTO 0);

  -- blinker
  SIGNAL blink_start : std_logic;
  SIGNAL blink_finished : std_logic;
  SIGNAL blink_out : std_logic_vector(WORD_WIDTH - 1 DOWNTO 0);

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

  decode : Decoder
  PORT MAP(
    data_in => origin,
    data_out => data_next
  );

  div_clock : FD
  GENERIC MAP(
    N => CLK_DIV
  )
  PORT MAP(
    clock => clock,
    reset => reset,
    clock_div => clock_div
  );

  scroller : ScreenScroller
  PORT MAP(
    clock => clock_div,
    reset => reset,
    data_out => scroll_out
  );

  blinker : ScreenBlinker
  GENERIC MAP(
    BLINK => BLINK
  )
  PORT MAP(
    clock => clock_div,
    reset => reset,

    start => blink_start,
    finished => blink_finished,

    data_in => data,
    data_out => blink_out
  );

  -- clock trigger
  PROCESS (clock, reset, scroll_out)
  BEGIN
    IF (enable = '0') THEN
      data <= scroll_out;
      present_state <= disenable;
    ELSIF (reset = '1') THEN
      data <= (OTHERS => '0');
      present_state <= idle;
    ELSIF (clock'event AND clock = '1') THEN
      data <= data_next;
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (ALL)
  BEGIN
    CASE present_state IS
      WHEN disenable =>
        next_state <= ifElse(enable, idle, disenable);

      WHEN idle =>
        next_state <= ifElse(empty, idle, pulling);

      WHEN pulling =>
        next_state <= ifElse(enable_pull, on_blink, pulling);

      WHEN on_blink =>
        next_state <= ifElse(blink_finished, idle, on_blink);

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in, data, scroll_out, blink_out)
  BEGIN
    pull <= '0';
    data_out <= data;
    blink_start <= '0';

    CASE present_state IS
      WHEN disenable =>
        data_out <= scroll_out;

      WHEN pulling =>
        pull <= '1';
        origin <= data_in;

      WHEN on_blink =>
        blink_start <= '1';
        data_out <= blink_out;

      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;

END arch;