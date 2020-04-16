LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE work.config.ALL;

ENTITY MultiCounter IS
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

    data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
  );
END MultiCounter;

ARCHITECTURE arch OF MultiCounter IS

  COMPONENT OneToManyArch
    GENERIC (
      RAM_WIDTH : NATURAL
    );
    PORT (
      clock : IN STD_LOGIC;
      enable_pull : IN STD_LOGIC;
      input_1 : IN STD_LOGIC;
      input_2 : IN STD_LOGIC;
      input_3 : IN STD_LOGIC;
      input_4 : IN STD_LOGIC;
      data_in : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
      pull : OUT STD_LOGIC;
      enable_1 : OUT STD_LOGIC;
      enable_2 : OUT STD_LOGIC;
      enable_3 : OUT STD_LOGIC;
      enable_4 : OUT STD_LOGIC;
      data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Counter
    GENERIC (
      RAM_WIDTH : NATURAL
    );
    PORT (
      clock : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      data_out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
  SIGNAL arch_enable_pull : STD_LOGIC;
  SIGNAL arch_pull : STD_LOGIC;
BEGIN
  arch_enable_pull <= NOT(arch_pull);

  b2v_count_arch1 : OneToManyArch
  GENERIC MAP(
    RAM_WIDTH => DATA_WIDTH
  )
  PORT MAP(
    clock => clock,

    enable_pull => arch_enable_pull,

    input_1 => input_1,
    input_2 => input_2,
    input_3 => input_3,
    input_4 => input_4,

    data_in => data,
    pull => arch_pull,

    enable_1 => enable_1,
    enable_2 => enable_2,
    enable_3 => enable_3,
    enable_4 => enable_4,

    data_out => data_out
  );

  b2v_counter1 : Counter
  GENERIC MAP(
    RAM_WIDTH => DATA_WIDTH
  )
  PORT MAP(
    clock => arch_pull,
    reset => reset,
    data_out => data
  );

END arch;