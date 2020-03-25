LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Service IS
  PORT (
    clk : IN std_logic;

    call : IN std_logic; -- �к�, �� en_in, en_out
    recall : IN std_logic; -- ���½к�, �� en_out

    en_in : OUT std_logic; -- �򿪺�ȴ���һ���ݺ�ر�
    en_out : OUT std_logic; -- �򿪺�һ��ʱ���Զ��ر�

    data_in : IN std_logic_vector(7 DOWNTO 0);
    data_out : OUT std_logic_vector(7 DOWNTO 0)
  );
END Service;

-- TODO Ŀǰȫ��������ʱ�ӵ�
ARCHITECTURE rtl OF Service IS
  CONSTANT en_out_length : INTEGER := 1;
  SIGNAL en_out_count : INTEGER RANGE 0 TO en_out_length;

  SIGNAL data : std_logic_vector(7 DOWNTO 0);

  SIGNAL s_en_in : std_logic; -- �������ݺ��ֶ��ر�
  SIGNAL s_en_out : std_logic; -- n clk ���Զ��ر�
BEGIN
  -- �к�
  call_next : PROCESS (call)
  BEGIN
    s_en_in <= '1';
    s_en_out <= '1';
  END PROCESS;

  -- ���½к�
  recall_current : PROCESS (call)
  BEGIN
    s_en_out <= '1';
  END PROCESS;

  -- �Զ����� en_out
  heartbeat : PROCESS (clk)
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (en_out_count = en_out_length) THEN
        s_en_out <= '0';
        en_out_count <= 0;
      ELSE
        en_out_count <= en_out_count + 1;
      END IF;
    END IF;
  END PROCESS;

  -- ���� data
  data_receiver : PROCESS (s_en_in, data_in)
  BEGIN
    IF (data_in'event AND s_en_in = '1') THEN
      data <= data_in;
      s_en_in <= '0';
    END IF;
  END PROCESS;

  -- ��� data
  data_output : PROCESS (s_en_out, data)
  BEGIN
    IF (s_en_out'event) THEN
      en_out <= s_en_out;

      IF (s_en_out = '1') THEN
        data_out <= data;
      ELSE
        data_out <= "00000000";
      END IF;
    END IF;
  END PROCESS;

  -- ���� s_en_in
  output_en_in : PROCESS (s_en_in)
  BEGIN
    en_in <= s_en_in;
  END PROCESS;

  -- ���� s_en_out
  output_en_out : PROCESS (s_en_in)
  BEGIN
    en_out <= s_en_out;
  END PROCESS;
END rtl;