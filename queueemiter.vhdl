LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY QueueEmiter IS
  PORT (
    clock : IN std_logic;

    changed : IN std_logic;
    emitted : OUT std_logic;

    data_in : IN std_logic_vector(7 DOWNTO 0); -- length
    data_out : OUT std_logic_vector(7 DOWNTO 0); -- length

    -- queue
    push : OUT std_logic;
    allow_push : IN std_logic -- used by queue arch, or connect to queue.full
  );
END QueueEmiter;

ARCHITECTURE arch OF QueueEmiter IS
  TYPE states IS(idle, waiting, sending, sent);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(7 DOWNTO 0);
BEGIN
  -- clock trigger
  PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (changed = '1') THEN
          next_state <= waiting;
        ELSE
          next_state <= idle;
        END IF;

      WHEN waiting =>
        IF allow_push = '1' THEN
          next_state <= sending;
        ELSE
          next_state <= waiting;
        END IF;

      WHEN sending =>
        next_state <= sent;

      WHEN sent =>
        next_state <= idle;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        NULL;

      WHEN waiting =>
        emitted <= '0';
        data(7 DOWNTO 0) <= data_in(7 DOWNTO 0);

      WHEN sending =>
        push <= '1';
        data_out(7 DOWNTO 0) <= data(7 DOWNTO 0);

      WHEN sent =>
        push <= '0';
        emitted <= '1';
    END CASE;
  END PROCESS;
END arch;