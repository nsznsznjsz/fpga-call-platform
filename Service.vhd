LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- 数据源 -> 取号 -> 发射 -> 接收器
ENTITY Service IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16
  );
  PORT (
    clock : IN std_logic;
    call : IN std_logic; -- 叫号
    recall : IN std_logic; -- 重新叫号

    pull : OUT std_logic; -- 申请取号
    enable_pull : IN std_logic; -- 允许取号

    push : OUT std_logic; -- 申请发送
    pushed : IN std_logic; -- 已发送

    data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
    data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
  );
END Service;

ARCHITECTURE arch OF Service IS
  -- If you are updating flags, you need: 
  -- 1. Update README
  -- 2. Synchronous update `Waiting`, `Service` and `Decoder`
  -- 3. Check groups flag is right, vip_flags = bit_xor(vip, group)
  --
  -- I try my best to maintain the consistency of the flags, but we
  -- need a better way to replace the manual operation. 

  CONSTANT FLAG_SCREEN_WAITING : std_logic_vector(1 DOWNTO 0) := "10";
  CONSTANT FLAG_SCREEN_SERVICE : std_logic_vector(1 DOWNTO 0) := "11";

  CONSTANT FLAG_GROUP_FREE : std_logic_vector(3 DOWNTO 0) := "0000";
  CONSTANT FLAG_GROUP_A : std_logic_vector(3 DOWNTO 0) := "0001";
  CONSTANT FLAG_GROUP_B : std_logic_vector(3 DOWNTO 0) := "0010";
  CONSTANT FLAG_GROUP_VIPA : std_logic_vector(3 DOWNTO 0) := "1001";
  CONSTANT FLAG_GROUP_VIPB : std_logic_vector(3 DOWNTO 0) := "1001";

  CONSTANT FLAG_ERROR_FREE : std_logic_vector(1 DOWNTO 0) := "00";
  CONSTANT FLAG_ERROR_QUEUE_EMPTY : std_logic_vector(1 DOWNTO 0) := "10";
  CONSTANT FLAG_ERROR_QUEUE_FULL : std_logic_vector(1 DOWNTO 0) := "11";
  CONSTANT FLAG_ERROR_UNKNOWN : std_logic_vector(1 DOWNTO 0) := "01";

  TYPE states IS(idle, pulling, pulled, pushing, success);
  SIGNAL present_state : states;
  SIGNAL next_state : states;

  SIGNAL data : std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);

  -- jump next state
  PROCEDURE waitOrNext(
    SIGNAL next_state : OUT states;
    SIGNAL enable : IN std_logic;
    CONSTANT s_wait : IN states;
    CONSTANT s_next : IN states
  ) IS
  BEGIN
    IF (enable = '1') THEN
      next_state <= s_next;
    ELSE
      next_state <= s_wait;
    END IF;
  END PROCEDURE;
BEGIN
  -- clock trigger
  PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      present_state <= next_state;
    END IF;
  END PROCESS;

  -- state change
  PROCESS (present_state, call, recall, enable_pull, pushed)
  BEGIN
    CASE present_state IS
      WHEN idle =>
        IF (call = '1') THEN
          next_state <= pulling;
        ELSIF (recall = '1') THEN
          next_state <= pushing;
        ELSE
          next_state <= idle;
        END IF;

      WHEN pulling =>
        waitOrNext(next_state, enable_pull, pulling, pulled);

      WHEN pulled =>
        next_state <= pushing;

      WHEN pushing =>
        waitOrNext(next_state, pushed, pushing, success);

      WHEN success =>
        next_state <= idle;

      WHEN OTHERS =>
        next_state <= idle;
    END CASE;
  END PROCESS;

  -- state events
  PROCESS (present_state, data_in, data)
  BEGIN
    -- make latches: data, data_out
    push <= '0';
    pull <= '0';

    CASE present_state IS
      WHEN idle =>
        data <= (OTHERS => '0');
        data <=
          FLAG_SCREEN_SERVICE
          & FLAG_GROUP_FREE
          & FLAG_ERROR_UNKNOWN
          & data(RAM_WIDTH - 9 DOWNTO 0);

      WHEN pulling =>
        pull <= '1';
        data <= FLAG_SCREEN_SERVICE & data_in(13 DOWNTO 0);

      WHEN pulled =>
        pull <= '0';

      WHEN pushing =>
        push <= '1';
        data_out <= data;

      WHEN success =>
        push <= '0';

      WHEN OTHERS => NULL;

    END CASE;
  END PROCESS;
END arch;