LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

LIBRARY work;
USE work.config.ALL;
USE work.ascii.ALL;

ENTITY ScreenBlinker IS
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
END ScreenBlinker;

ARCHITECTURE arch OF ScreenBlinker IS
  TYPE states IS(idle, blink_on, blink_off, blink_end);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL blink_counter : INTEGER RANGE 0 TO 2 * BLINK - 1;
  SIGNAL DATA_DEFAULT : std_logic_vector(WORD_WIDTH - 1 DOWNTO 0) := X & X & X & X & X;

  -- Increment and wrap
  PROCEDURE incr(SIGNAL index : INOUT INTEGER) IS
  BEGIN
    IF (index = 2 * BLINK - 1) THEN
      index <= 0;
    ELSE
      index <= index + 1;
    END IF;
  END PROCEDURE;
BEGIN

  -- counter
  PROCESS (clock, reset)
  BEGIN
    IF (reset = '1' OR present_state = idle) THEN
      blink_counter <= 0;
    ELSIF (clock'event AND clock = '1') THEN
      incr(blink_counter);
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
  PROCESS (ALL)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (start = '1') THEN
          next_state <= blink_on;
        ELSE
          next_state <= idle;
        END IF;

      WHEN blink_on =>
        next_state <= blink_off;

      WHEN blink_off =>
        IF (blink_counter = 2 * BLINK - 1) THEN
          next_state <= blink_end;
        ELSE
          next_state <= blink_on;
        END IF;

      WHEN OTHERS => next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in)
  BEGIN
    finished <= '0';
    data_out <= DATA_DEFAULT;

    CASE present_state IS
      WHEN blink_on => data_out <= data_in;
      WHEN blink_end => finished <= '1';
      WHEN OTHERS => NULL;
    END CASE;
  END PROCESS;
END arch;