LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- 将上升沿转换为一个时钟的冲激
ENTITY UpSideTrigger IS
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;

    target : IN std_logic;
    upside : OUT std_logic
  );
END UpSideTrigger;

ARCHITECTURE arch OF UpSideTrigger IS
  TYPE states IS(idle, active, inactivation);
  SIGNAL present_state : states;
  SIGNAL next_state : states;
BEGIN
  -- clock trigger
  PROCESS (clock)
  BEGIN
    IF (reset = '1') THEN
      present_state <= idle;
    ELSIF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        next_state <= active WHEN target = '1' ELSE
          idle;

      WHEN active =>
        next_state <= inactivation;

      WHEN inactivation =>
        next_state <= idle WHEN target = '0' ELSE
          inactivation;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in, data)
  BEGIN
    CASE present_state IS
      WHEN active => upside <= '1';
      WHEN OTHERS => upside <= '0';
    END CASE;
  END PROCESS;
END arch;