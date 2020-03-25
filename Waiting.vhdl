LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- 取号器, 从Counter取号并发送出去
ENTITY Waiting IS
  PORT (
    clock : IN std_logic;

    get : IN std_logic;
    enable_in : OUT std_logic;

    data_in : IN std_logic_vector(7 DOWNTO 0);
    data_out : OUT std_logic_vector(7 DOWNTO 0)
  );
END Waiting;

ARCHITECTURE arch OF Waiting IS
  CONSTANT LENGTH : INTEGER := 7; -- 8

  TYPE states IS(waiting, pedding, resloved);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(LENGTH DOWNTO 0);
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
        IF (get = '1') THEN
          enable_in <= '1';
          next_state <= pedding;
        ELSE
          next_state <= waiting;
        END IF;
      WHEN pedding =>
        -- IF (data(LENGTH DOWNTO 0) = data_in(LENGTH DOWNTO 0)) THEN
        --  next_state <= pedding;
        -- ELSE
        data(LENGTH DOWNTO 0) <= data_in(LENGTH DOWNTO 0);
        next_state <= resloved;
        -- END IF;
      WHEN resloved =>
        enable_in <= '0';
        data_out(LENGTH DOWNTO 0) <= data(LENGTH DOWNTO 0);
        next_state <= waiting;
      WHEN OTHERS =>
        next_state <= waiting;
    END CASE;
  END PROCESS;
END arch;