-- dds.vhd : synthetiseur numerique direct (DDS)
-- But : generer un sinus 14 bits non signe dont la frequence vaut
-- f_out = f_clk * W / 2**N et dont la phase est decalee de offset*2pi/1024


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir is
	generic (
	W : integer := 14
	);

	port (
	clk : in std_logic; -- horloge maitre (15.625MHz)
	data_i : in std_logic_vector(W-1 downto 0);
	data_o : out std_logic_vector(W-1 downto 0)
	);
end fir;

architecture a of fir is 


type fir_state_t is array (0 to 3) of unsigned(13 downto 0);
type fir_coefs_t is array (0 to 3) of unsigned(7 downto 0);

constant coefs: fir_coefs_t := (x"0c", x"74", x"74", x"0c");
signal sr: fir_state_t;
signal sum: unsigned(13 downto 0);

begin 

shift_register: 
process(clk) begin 
	if rising_edge(clk) then
		sr(0) <= unsigned(data_i); 
		sr(1) <= sr(0);
		sr(2) <= sr(1);
		sr(3) <= sr(2);
	end if;
end process;

comp_sum:
process(clk) begin
	if rising_edge(clk) then
		sum <= (
		       sr(0)*coefs(0) + 
		       sr(1)*coefs(1) + 
		       sr(2)*coefs(2) + 
		       sr(3)*coefs(3)
	       );
	end if;
	data_o <= std_logic_vector(sum);
end process;

end architecture;

