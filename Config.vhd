LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;

PACKAGE Config IS
  CONSTANT FLAG_WIDTH : NATURAL := 8;
  CONSTANT DATA_WIDTH : NATURAL := 8;
  CONSTANT RAM_WIDTH : NATURAL := FLAG_WIDTH + DATA_WIDTH;

  -- data 
  CONSTANT DATA_HIGH : NATURAL := DATA_WIDTH - 1;
  CONSTANT DATA_LOW : NATURAL := 0;

  -- queue
  CONSTANT RAM_DEPTH : NATURAL := 32;

  -- screen
  CONSTANT WORD_LENGTH : NATURAL := 5;
  CONSTANT WORD_WIDTH : NATURAL := WORD_LENGTH * 8;

  -- If you are updating FLAGS, you need: 
  -- 1. Update README
  -- 2. (Change order) Update `Waiting`, `Service` and `Decoder`

  -- screen flags
  CONSTANT FLAG_SCREEN_WIDTH : NATURAL := 2;
  CONSTANT FLAG_SCREEN_HIGH : NATURAL := RAM_WIDTH - 1;
  CONSTANT FLAG_SCREEN_LOW : NATURAL := FLAG_SCREEN_HIGH - FLAG_SCREEN_WIDTH + 1;

  CONSTANT FLAG_SCREEN_FREE : std_logic_vector(FLAG_SCREEN_WIDTH - 1 DOWNTO 0) := "00";
  CONSTANT FLAG_SCREEN_WAITING : std_logic_vector(FLAG_SCREEN_WIDTH - 1 DOWNTO 0) := "10";
  CONSTANT FLAG_SCREEN_SERVICE : std_logic_vector(FLAG_SCREEN_WIDTH - 1 DOWNTO 0) := "11";

  -- error flags
  CONSTANT FLAG_ERROR_WIDTH : NATURAL := 3;
  CONSTANT FLAG_ERROR_HIGH : NATURAL := FLAG_SCREEN_LOW - 1;
  CONSTANT FLAG_ERROR_LOW : NATURAL := FLAG_ERROR_HIGH - FLAG_ERROR_WIDTH + 1;

  CONSTANT FLAG_ERROR_FREE : std_logic_vector(FLAG_ERROR_WIDTH - 1 DOWNTO 0) := "111";
  CONSTANT FLAG_ERROR_NON_DATA : std_logic_vector(FLAG_ERROR_WIDTH - 1 DOWNTO 0) := "100";
  CONSTANT FLAG_ERROR_QUEUE_RETRY : std_logic_vector(FLAG_ERROR_WIDTH - 1 DOWNTO 0) := "001";
  CONSTANT FLAG_ERROR_QUEUE_EMPTY : std_logic_vector(FLAG_ERROR_WIDTH - 1 DOWNTO 0) := "010";
  CONSTANT FLAG_ERROR_QUEUE_FULL : std_logic_vector(FLAG_ERROR_WIDTH - 1 DOWNTO 0) := "011";
  CONSTANT FLAG_ERROR_UNKNOWN : std_logic_vector(FLAG_ERROR_WIDTH - 1 DOWNTO 0) := "000";

  -- group flags
  CONSTANT FLAG_GROUP_WIDTH : NATURAL := 3;
  CONSTANT FLAG_GROUP_HIGH : NATURAL := FLAG_ERROR_LOW - 1;
  CONSTANT FLAG_GROUP_LOW : NATURAL := FLAG_GROUP_HIGH - FLAG_GROUP_WIDTH + 1;

  CONSTANT FLAG_GROUP_FREE : std_logic_vector(FLAG_GROUP_WIDTH - 1 DOWNTO 0) := "000";
  CONSTANT FLAG_GROUP_A : std_logic_vector(FLAG_GROUP_WIDTH - 1 DOWNTO 0) := "001";
  CONSTANT FLAG_GROUP_B : std_logic_vector(FLAG_GROUP_WIDTH - 1 DOWNTO 0) := "010";
  CONSTANT FLAG_GROUP_VIPA : std_logic_vector(FLAG_GROUP_WIDTH - 1 DOWNTO 0) := "101";
  CONSTANT FLAG_GROUP_VIPB : std_logic_vector(FLAG_GROUP_WIDTH - 1 DOWNTO 0) := "110";
END;