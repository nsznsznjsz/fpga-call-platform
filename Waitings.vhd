LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;

-- 客户端取号器
ENTITY Waitings IS
  GENERIC (
    RAM_WIDTH : NATURAL := 16;
    FLAGS_1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- flag width
    FLAGS_2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- flag width
    FLAGS_3 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- flag width
    FLAGS_4 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0') -- flag width
  );
  PORT (
    clock : IN STD_LOGIC;
    reset : IN std_logic;

    -- for queues
    pull : OUT STD_LOGIC;
    enable_out : IN STD_LOGIC;
    data_out : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);

    -- buttons
    get_number_1 : IN STD_LOGIC;
    get_number_2 : IN STD_LOGIC;
    get_number_3 : IN STD_LOGIC;
    get_number_4 : IN STD_LOGIC;

    -- for customs
    getted_number_1 : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    getted_number_2 : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    getted_number_3 : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
    getted_number_4 : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0)
  );
END Waitings;

ARCHITECTURE arch OF Waitings IS

  COMPONENT MultiCounter
    GENERIC (
      RAM_WIDTH : NATURAL
    );
    PORT (
      clock : IN STD_LOGIC;
      reset : IN STD_LOGIC;

      input_1 : IN STD_LOGIC;
      input_2 : IN STD_LOGIC;
      input_3 : IN STD_LOGIC;
      input_4 : IN STD_LOGIC;

      enable_1 : OUT STD_LOGIC;
      enable_2 : OUT STD_LOGIC;
      enable_3 : OUT STD_LOGIC;
      enable_4 : OUT STD_LOGIC;

      data_out : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT ManyToOneArch
    GENERIC (
      RAM_WIDTH : NATURAL
    );
    PORT (
      clock : IN std_logic;

      push : OUT std_logic;
      enable_push : IN std_logic;

      enable_1 : IN std_logic;
      enable_2 : IN std_logic;
      enable_3 : IN std_logic;
      enable_4 : IN std_logic;

      emitted_1 : OUT std_logic;
      emitted_2 : OUT std_logic;
      emitted_3 : OUT std_logic;
      emitted_4 : OUT std_logic;

      data_in_1 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
      data_in_2 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
      data_in_3 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
      data_in_4 : IN std_logic_vector(RAM_WIDTH - 1 DOWNTO 0);
      data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Waiting
    GENERIC (
      RAM_WIDTH : NATURAL;
      FLAGS : STD_LOGIC_VECTOR(7 DOWNTO 0) -- flag width
    );
    PORT (
      clock : IN std_logic;
      button : IN std_logic; -- 用户取号

      pull : OUT std_logic; -- 申请取号
      enable_pull : IN std_logic; -- 允许取号

      push : OUT std_logic; -- 申请发送
      pushed : IN std_logic; -- 已发送

      data_in : IN std_logic_vector(RAM_WIDTH - 9 DOWNTO 0);
      data_out : OUT std_logic_vector(RAM_WIDTH - 1 DOWNTO 0)
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

  SIGNAL s_getted_number_1 : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL s_getted_number_2 : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL s_getted_number_3 : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
  SIGNAL s_getted_number_4 : STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);

  SIGNAL data : STD_LOGIC_VECTOR(RAM_WIDTH - 9 DOWNTO 0);

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
  GENERIC MAP(
    RAM_WIDTH => RAM_WIDTH - 8 -- flag width
  )
  PORT MAP(
    clock => clock,
    reset => reset,
    input_1 => pull_1,
    input_2 => pull_2,
    input_3 => pull_3,
    input_4 => pull_4,
    enable_1 => enable_1,
    enable_2 => enable_2,
    enable_3 => enable_3,
    enable_4 => enable_4,
    data_out => data
  );

  b2v_custom_arch_1 : ManyToOneArch
  GENERIC MAP(
    RAM_WIDTH => RAM_WIDTH
  )
  PORT MAP(
    clock => clock,
    enable_push => enable_out,
    enable_1 => push_1,
    enable_2 => push_2,
    enable_3 => push_3,
    enable_4 => push_4,
    data_in_1 => s_getted_number_1,
    data_in_2 => s_getted_number_2,
    data_in_3 => s_getted_number_3,
    data_in_4 => s_getted_number_4,
    push => pull,
    emitted_1 => emitted_1,
    emitted_2 => emitted_2,
    emitted_3 => emitted_3,
    emitted_4 => emitted_4,
    data_out => data_out
  );

  b2v_custom_side_1 : Waiting
  GENERIC MAP(
    RAM_WIDTH => RAM_WIDTH,
    FLAGS => FLAGS_1
  )
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
  GENERIC MAP(
    RAM_WIDTH => RAM_WIDTH,
    FLAGS => FLAGS_2
  )
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
  GENERIC MAP(
    RAM_WIDTH => RAM_WIDTH,
    FLAGS => FLAGS_3
  )
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
  GENERIC MAP(
    RAM_WIDTH => RAM_WIDTH,
    FLAGS => FLAGS_4
  )
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