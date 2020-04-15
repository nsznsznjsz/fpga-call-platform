LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE work.config.ALL;

ENTITY Services IS
  PORT (
    clock : IN STD_LOGIC;
    reset : IN STD_LOGIC;

    call_1 : IN STD_LOGIC;
    call_2 : IN STD_LOGIC;
    call_3 : IN STD_LOGIC;
    call_4 : IN STD_LOGIC;

    recall_1 : IN STD_LOGIC;
    recall_2 : IN STD_LOGIC;
    recall_3 : IN STD_LOGIC;
    recall_4 : IN STD_LOGIC;

    pull : OUT STD_LOGIC;
    enable_pull : IN STD_LOGIC;
    pushed : IN STD_LOGIC;

    push_1 : OUT STD_LOGIC;
    push_2 : OUT STD_LOGIC;
    push_3 : OUT STD_LOGIC;
    push_4 : OUT STD_LOGIC;

    data_in : IN STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    data_out_1 : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    data_out_2 : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    data_out_3 : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    data_out_4 : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0)
  );
END Services;

ARCHITECTURE bdf_type OF Services IS

  COMPONENT Service IS
    PORT (
      clock : IN std_logic;
      call : IN std_logic; -- ½ÐºÅ
      recall : IN std_logic; -- ÖØÐÂ½ÐºÅ

      pull : OUT std_logic; -- ÉêÇëÈ¡ºÅ
      enable_pull : IN std_logic; -- ÔÊÐíÈ¡ºÅ

      push : OUT std_logic; -- ÉêÇë·¢ËÍ
      pushed : IN std_logic; -- ÒÑ·¢ËÍ

      data_in : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
      data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT OneToManyArch
    GENERIC (
      RAM_WIDTH : INTEGER
    );
    PORT (
      clock : IN STD_LOGIC;
      enable_pull : IN STD_LOGIC;
      input_1 : IN STD_LOGIC;
      input_2 : IN STD_LOGIC;
      input_3 : IN STD_LOGIC;
      input_4 : IN STD_LOGIC;
      data_in : IN STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
      pull : OUT STD_LOGIC;
      enable_1 : OUT STD_LOGIC;
      enable_2 : OUT STD_LOGIC;
      enable_3 : OUT STD_LOGIC;
      enable_4 : OUT STD_LOGIC;
      data_out : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL data : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);

  SIGNAL pull_1 : STD_LOGIC;
  SIGNAL pull_2 : STD_LOGIC;
  SIGNAL pull_3 : STD_LOGIC;
  SIGNAL pull_4 : STD_LOGIC;

  SIGNAL enable_pull_1 : STD_LOGIC;
  SIGNAL enable_pull_2 : STD_LOGIC;
  SIGNAL enable_pull_3 : STD_LOGIC;
  SIGNAL enable_pull_4 : STD_LOGIC;

BEGIN

  b2v_service_1 : Service
  PORT MAP(
    clock => clock,
    call => call_1,
    recall => recall_1,
    enable_pull => enable_pull_1,
    pushed => pushed,
    data_in => data,
    pull => pull_1,
    push => push_1,
    data_out => data_out_1
  );

  b2v_service_2 : Service
  PORT MAP(
    clock => clock,
    call => call_2,
    recall => recall_2,
    enable_pull => enable_pull_2,
    pushed => pushed,
    data_in => data,
    pull => pull_2,
    push => push_2,
    data_out => data_out_2
  );

  b2v_service_3 : Service
  PORT MAP(
    clock => clock,
    call => call_3,
    recall => recall_3,
    enable_pull => enable_pull_3,
    pushed => pushed,
    data_in => data,
    pull => pull_3,
    push => push_3,
    data_out => data_out_3
  );

  b2v_service_4 : Service
  PORT MAP(
    clock => clock,
    call => call_4,
    recall => recall_4,
    enable_pull => enable_pull_4,
    pushed => pushed,
    data_in => data,
    pull => pull_4,
    push => push_4,
    data_out => data_out_4
  );

  b2v_service_arch1 : OneToManyArch
  GENERIC MAP(
    RAM_WIDTH => RAM_WIDTH
  )
  PORT MAP(
    clock => clock,
    enable_pull => enable_pull,
    input_1 => pull_1,
    input_2 => pull_2,
    input_3 => pull_3,
    input_4 => pull_4,
    data_in => data_in,
    pull => pull,
    enable_1 => enable_pull_1,
    enable_2 => enable_pull_2,
    enable_3 => enable_pull_3,
    enable_4 => enable_pull_4,
    data_out => data
  );

END bdf_type;