LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Service IS
  PORT (
    clock : IN std_logic;

    call : IN std_logic; -- 叫号, 打开 enable_in, enable_out
    recall : IN std_logic; -- 重新叫号, 打开 enable_out

    enable_in : OUT std_logic; -- 打开后等待下一数据后关闭
    enable_out : OUT std_logic; -- 打开后一段时间自动关闭

    data_in : IN std_logic_vector(7 DOWNTO 0);
    data_out : OUT std_logic_vector(7 DOWNTO 0)
  );
END Service;

ARCHITECTURE rtl OF Service IS
  CONSTANT enable_out_length : INTEGER := 1;
  SIGNAL enable_out_count : INTEGER RANGE 0 TO enable_out_length;

  SIGNAL data : std_logic_vector(7 DOWNTO 0);

  SIGNAL s_enable_in : std_logic; -- 接收数据后手动关闭
  SIGNAL s_enable_out : std_logic; -- n clock 后自动关闭
BEGIN
  -- 叫号
  call_next : PROCESS (call)
  BEGIN
    s_enable_in <= '1';
    s_enable_out <= '1';
  END PROCESS;

  -- 重新叫号
  recall_current : PROCESS (call)
  BEGIN
    s_enable_out <= '1';
  END PROCESS;

  -- 自动回落 enable_out
  heartbeat : PROCESS (clock)
  BEGIN
    IF (clock'event AND clock = '1') THEN
      IF (enable_out_count = enable_out_length) THEN
        s_enable_out <= '0';
        enable_out_count <= 0;
      ELSE
        enable_out_count <= enable_out_count + 1;
      END IF;
    END IF;
  END PROCESS;

  -- 输入 data
  data_receiver : PROCESS (s_enable_in, data_in)
  BEGIN
    IF (data_in'event AND s_enable_in = '1') THEN
      data <= data_in;
      s_enable_in <= '0';
    END IF;
  END PROCESS;

  -- 输出 data
  data_output : PROCESS (s_enable_out, data)
  BEGIN
    IF (s_enable_out'event) THEN
      enable_out <= s_enable_out;

      IF (s_enable_out = '1') THEN
        data_out <= data;
      ELSE
        data_out <= "00000000";
      END IF;
    END IF;
  END PROCESS;

  -- 监听 s_enable_in
  output_enable_in : PROCESS (s_enable_in)
  BEGIN
    enable_in <= s_enable_in;
  END PROCESS;

  -- 监听 s_enable_out
  output_enable_out : PROCESS (s_enable_in)
  BEGIN
    enable_out <= s_enable_out;
  END PROCESS;
END rtl;