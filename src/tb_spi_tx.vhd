-- tb_spi_tx.vhd : simulation de spi_tx (envoi de 0x2200 puis 0x4100, et un 2e cas avec tscale = 5 et N = 8)

library ieee;
use ieee.std_logic_1164.all;

entity tb_spi_tx is
end tb_spi_tx;

architecture a of tb_spi_tx is

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

constant PERIOD : time := 8 ns; -- 125 MHz

signal clkt : std_logic := '0';
signal ent : std_logic := '0';
signal datat : std_logic_vector(15 downto 0) := x"2200";
signal sclkt, sdatat, fint : std_logic;
-- 2e instance : autres valeurs des parametres
signal data8t : std_logic_vector(7 downto 0) := x"A5";
signal sclk8t, sdata8t, fin8t : std_logic;

begin

u1 : spi_tx
	generic map (tscale => 20, N => 16)
	port map (clk => clkt, en => ent, data => datat, sclk => sclkt, sdata => sdatat, fin => fint);

u2 : spi_tx
	generic map (tscale => 5, N => 8)
	port map (clk => clkt, en => ent, data => data8t, sclk => sclk8t, sdata => sdata8t, fin => fin8t);

clk_process : process
begin
	clkt <= '0';
	wait for PERIOD/2;
	clkt <= '1';
	wait for PERIOD/2;
end process;

stimuli : process
begin
	-- 1er envoi : 0x2200
	ent <= '0';
	wait for 96 ns;
	ent <= '1';
	wait for 3 us;
	-- remise a zero puis 2e envoi : 0x4100
	ent <= '0';
	datat <= x"4100";
	wait for 200 ns;
	ent <= '1';
	wait for 3 us;
	ent <= '0';
	wait;
end process;

end architecture;
