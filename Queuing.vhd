LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;

ENTITY Queuing IS
  PORT (
    clock : IN STD_LOGIC;

    -- for queues
    pull : OUT STD_LOGIC;
    enable_out : IN STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- buttons
    get_number_1 : IN STD_LOGIC;
    get_number_2 : IN STD_LOGIC;
    get_number_3 : IN STD_LOGIC;
    get_number_4 : IN STD_LOGIC;

    -- for customs
    getted_number_1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    getted_number_2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    getted_number_3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    getted_number_4 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END Queuing;

ARCHITECTURE arch OF Queuing IS

  COMPONENT MultiCounter
    PORT (
      clock : IN STD_LOGIC;
      input1 : IN STD_LOGIC;
      input2 : IN STD_LOGIC;
      input3 : IN STD_LOGIC;
      input4 : IN STD_LOGIC;
      enable1 : OUT STD_LOGIC;
      enable2 : OUT STD_LOGIC;
      enable3 : OUT STD_LOGIC;
      enable4 : OUT STD_LOGIC;
      data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT ManyToOneArch
    PORT (
      clock : IN STD_LOGIC;
      enable_push : IN STD_LOGIC;
      enable1 : IN STD_LOGIC;
      enable2 : IN STD_LOGIC;
      enable3 : IN STD_LOGIC;
      enable4 : IN STD_LOGIC;
      data_in1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      data_in2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      data_in3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      data_in4 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      push : OUT STD_LOGIC;
      emitted1 : OUT STD_LOGIC;
      emitted2 : OUT STD_LOGIC;
      emitted3 : OUT STD_LOGIC;
      emitted4 : OUT STD_LOGIC;
      data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Waiting
    PORT (
      clock : IN STD_LOGIC;
      button : IN STD_LOGIC;
      enable_pull : IN STD_LOGIC;
      pushed : IN STD_LOGIC;
      data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      pull : OUT STD_LOGIC;
      push : OUT STD_LOGIC;
      data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL pull_1 : STD_LOGIC;
  SIGNAL pull_2 : STD_LOGIC;
  SIGNAL pull_3 : STD_LOGIC;
  SIGNAL pull_4 : STD_LOGIC;

  SIGNAL push_1 : STD_LOGIC;
  SIGNAL push_2 : STD_LOGIC;
  SIGNAL push_3 : STD_LOGIC;
  SIGNAL push_4 : STD_LOGIC;

  -- test port
  SIGNAL s_getted_number_1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL s_getted_number_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL s_getted_number_3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL s_getted_number_4 : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL data : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL enable_1 : STD_LOGIC;
  SIGNAL enable_2 : STD_LOGIC;
  SIGNAL enable_3 : STD_LOGIC;
  SIGNAL enable_4 : STD_LOGIC;

  SIGNAL emitted_1 : STD_LOGIC;
  SIGNAL emitted_2 : STD_LOGIC;
  SIGNAL emitted_3 : STD_LOGIC;
  SIGNAL emitted_4 : STD_LOGIC;
BEGIN
  getted_number_1 <= s_getted_number_1;
  getted_number_2 <= s_getted_number_2;
  getted_number_3 <= s_getted_number_3;
  getted_number_4 <= s_getted_number_4;

  b2v_counter_1 : MultiCounter
  PORT MAP(
    clock => clock,
    input1 => pull_1,
    input2 => pull_2,
    input3 => pull_3,
    input4 => pull_4,
    enable1 => enable_1,
    enable2 => enable_2,
    enable3 => enable_3,
    enable4 => enable_4,
    data_out => data
  );

  b2v_custom_arch_1 : ManyToOneArch
  PORT MAP(
    clock => clock,
    enable_push => enable_out,
    enable1 => push_1,
    enable2 => push_2,
    enable3 => push_3,
    enable4 => push_4,
    data_in1 => s_getted_number_1,
    data_in2 => s_getted_number_2,
    data_in3 => s_getted_number_3,
    data_in4 => s_getted_number_4,
    push => pull,
    emitted1 => emitted_1,
    emitted2 => emitted_2,
    emitted3 => emitted_3,
    emitted4 => emitted_4,
    data_out => data_out
  );

  b2v_custom_side_1 : Waiting
  PORT MAP(
    clock => clock,
    button => get_number_1,
    enable_pull => enable_1,
    pushed => emitted_1,
    data_in => data,
    pull => pull_1,
    push => push_1,
    data_out => s_getted_number_1
  );

  b2v_custom_side_2 : Waiting
  PORT MAP(
    clock => clock,
    button => get_number_2,
    enable_pull => enable_2,
    pushed => emitted_2,
    data_in => data,
    pull => pull_2,
    push => push_2,
    data_out => s_getted_number_2
  );

  b2v_custom_side_3 : Waiting
  PORT MAP(
    clock => clock,
    button => get_number_3,
    enable_pull => enable_3,
    pushed => emitted_3,
    data_in => data,
    pull => pull_3,
    push => push_3,
    data_out => s_getted_number_3
  );

  b2v_custom_side_4 : Waiting
  PORT MAP(
    clock => clock,
    button => get_number_4,
    enable_pull => enable_4,
    pushed => emitted_4,
    data_in => data,
    pull => pull_4,
    push => push_4,
    data_out => s_getted_number_4
  );

END arch;