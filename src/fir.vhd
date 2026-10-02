-- fir.vhdl : filtre RIF (FIR) passe-bas d'ordre 4
-- But : calculer y(n) = somme(b_i * x(n-i)) / 2**NF avec des coefficients entiers
-- Structure repliee du cours : le filtre etant symetrique (b4=b0, b3=b1), on additionne d'abord les echantillons de meme coefficient, ce qui ramene le nombre de multiplieurs de 5 a 3



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir is
	generic (
	W : integer := 14;
	b0 : integer := 0;
	b1 : integer := 0;
	b2 : integer := 0;
	NF : integer := 9
	);

	port (
	clk : in std_logic; -- horloge maitre (15.625MHz)
	ena : in std_logic;
	data_i : in std_logic_vector(W-1 downto 0);
	data_o : out std_logic_vector(W-1 downto 0)
	);
end fir;

architecture a of fir is 


type fir_state_t is array (0 to 4) of unsigned(13 downto 0);

signal sr: fir_state_t;
signal sum: unsigned(13 downto 0);

begin 

shift_register: 
process(clk) begin 
	if rising_edge(clk) then
		if ena = '1' then
			sr(0) <= unsigned(data_i); 
			sr(1) <= sr(0);
			sr(2) <= sr(1);
			sr(3) <= sr(2);
			sr(4) <= sr(3);
		end if;
	end if;
end process;

comp_sum:
process(clk) begin
	if rising_edge(clk) then
		sum <= shift_right(
		       (resize(sr(0), W+1) + resize(sr(4), W+1))*b0 + 
			       (resize(sr(1), W+1) + resize(sr(3), W+1))*b1 + 
			       resize(sr(2), W+1)*b2
			       , NF)(13 downto 0) ;
	end if;
end process;

data_o <= std_logic_vector(sum(W-1 downto 0));

end architecture;

