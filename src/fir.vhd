-- dds.vhd : synthetiseur numerique direct (DDS)
-- But : generer un sinus 14 bits non signe dont la frequence vaut
-- f_out = f_clk * W / 2**N et dont la phase est decalee de offset*2pi/1024


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
		if ena then
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
		       (sr(0) + sr(4))*b0 + 
		       (sr(1) + sr(3))*b1 + 
		       sr(2)*b2
		       , NF)(13 downto 0);
	end if;
	data_o <= std_logic_vector(sum);
end process;

end architecture;

