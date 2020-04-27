LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY FD IS
  GENERIC (
    N : NATURAL := 5
  );
  PORT (
    clock : IN std_logic;
    reset : IN std_logic;
    clock_div : OUT std_logic
  );
END FD;

ARCHITECTURE arch OF FD IS
  SIGNAL cnt_up, cnt_down : INTEGER RANGE 0 TO 2 * N - 1;
BEGIN

  PROCESS (cnt_up, cnt_down)
  BEGIN
    IF (cnt_up + cnt_down < N) THEN
      clock_div <= '0';
    ELSE
      clock_div <= '1';
    END IF;
  END PROCESS;

  PROCESS (clock, reset)
  BEGIN
    IF (reset = '1') THEN
      cnt_up <= 0;
    ELSIF (clock'event AND clock = '1') THEN --上升沿计数
      IF (cnt_up < 2 * N - 1) THEN
        cnt_up <= cnt_up + 1;
      ELSE
        cnt_up <= 0;
      END IF;
    END IF;
  END PROCESS;

  PROCESS (clock, reset)
  BEGIN
    IF (reset = '1') THEN
      cnt_down <= 0;
    ELSIF (clock'event AND clock = '0') THEN --下降沿计数
      IF (cnt_down < 2 * N - 1) THEN
        cnt_down <= cnt_down + 1;
      ELSE
        cnt_down <= 0;
      END IF;
    END IF;
  END PROCESS;

END arch;