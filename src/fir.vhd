-- fir.vhdl : filtre RIF (FIR) passe-bas d'ordre 4

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
signal p0, p1, p2 : unsigned(2*W+1 downto 0);

begin 


process begin
	wait until rising_edge(clk);

	-- ligne a retard : avance d'un echantillon quand ena = '1'
	if ena = '1' then
		sr(0) <= unsigned(data_i); 
		sr(1) <= sr(0);
		sr(2) <= sr(1);
		sr(3) <= sr(2);
		sr(4) <= sr(3);
	end if;

	-- produits (structure repliee)
	p0 <= (resize(sr(0), W+1) + resize(sr(4), W+1))*b0;
	p1 <= (resize(sr(1), W+1) + resize(sr(3), W+1))*b1;
	p2 <= resize(sr(2), W+1)*b2;

	-- somme et division par 2**NF
	sum <= shift_right(p0 + p1 + p2, NF)(13 downto 0);
end process;

data_o <= std_logic_vector(sum);

end architecture;

