library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity video is
  port(
    clk : in std_logic;
    led : out std_logic_vector(7 downto 0)
  );
end video;

architecture arch of video is
  signal pll_clk_12 : std_logic;
  signal pll_locked : std_logic;
begin
  video : process(clk)
    variable n : unsigned(31 downto 0);
  begin
    if rising_edge(clk) then
      n := n + 1;
      led <= std_logic_vector(n(31 downto 24));
    end if;
  end process;
end arch;
