LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;

PACKAGE Config IS
  CONSTANT FLAG_WIDTH : NATURAL := 8;
  CONSTANT DATA_WIDTH : NATURAL := 8;
  CONSTANT RAM_WIDTH : NATURAL := FLAG_WIDTH + DATA_WIDTH;

  -- queue
  CONSTANT RAM_DEPTH : NATURAL := 32;

  -- screen
  CONSTANT WORD_LENGTH : NATURAL := 5;

  -- FLAGS
  --
  -- If you are updating flags, you need: 
  -- 1. Update README (do it!)
  -- 2. Check groups flag is right, vip_flags = bit_xor(vip, group)
  -- 3. (Change Width) Update `Waiting`, `Service` and `Decoder`

  CONSTANT FLAG_SCREEN_WAITING : std_logic_vector(1 DOWNTO 0) := "10";
  CONSTANT FLAG_SCREEN_SERVICE : std_logic_vector(1 DOWNTO 0) := "11";

  CONSTANT FLAG_GROUP_FREE : std_logic_vector(3 DOWNTO 0) := "0000";
  CONSTANT FLAG_GROUP_A : std_logic_vector(3 DOWNTO 0) := "0001";
  CONSTANT FLAG_GROUP_B : std_logic_vector(3 DOWNTO 0) := "0010";
  CONSTANT FLAG_GROUP_VIPA : std_logic_vector(3 DOWNTO 0) := "1001";
  CONSTANT FLAG_GROUP_VIPB : std_logic_vector(3 DOWNTO 0) := "1010";

  CONSTANT FLAG_ERROR_FREE : std_logic_vector(1 DOWNTO 0) := "00";
  CONSTANT FLAG_ERROR_QUEUE_EMPTY : std_logic_vector(1 DOWNTO 0) := "10";
  CONSTANT FLAG_ERROR_QUEUE_FULL : std_logic_vector(1 DOWNTO 0) := "11";
  CONSTANT FLAG_ERROR_UNKNOWN : std_logic_vector(1 DOWNTO 0) := "01";
END;