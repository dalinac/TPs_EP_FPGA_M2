-- spi_tx.vhd : envoie N bits sur SDATA (MSb en premier) avec SCLK = clk/tscale, fin passe a 1 quand tout est envoye

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_tx is
	generic (
	tscale : integer range 3 to 1000 := 20; -- division de l'horloge pour SCLK
	N : integer range 1 to 32 := 16         -- nombre de bits a envoyer
	);
	port (
	clk : in std_logic;
	en : in std_logic; -- '1' : envoi, '0' : remise a zero (SCLK = 1, compteurs a 0)
	data : in std_logic_vector(N-1 downto 0);
	sclk : out std_logic;
	sdata : out std_logic;
	fin : out std_logic
	);
end spi_tx;

architecture a of spi_tx is

signal cpt_div : integer range 0 to tscale-1 := 0; -- diviseur de frequence
signal cpt_bit : integer range 0 to N := 0;        -- numero du bit en cours

begin

process begin
	wait until rising_edge(clk);

	-- compteurs
	if en = '0' then
		cpt_div <= 0;
		cpt_bit <= 0;
	elsif cpt_bit < N then
		if cpt_div = tscale-1 then
			cpt_div <= 0;
			cpt_bit <= cpt_bit + 1;
		else
			cpt_div <= cpt_div + 1;
		end if;
	end if;

	-- sorties deduites des compteurs : SCLK a 1 sur la 1re moitie de la periode, a 0 sur la 2e
	if en = '1' and cpt_bit < N and cpt_div >= tscale/2 then
		sclk <= '0';
	else
		sclk <= '1';
	end if;

	-- le bit change en meme temps que le front montant de SCLK
	if cpt_bit < N then
		sdata <= data(N-1-cpt_bit);
	else
		sdata <= '0';
	end if;

	if en = '1' and cpt_bit = N then
		fin <= '1';
	else
		fin <= '0';
	end if;
end process;

end architecture;
