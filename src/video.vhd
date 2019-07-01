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
  signal pll_clk_6 : std_logic;
  signal pll_locked : std_logic;

  signal video_hsync, video_vsync : std_logic;
  signal video_hblank, video_vblank : std_logic;
  signal video_tile_x, video_tile_y : std_logic_vector(4 downto 0);
  signal video_pixel_x, video_pixel_y : std_logic_vector(2 downto 0);

  signal video_on : std_logic;
begin
  my_pll : entity pll.pll
  port map(
    refclk   => clk,
    rst      => '0',
    outclk_0 => pll_clk_6,
    locked   => pll_locked
  );

  sync_gen : entity work.sync_gen
  port map(
    clk     => pll_clk_6,
    cen     => '1',
    hsync   => video_hsync,
    vsync   => video_vsync,
    hblank  => video_hblank,
    vblank  => video_vblank,
    tile_x  => video_tile_x,
    tile_y  => video_tile_y,
    pixel_x => video_pixel_x,
    pixel_y => video_pixel_y
  );

  video_on <= not (video_hblank or video_vblank);
  vga_hs <= not (video_hsync xor video_vsync);
  vga_vs <= '1';
  -- vga_r <= "111111" when video_on = '1' and ((video_hpos(2 downto 0) = "000") or (video_vpos(2 downto 0) = "000")) else "ZZZZZZ";
  -- vga_g <= "111111" when video_on = '1' and video_hpos(4) = '1' else "ZZZZZZ";
  -- vga_b <= "111111" when video_on = '1' and video_vpos(4) = '1' else "ZZZZZZ";
  vga_r <= "111111" when video_on = '1' and ((video_pixel_x = "000") or (video_pixel_y = "000")) else "ZZZZZZ";
end arch;
