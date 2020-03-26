LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- 取号器
ENTITY Waiting IS
  PORT (
    clock : IN std_logic;
    button : IN std_logic; -- 用户取号

    pull : OUT std_logic; -- 申请取号
    enable_pull : IN std_logic; -- 允许取号

    push : OUT std_logic; -- 申请发送
    pushed : IN std_logic; -- 已发送

    data_in : IN std_logic_vector(7 DOWNTO 0);
    data_out : OUT std_logic_vector(7 DOWNTO 0)
  );
END Waiting;

ARCHITECTURE arch OF Waiting IS
  TYPE states IS(idle, pulling, pulled, pushing, success);
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
        IF (button = '1') THEN
          next_state <= pulling;
        ELSE
          next_state <= idle;
        END IF;

      WHEN pulling =>
        IF (enable_pull = '1') THEN
          next_state <= pulled;
        ELSE
          next_state <= pulling;
        END IF;

      WHEN pulled =>
        next_state <= pushing;

      WHEN pushing =>
        IF (pushed = '1') THEN
          next_state <= success;
        ELSE
          next_state <= pushing;
        END IF;

      WHEN success =>
        next_state <= idle;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state)
  BEGIN
    push <= '0';
    pull <= '0';

    CASE present_state IS
      WHEN idle => NULL;

      WHEN pulling =>
        pull <= '1';

      WHEN pulled =>
        pull <= '0';
        data(7 DOWNTO 0) <= data_in(7 DOWNTO 0);

      WHEN pushing =>
        push <= '1';
        data_out(7 DOWNTO 0) <= data(7 DOWNTO 0);

      WHEN success =>
        push <= '0';

      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;
END arch;