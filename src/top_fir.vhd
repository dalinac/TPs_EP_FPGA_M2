-- top_dds.vhd : encapsulation du DDS pour la Red Pitaya (flot openXC7)


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_fir is
port (
	adc_clk_p_i, adc_clk_n_i : in std_logic; 
	SW : in std_logic_vector(3 downto 0);
	GPIO : in std_logic_vector(3 downto 0);
	led_o : out std_logic_vector(7 downto 0);           
	--DAC signals
	dac_clk_o : out std_logic;
	dac_rst_o : out std_logic;
	dac_sel_o : out std_logic;
	dac_wrt_o : out std_logic;
	dac_dat_o : out std_logic_vector(13 downto 0)
	);
end top_dds;


architecture a of top_fir is
component fir is
	generic (
	W : integer := 14
	);

	port (
	clk : in std_logic; -- horloge maitre (15.625MHz)
	data_i : in std_logic_vector(W-1 downto 0);
	data_o : out std_logic_vector(W-1 downto 0)
	);
end component;

signal clk125, clk_nobuf_s : std_logic;

component IBUFDS is
   port(I, IB: IN std_logic;
	O : OUT std_logic);
end component;

component BUFG is
	port(I: IN std_logic;
	O : OUT std_logic);
end component;

begin
	clk_inst0: IBUFDS PORT MAP(I=>adc_clk_p_i,IB =>adc_clk_n_i,O =>clk_nobuf_s);
	clk_inst: BUFG PORT MAP(I=>clk_nobuf_s, O=>clk125); 
	
	
	
	u_fir : fir		
	generic map (W => 14)
	port map (
		);
	
	dac_clk_o <= not clk125;
	dac_wrt_o <= dac_clk_o;
	dac_rst_o <= '0';
	dac_sel_o <= '0';      -- sortie OUT1
	
	process
	begin
		wait until rising_edge(clk125);
		dac_dat_o <= s_dds;
	end process;
	
	

end a;
	
