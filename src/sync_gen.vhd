library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_gen is
  port(
    -- clock
    clk : in std_logic;

    -- clock enable
    cen : in std_logic;

    -- horizontal and vertical position
    hpos, vpos : out unsigned(8 downto 0);

    -- horizontal and vertical sync
    hsync, vsync : out std_logic;

    -- horizontal and vertical blank
    hblank, vblank : out std_logic
  );
end sync_gen;

architecture struct of sync_gen is
  signal hcnt : unsigned(8 downto 0) := 9x"080";
  signal vcnt : unsigned(8 downto 0) := 9x"0fa";
begin
  -- horizontal counter counts $080 to $1ff = 384 (6MHz/384 = 15.625kHz)
  h_counter : process(clk)
  begin
    if rising_edge(clk) then
      if hcnt = 9x"1ff" then -- 511
        hcnt <= 9x"080"; -- 128
      else
        hcnt <= hcnt + 1;
      end if;
    end if;
  end process;

  -- vertical counter counts $0fa to $1ff = 261 (15.625KHz/261 = 59.866Hz)
  v_counter : process(clk)
  begin
    if rising_edge(clk) and hcnt = 9x"1ff" then
      if vcnt = 9x"1ff" then -- 511
        vcnt <= 9x"0fa"; -- 250
      else
        vcnt <= vcnt + 1;
      end if;
    end if;
  end process;

  sync : process(clk)
  begin
    if rising_edge(clk) then
      if hcnt(2 downto 0) = "111" then
        hblank <= hcnt(8);

        case vcnt is
          when 9x"110" => vblank <= '1'; -- 272
          when 9x"1f0" => vblank <= '0'; -- 496
          when 9x"1fb" => vsync <= '1';  -- 507
          when 9x"1fe" => vsync <= '0';  -- 510
          when others => null;
        end case;
      end if;

      case hcnt is
        when 9x"0b2" => hsync <= '1'; -- 178
        when 9x"0ce" => hsync <= '0'; -- 206
        when others => null;
      end case;
    end if;
  end process;

  hpos <= hcnt;
  vpos <= vcnt;
end architecture;
