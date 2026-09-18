-- tb_dds.vhd :test du DDS
-- ce qu'il faut simuler : 
-- essai 1 : W = 1 : periode = 1024 cycles = 8,192 us (deux periodes affichees)
-- essai 2 : W = 10 : periode = 102,4 cycles = 819,2 ns
-- essai 3 : meme W, offset = 256 : saut de phase de +90 degres, frequence inchangée 
-- essai 4 : offset = 512 : saut de 180 degres

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dds is
end tb_dds;


architecture sim of tb_dds is
	component dds is
		generic (N : integer := 10);
		
		port (
		clk : in std_logic;
		W : in std_logic_vector(N-1 downto 0);
		offset : in std_logic_vector(9 downto 0);
		s : out std_logic_vector(13 downto 0)
		);
	end component;
	
	constant CLK_PERIOD : time := 8 ns; -- 125 MHz
	signal clkt    : STD_LOGIC := '0';
	signal Wt : std_logic_vector(9 downto 0) := (others => '0');
	signal offsett : std_logic_vector(9 downto 0) := (others => '0');
	signal st : std_logic_vector(13 downto 0);
	
-- conversion entier -> vecteur 10 bits (lisibilite)
	function v10(x : integer) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(x, 10));
	end function;
	
begin 
	tb  : dds
		port map (
		    clk     => clkt,
		    W 	    => Wt, 
		    offset  => offsett, 
		    s       => st
        );
        
        clk_process : process 
        begin
	     clkt <= '0';
	     wait for CLK_PERIOD/2;
	     clkt <= '1';
	     wait for CLK_PERIOD/2;
	end process;

	test : process 
	begin 

	Wt <= v10(1);
	wait for 2*1024*CLK_PERIOD;

	Wt <= v10(10);
	wait for 2 us;

	offsett <= v10(256);
	wait for 2 us;

	offsett <= v10(512);
	wait for 2 us;
	wait;
	end process;
end sim;
		
        
        
	
