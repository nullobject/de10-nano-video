library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library pll;

entity video is
  port(
    clk : in std_logic;
    vga_hs, vga_vs : out std_logic;
    vga_r, vga_g, vga_b : out std_logic_vector(5 downto 0);
    vga_en : in std_logic
  );
end video;

architecture arch of video is
  signal pll_clk_12 : std_logic;
  signal pll_locked : std_logic;

  signal video_hsync, video_vsync : std_logic;
  signal video_hblank, video_vblank : std_logic;
  signal video_hpos, video_vpos : unsigned(8 downto 0);

  signal blank : std_logic;
begin
  my_pll : entity pll.pll
  port map(
    refclk   => clk,
    rst      => '0',
    outclk_0 => pll_clk_12,
    locked   => pll_locked
  );

  sync_gen : entity work.sync_gen
  port map(
    clk        => pll_clk_12,
    cen        => '1',
    hsync      => video_hsync,
    vsync      => video_vsync,
    hblank     => video_hblank,
    vblank     => video_vblank,
    hpos       => video_hpos,
    vpos       => video_vpos
  );

  blank <= not (video_hblank or video_vblank);
  vga_hs <= not (video_hsync xor video_vsync);
  vga_vs <= '1';
  vga_r <= "111111" when blank = '0' and ((video_hpos(2 downto 0) = "000") or (video_vpos(2 downto 0) = "000")) else "ZZZZZZ";
  vga_g <= "111111" when blank = '0' and video_hpos(4) = '1' else "ZZZZZZ";
  vga_b <= "111111" when blank = '0' and video_vpos(4) = '1' else "ZZZZZZ";
end arch;
