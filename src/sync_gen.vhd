library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_gen is
  port(
    clk : in std_logic;
    cen : in std_logic;
    hsync, vsync : out std_logic;
    hblank, vblank : out std_logic;
    tile_x, tile_y : out std_logic_vector(4 downto 0);
    pixel_x, pixel_y : out std_logic_vector(2 downto 0)
  );
end sync_gen;

architecture struct of sync_gen is
  signal hcnt   : unsigned(8 downto 0) := to_unsigned(511, 9);
  signal vcnt   : unsigned(8 downto 0) := to_unsigned(511, 9);
  signal vcnt_r : unsigned(8 downto 0) := to_unsigned(511, 9);
begin
  tile_x  <= std_logic_vector(hcnt(7 downto 3));
  tile_y  <= std_logic_vector(vcnt_r(7 downto 3));
  pixel_x <= std_logic_vector(hcnt(2 downto 0));
  pixel_y <= std_logic_vector(vcnt_r(2 downto 0));

  -- Horizontal counter: 511-128 + 1 = 384 pixels
  -- 128 to 175: 48 pixels end of line
  -- 176 to 255: 80 pixels beginning of line
  -- 256 to 511: 256 pixels displayed (32 tiles)

  -- Vertical counter: 511-248 + 1 = 264 lines
  -- 496 to 511: 16 lines end of frame
  -- 248 to 271: 24 lines beginning of frame
  -- 272 to 495: 224 lines displayed (28 tiles)

  -- Horizontal sync: hcnt = [176 to 207] (32 pixels)
  -- Vertical sync: vcnt = [248 to 255] (8 lines)
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

        if    hcnt = (127+8+1) then hblank <= '1'; -- +8 = delay of the shift register + 1 pixel
        elsif hcnt = (255+8+1) then hblank <= '0'; -- +8 = delay of the shift register + 1 pixel
        end if;

        if    vcnt = (495+1+0) then vblank <= '1';
        elsif vcnt = (271+1+1) then vblank <= '0';
        end if;
      end if;
    end if;
  end process;
end architecture;
