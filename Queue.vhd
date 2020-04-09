LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Queue IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16;
    RAM_DEPTH : NATURAL := 32
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;

    -- Write port
    push : IN std_logic;
    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

    -- Read port
    pop : IN std_logic;
    enable_read : OUT std_logic;
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

    -- Flags
    empty : OUT std_logic;
    empty_next : OUT std_logic;
    full : OUT std_logic;
    full_next : OUT std_logic;

    -- The number of elements in the FIFO
    fill_count : OUT INTEGER RANGE RAM_DEPTH - 1 DOWNTO 0
  );
END Queue;

ARCHITECTURE rtl OF Queue IS

  TYPE ram_type IS ARRAY (0 TO RAM_DEPTH - 1) OF std_logic_vector(data_in'RANGE);
  SIGNAL ram : ram_type;

  SUBTYPE index_type IS INTEGER RANGE ram_type'RANGE;
  SIGNAL head : index_type;
  SIGNAL tail : index_type;

  SIGNAL empty_i : std_logic;
  SIGNAL full_i : std_logic;
  SIGNAL fill_count_i : INTEGER RANGE RAM_DEPTH - 1 DOWNTO 0;

  -- Increment and wrap
  PROCEDURE incr(SIGNAL index : INOUT index_type) IS
  BEGIN
    IF index = index_type'high THEN
      index <= index_type'low;
    ELSE
      index <= index + 1;
    END IF;
  END PROCEDURE;

BEGIN
  -- Copy internal signals to output
  empty <= empty_i;
  full <= full_i;
  fill_count <= fill_count_i;

  -- Set the flags
  empty_i <= '1' WHEN fill_count_i = 0 ELSE
    '0';
  empty_next <= '1' WHEN fill_count_i <= 1 ELSE
    '0';
  full_i <= '1' WHEN fill_count_i >= RAM_DEPTH - 1 ELSE
    '0';
  full_next <= '1' WHEN fill_count_i >= RAM_DEPTH - 2 ELSE
    '0';

  -- Update the head pointer in write
  PROC_HEAD : PROCESS (clock)
  BEGIN
    IF rising_edge(clock) THEN
      IF reset = '1' THEN
        head <= 0;
      ELSE

        IF push = '1' AND full_i = '0' THEN
          incr(head);
        END IF;

      END IF;
    END IF;
  END PROCESS;

  -- Update the tail pointer on read and pulse valid
  PROC_TAIL : PROCESS (clock)
  BEGIN
    IF rising_edge(clock) THEN
      IF reset = '1' THEN
        tail <= 0;
        enable_read <= '0';
      ELSE
        enable_read <= '0';

        IF pop = '1' AND empty_i = '0' THEN
          incr(tail);
          enable_read <= '1';
        END IF;

      END IF;
    END IF;
  END PROCESS;

  -- Write to and read from the RAM
  PROC_RAM : PROCESS (clock)
  BEGIN
    IF rising_edge(clock) THEN
      ram(head) <= data_in;
      data_out <= ram(tail);
    END IF;
  END PROCESS;

  -- Update the fill count
  PROC_COUNT : PROCESS (head, tail)
  BEGIN
    IF head < tail THEN
      fill_count_i <= head - tail + RAM_DEPTH;
    ELSE
      fill_count_i <= head - tail;
    END IF;
  END PROCESS;

END ARCHITECTURE;