library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_gen is
  port(
    clk : in std_logic;
    cen : in std_logic := '1';
    hsync : out std_logic;
    vsync : out std_logic;
    csync : out std_logic;
    hblank : out std_logic;
    vblank : out std_logic
  );
end video_gen;

architecture struct of video_gen is
  signal hcnt : unsigned (8 downto 0) := to_unsigned(511, 9);
  signal vcnt : unsigned (8 downto 0) := to_unsigned(511, 9);

  signal hsync0 : std_logic;
  signal hsync1 : std_logic;
  signal hsync2 : std_logic;
begin
  hsync <= hsync0;

  -- Compteur horizontal : 511-128+1=384 pixels
  -- 128 à 175 :  48 pixels fin de ligne
  -- 176 à 255 :  80 pixels debut de ligne
  -- 256 à 511 : 256 pixels affichés (32 tiles)

  -- Compteur vertical   : 511-248+1=264 lignes
  -- 496 à 511 :  16 lignes fin de trame
  -- 248 à 271 :  24 lignes debut de trame
  -- 272 à 495 : 224 lignes affichées (28 tiles)

  -- Synchro horizontale : hcnt=[176 à 207] (32 pixels)
  -- Synchro verticale   : vcnt=[248 à 255] ( 8 lignes)

  process(clk)
  begin
    if rising_edge(clk) then
      if cen = '1' then
        if hcnt = 511 then
          hcnt <= to_unsigned (128,9);
        else
          hcnt <= hcnt + 1;
        end if;

        if hcnt = 175 then
          if vcnt = 511 then
            vcnt <= to_unsigned(248,9);
          else
            vcnt <= vcnt + 1;
          end if;
        end if;

        if    hcnt = (175+ 0) then hsync0 <= '0';
        elsif hcnt = (175+29) then hsync0 <= '1';
        end if;

        if    hcnt = (175)        then hsync1 <= '0';
        elsif hcnt = (175+13)     then hsync1 <= '1';
        elsif hcnt = (175   +192) then hsync1 <= '0';
        elsif hcnt = (175+13+192) then hsync1 <= '1';
        end if;

        if    hcnt = (175)    then hsync2 <= '0';
        elsif hcnt = (175-28) then hsync2 <= '1';
        end if;

        if    vcnt = 509 then csync <= hsync1;
        elsif vcnt = 510 then csync <= hsync1;
        elsif vcnt = 511 then csync <= hsync1;
        elsif vcnt = 248 then csync <= hsync2;
        elsif vcnt = 249 then csync <= hsync2;
        elsif vcnt = 250 then csync <= hsync2;
        elsif vcnt = 251 then csync <= hsync1;
        elsif vcnt = 252 then csync <= hsync1;
        elsif vcnt = 253 then csync <= hsync1;
        else                  csync <= hsync0;
        end if;

        if    vcnt = 511 then vsync <= '0';
        elsif vcnt = 250 then vsync <= '1';
        end if;

        if    hcnt = (127+8+1) then hblank <= '1'; -- +8 = retard du shift_register + 1 pixel--
        elsif hcnt = (255+8+1) then hblank <= '0'; -- +8 = retard du shift_register + 1 pixel--
        end if;

        if    vcnt = (495+1+0) then vblank <= '1';
        elsif vcnt = (271+1+1) then vblank <= '0';
        end if;
      end if;
    end if;
  end process;
end architecture;
