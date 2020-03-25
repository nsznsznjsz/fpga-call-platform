LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY QueueEmiter IS
  PORT (
    clock : IN std_logic;

    data_in : IN std_logic_vector(7 DOWNTO 0); -- length
    data_out : OUT std_logic_vector(7 DOWNTO 0); -- length

    emitted : OUT std_logic;

    -- queue
    full : IN std_logic;
    push : OUT std_logic;
    allow_push : IN std_logic -- used by queue arch, or connect to VCC
  );
END QueueEmiter;

ARCHITECTURE arch OF QueueEmiter IS
  TYPE states IS(waiting, pedding, resloved);
  SIGNAL present_state : states := resloved;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(7 DOWNTO 0);
BEGIN
  trigger : PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  fsm : PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN waiting =>
        IF (data_in(7 DOWNTO 0) = data(7 DOWNTO 0)) THEN
          next_state <= waiting;
        ELSE
          data(7 DOWNTO 0) <= data_in(7 DOWNTO 0);
          emitted <= '0';
          next_state <= pedding;
        END IF;
      WHEN pedding =>
        IF (full = '0' AND allow_push = '1') THEN
          push <= '1';
          data_out(7 DOWNTO 0) <= data(7 DOWNTO 0);
          next_state <= resloved;
        ELSE
          next_state <= pedding;
        END IF;
      WHEN resloved =>
        push <= '0';
        emitted <= '1';
        next_state <= waiting;
      WHEN OTHERS =>
        next_state <= waiting;
    END CASE;
  END PROCESS;
END arch;