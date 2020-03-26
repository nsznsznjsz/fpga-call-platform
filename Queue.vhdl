LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Queue IS
  PORT (
    clock : IN std_logic;

    -- operate
    reset : IN std_logic;
    pop : IN std_logic;
    push : IN std_logic;

    -- state
    empty : OUT std_logic;
    full : OUT std_logic;

    -- data
    data_in : IN std_logic_vector(7 DOWNTO 0); -- depth
    data_out : OUT std_logic_vector(7 DOWNTO 0) -- depth
  );
END Queue;

ARCHITECTURE arch OF Queue IS
  SUBTYPE word IS std_logic_vector(7 DOWNTO 0);
  TYPE queue_array IS ARRAY(7 DOWNTO 0) OF word;
  SIGNAL queue : queue_array;

  TYPE states IS(init, idle, state_pop, state_push, state_full, state_empty);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL front : INTEGER RANGE 0 TO 7 := 0;
  SIGNAL rear : INTEGER RANGE 0 TO 7 := 0;
BEGIN
  -- clock trigger
  PROCESS (clock)
  BEGIN
    IF (reset = '1') THEN
      present_state <= init;
    ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN init =>
        next_state <= state_empty;

      WHEN state_push =>
        IF (front + 1 = rear) THEN
          next_state <= state_full;
        ELSE
          next_state <= idle;
        END IF;

      WHEN state_pop =>
        IF (front = rear + 1) THEN
          next_state <= state_full;
        ELSE
          next_state <= idle;
        END IF;

      WHEN state_empty =>
        IF (push = '1') THEN
          next_state <= state_push;
        END IF;

      WHEN state_full =>
        IF (pop = '1') THEN
          next_state <= state_pop;
        END IF;

      WHEN idle =>
        IF push = '1' THEN
          next_state <= state_push;
        ELSIF pop = '1' THEN
          next_state <= state_pop;
        ELSE
          next_state <= idle;
        END IF;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN init =>
        front <= 0;
        rear <= 0;

      WHEN state_push =>
        front <= front + 1;
        queue(front) <= data_in;

      WHEN state_pop =>
        data_out <= queue(rear);
        rear <= rear + 1;

      WHEN state_empty =>
        full <= '0';
        empty <= '1';

      WHEN state_full =>
        full <= '1';
        empty <= '0';

      WHEN idle =>
        full <= '0';
        empty <= '0';
    END CASE;
  END PROCESS;
END arch;