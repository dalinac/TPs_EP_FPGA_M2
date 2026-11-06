-- top_spi.vhd : encapsulation de spi_dds pour la Red Pitaya (horloge 125 MHz, noms des ports du ports.xdc)

library ieee;
use ieee.std_logic_1164.all;

entity top_spi is
	port (
	adc_clk_p_i, adc_clk_n_i : in std_logic;   -- horloge differentielle 125 MHz
	SW : in std_logic_vector(3 downto 0);
	Button : in std_logic;
	led_o : out std_logic_vector(7 downto 0);
	gfedcba : out std_logic_vector(6 downto 0); -- 7 segments, gfedcba(0) = a
	GPIO : out std_logic_vector(3 downto 0)    -- 0 : SDATA, 1 : SCLK, 2 : FSYNC, 3 : RESET
	);
end top_spi;

architecture a of top_spi is

component spi_dds is
	port (
	clk : in std_logic;
	SW : in std_logic_vector(3 downto 0);
	bouton : in std_logic;
	led : out std_logic_vector(7 downto 0);
	seg : out std_logic_vector(6 downto 0);
	sdata : out std_logic;
	sclk : out std_logic;
	fsync : out std_logic;
	reset : out std_logic
	);
end component;

component IBUFDS is
	port(I, IB : in std_logic;
	O : out std_logic);
end component;

component BUFG is
	port(I : in std_logic;
	O : out std_logic);
end component;

signal clk125, clk_nobuf_s : std_logic;

begin

clk_inst0 : IBUFDS port map (I => adc_clk_p_i, IB => adc_clk_n_i, O => clk_nobuf_s);
clk_inst : BUFG port map (I => clk_nobuf_s, O => clk125);

u : spi_dds port map (clk => clk125, SW => SW, bouton => Button, led => led_o, seg => gfedcba,
	sdata => GPIO(0), sclk => GPIO(1), fsync => GPIO(2), reset => GPIO(3));

end architecture;
