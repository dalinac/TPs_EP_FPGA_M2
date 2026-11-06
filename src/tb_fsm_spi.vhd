-- tb_fsm_spi.vhd : simulation de la machine de Moore seule (fin est imite par le testbench)

library ieee;
use ieee.std_logic_1164.all;

entity tb_fsm_spi is
end tb_fsm_spi;

architecture a of tb_fsm_spi is

component fsm_spi is
	port (
	clk : in std_logic;
	bouton : in std_logic;
	fin : in std_logic;
	fsync : out std_logic;
	en : out std_logic
	);
end component;

constant PERIOD : time := 8 ns;

signal clkt : std_logic := '0';
signal boutont, fint : std_logic := '0';
signal fsynct, ent : std_logic;

begin

u : fsm_spi port map (clk => clkt, bouton => boutont, fin => fint, fsync => fsynct, en => ent);

clk_process : process
begin
	clkt <= '0';
	wait for PERIOD/2;
	clkt <= '1';
	wait for PERIOD/2;
end process;

-- imite spi_tx : fin passe a 1 200 ns apres le debut de l'envoi, et revient a 0 quand en = 0
fin_process : process
begin
	wait until ent = '1';
	wait for 200 ns;
	wait until rising_edge(clkt);
	fint <= '1';
	wait until ent = '0';
	wait until rising_edge(clkt);
	fint <= '0';
end process;

stimuli : process
begin
	-- appui long : le bouton est relache apres la fin de l'envoi
	wait for 48 ns;
	boutont <= '1';
	wait for 496 ns;
	boutont <= '0';
	-- appui court : le bouton est relache avant la fin de l'envoi
	wait for 200 ns;
	boutont <= '1';
	wait for 48 ns;
	boutont <= '0';
	wait;
end process;

end architecture;
