library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity multiplier is
  port(
    clk : in std_logic;
    a   : in std_logic_vector(15 downto 0);
    b   : in std_logic_vector(15 downto 0);
    p   : out std_logic_vector(31 downto 0)
  );
end multiplier;

architecture IMP of multiplier is
  
begin
  process (clk)
  begin
    if clk'event and clk = '1' then
      p <= a * b;
    end if;
  end process;
end IMP;
