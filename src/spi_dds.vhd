-- spi_dds.vhd : 3e entite, choisit le mot de 16 bits avec les switches, l'affiche (7 segments et leds) et l'envoie au DDS

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_dds is
	port (
	clk : in std_logic;
	SW : in std_logic_vector(3 downto 0); -- SW(1..0) : choix du mot, SW(3..2) : choix du quartet affiche
	bouton : in std_logic;
	led : out std_logic_vector(7 downto 0);
	seg : out std_logic_vector(6 downto 0); -- seg(0) = a, ..., seg(6) = g
	sdata : out std_logic;
	sclk : out std_logic;
	fsync : out std_logic;
	reset : out std_logic
	);
end spi_dds;

architecture a of spi_dds is

component spi_tx is
	generic (
	tscale : integer range 3 to 1000 := 20;
	N : integer range 1 to 32 := 16
	);
	port (
	clk : in std_logic;
	en : in std_logic;
	data : in std_logic_vector(N-1 downto 0);
	sclk : out std_logic;
	sdata : out std_logic;
	fin : out std_logic
	);
end component;

component fsm_spi is
	port (
	clk : in std_logic;
	bouton : in std_logic;
	fin : in std_logic;
	fsync : out std_logic;
	en : out std_logic
	);
end component;

signal mot : std_logic_vector(15 downto 0);
signal quartet : std_logic_vector(3 downto 0);
signal en_s, fin_s : std_logic;

begin

-- les 4 mots possibles : configuration, puis LSB et MSB de FREQ0
with SW(1 downto 0) select
	mot <= x"2200" when "00",  -- registre de controle : B28 = 1 (D13), PIN/SW = 1 (D9)
	       x"4000" when "01",  -- FREQ0, 14 LSB de W = 0
	       x"4100" when "10",  -- FREQ0, 14 MSB de W = 256 -> 1,09 MHz
	       x"4010" when others; -- FREQ0, 14 MSB de W = 16 -> 68 kHz

-- quartet affiche et octet qui le contient sur les leds
with SW(3 downto 2) select
	quartet <= mot(3 downto 0) when "00",
	           mot(7 downto 4) when "01",
	           mot(11 downto 8) when "10",
	           mot(15 downto 12) when others;

led <= mot(7 downto 0) when SW(3) = '0' else mot(15 downto 8);

-- decodage 7 segments (segment allume a '1')
with quartet select
	seg <= "0111111" when x"0",
	       "0000110" when x"1",
	       "1011011" when x"2",
	       "1001111" when x"3",
	       "1100110" when x"4",
	       "1101101" when x"5",
	       "1111101" when x"6",
	       "0000111" when x"7",
	       "1111111" when x"8",
	       "1101111" when x"9",
	       "1110111" when x"A",
	       "1111100" when x"B",
	       "0111001" when x"C",
	       "1011110" when x"D",
	       "1111001" when x"E",
	       "1110001" when others;

u_tx : spi_tx
	generic map (tscale => 20, N => 16)
	port map (clk => clk, en => en_s, data => mot, sclk => sclk, sdata => sdata, fin => fin_s);

u_fsm : fsm_spi
	port map (clk => clk, bouton => bouton, fin => fin_s, fsync => fsync, en => en_s);

reset <= '0'; -- RESET du DDS inactif

end architecture;
