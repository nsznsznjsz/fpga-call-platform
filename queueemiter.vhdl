LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY QueueEmiter IS
  PORT (
    data_in : IN std_logic_vector(7 DOWNTO 0);
    data_out : OUT std_logic_vector(7 DOWNTO 0);

    emitted : OUT std_logic;

    -- queue
    full : IN std_logic;
    push : OUT std_logic;
    allow_push : IN std_logic -- used by queue arch, or connect to VCC
  );
END QueueEmiter;

ARCHITECTURE arch OF QueueEmiter IS
  TYPE states IS(pedding, resloved);
  SIGNAL present_state : states := resloved;
  SIGNAL next_state : states;

  SIGNAL data_changed_flag : std_logic;
  SIGNAL emitted_flag : std_logic;
  SIGNAL data : std_logic_vector(7 DOWNTO 0);
BEGIN
  data_listener : PROCESS (data_in)
  BEGIN
    -- 覆盖模式, 禁止覆盖则取消下列注释
    -- IF (emitted = '1') THEN
    data <= data_in;
    data_changed_flag <= NOT data_changed_flag;
  END PROCESS;

  emitter : PROCESS (allow_push, full, data)
  BEGIN
    IF (present_state = pedding AND full = '0' AND allow_push = '1') THEN
      emitted_flag <= NOT emitted_flag;
    END IF;
  END PROCESS;

  trigger : PROCESS (data_changed_flag, emitted_flag)
  BEGIN
    present_state <= next_state;
  END PROCESS;

  fsm : PROCESS (present_state)
  BEGIN
    CASE present_state IS
      WHEN pedding =>
        push <= '1';
        emitted <= '0';
        next_state <= resloved;
      WHEN resloved =>
        push <= '0';
        emitted <= '1';
        next_state <= pedding;
      WHEN OTHERS =>
        next_state <= resloved;
    END CASE;
  END PROCESS;
END arch;