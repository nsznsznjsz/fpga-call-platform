LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY FIFO IS
  PORT (
    reset : IN std_logic;
    rd, wr : IN std_logic;
    empty, full : OUT std_logic;
    data_in : IN std_logic_vector(7 DOWNTO 0); -- deep
    data_out : OUT std_logic_vector(7 DOWNTO 0) -- deep
  );
END FIFO;

ARCHITECTURE rtl OF FIFO IS
  CONSTANT LENGTH : INTEGER := 7; -- 8
  CONSTANT DEEP : INTEGER := 7; -- 8

  SUBTYPE word IS std_logic_vector(DEEP DOWNTO 0);
  TYPE queue_array IS ARRAY(LENGTH DOWNTO 0) OF word;
  SIGNAL queue : queue_array;

  SIGNAL front : INTEGER RANGE 0 TO LENGTH;
  SIGNAL rear : INTEGER RANGE 0 TO LENGTH;

  SIGNAL s_full : std_logic;
  SIGNAL s_empty : std_logic;
BEGIN
  front <= 0;
  rear <= 0;

  handle_reset : PROCESS (reset)
  BEGIN
    IF (reset'event AND reset = '1') THEN
      front <= 0;
      rear <= 0;
    END IF;
  END PROCESS;

  push : PROCESS (rd, data_in, queue)
  BEGIN
    IF (rd'event AND rd = '1' AND s_full = '0') THEN
      front <= front + 1;
      queue(front) <= data_in;
    END IF;
  END PROCESS;

  pop : PROCESS (wr, queue)
  BEGIN
    IF (wr'event AND wr = '1' AND s_empty = '0') THEN
      data_out <= queue(rear);
      rear <= rear + 1;
    END IF;
  END PROCESS;

  state_update : PROCESS (front, rear, s_full, s_empty)
  BEGIN
    IF (front + 1 = rear) THEN
      s_full <= '1';
      s_empty <= '0';
    ELSIF (front = rear) THEN
      s_full <= '0';
      s_empty <= '1';
    ELSE
      s_full <= '0';
      s_empty <= '0';
    END IF;
  END PROCESS;

  state_output : PROCESS (s_full, s_empty)
  BEGIN
    full <= s_full;
    empty <= s_empty;
  END PROCESS;
END rtl;