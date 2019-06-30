library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_gen is
  port(
    clk : in std_logic;
    cen : in std_logic;
    hsync, vsync : out std_logic;
    hblank, vblank : out std_logic;
    hpos, vpos : out unsigned(8 downto 0)
  );
end sync_gen;

architecture struct of sync_gen is
  signal hcnt   : unsigned (8 downto 0) := to_unsigned(511, 9);
  signal vcnt   : unsigned (8 downto 0) := to_unsigned(511, 9);
  signal vcnt_r : unsigned (8 downto 0) := to_unsigned(511, 9);

begin
  hpos <= hcnt;
  vpos <= vcnt_r;

  process(clk)
  begin
    if rising_edge(clk) then
      if cen = '1' then
        if hcnt = 511 then
          hcnt <= to_unsigned(128, 9);
          vcnt_r <= vcnt;
        else
          hcnt <= hcnt + 1;
        end if;

        if hcnt = 175 then
          if vcnt = 511 then
            vcnt <= to_unsigned(248, 9);
          else
            vcnt <= vcnt + 1;
          end if;
        end if;

        if    hcnt = (175+ 0) then hsync <= '0';
        elsif hcnt = (175+29) then hsync <= '1';
        end if;

        if    vcnt = 511 then vsync <= '0';
        elsif vcnt = 250 then vsync <= '1';
        end if;

        if    hcnt = (127+8+1) then hblank <= '1';
        elsif hcnt = (255+8+1) then hblank <= '0';
        end if;

        if    vcnt = (495+1+0) then vblank <= '1';
        elsif vcnt = (271+1+1) then vblank <= '0';
        end if;
      end if;
    end if;
  end process;
end architecture;
