-- tb_spi_dds.vhd : simulation de l'assemblage (switches, bouton, spi_tx et fsm_spi) : envoi de 0x2200, 0x4000 puis 0x4100

library ieee;
use ieee.std_logic_1164.all;

entity tb_spi_dds is
end tb_spi_dds;

architecture a of tb_spi_dds is

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

constant PERIOD : time := 8 ns;

signal clkt : std_logic := '0';
signal SWt : std_logic_vector(3 downto 0) := "0000";
signal boutont : std_logic := '0';
signal ledt : std_logic_vector(7 downto 0);
signal segt : std_logic_vector(6 downto 0);
signal sdatat, sclkt, fsynct, resett : std_logic;

begin

u : spi_dds port map (clk => clkt, SW => SWt, bouton => boutont, led => ledt, seg => segt,
	sdata => sdatat, sclk => sclkt, fsync => fsynct, reset => resett);

clk_process : process
begin
	clkt <= '0';
	wait for PERIOD/2;
	clkt <= '1';
	wait for PERIOD/2;
end process;

stimuli : process
begin
	-- mot 0x2200 (SW = 00), quartet 0 affiche
	SWt <= "0000";
	wait for 96 ns;
	boutont <= '1';
	wait for 4 us;
	boutont <= '0';
	wait for 1 us;
	-- mot 0x4000 (SW = 01), quartet 3 affiche (4)
	SWt <= "1101";
	wait for 96 ns;
	boutont <= '1';
	wait for 4 us;
	boutont <= '0';
	wait for 1 us;
	-- mot 0x4100 (SW = 10), quartet 2 affiche (1)
	SWt <= "1010";
	wait for 96 ns;
	boutont <= '1';
	wait for 4 us;
	boutont <= '0';
	wait;
end process;

end architecture;
