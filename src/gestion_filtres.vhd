-- gestion_filtres.vhd : partie 4 du TP2

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gestion_filtres is
	port (
	clk : in std_logic; 
	sel : in std_logic; -- bit 0 du GPIO
	adc_a : in std_logic_vector(13 downto 0); -- voie A de l'ADC (complement a 2)
	pbas_in : out std_logic_vector(13 downto 0); -- vers l'entree de fir (non signe)
	pbas_out : in std_logic_vector(13 downto 0); -- sortie de fir (non signe)
	pbande_out : in std_logic_vector(13 downto 0); -- sortie du FIR Compiler, bits 22 a 9
	dac : out std_logic_vector(31 downto 0) 
	);
end gestion_filtres;

architecture a of gestion_filtres is

signal pbas_s : std_logic_vector(13 downto 0); -- passe-bas remis en complement a 2
signal voie_a, voie_b : std_logic_vector(13 downto 0);

begin

pbas_in <= (not adc_a(13)) & adc_a(12 downto 0);
pbas_s <= (not pbas_out(13)) & pbas_out(12 downto 0);

process begin
	wait until rising_edge(clk);
	if sel = '0' then
		voie_a <= pbas_s;
		voie_b <= pbande_out;
	else
		voie_a <= pbande_out;
		voie_b <= pbas_s;
	end if;
end process;

-- 16 MSb = voie B, 16 LSb = voie A, les 2 MSb de chaque moitie recopient le bit de signe
dac <= voie_b(13) & voie_b(13) & voie_b & voie_a(13) & voie_a(13) & voie_a;

end architecture;
