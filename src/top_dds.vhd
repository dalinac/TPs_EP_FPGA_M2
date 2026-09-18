-- top_dds.vhd : encapsulation du DDS pour la Red Pitaya (flot openXC7)


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_dds is
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


architecture a of top_dds is
component dds is
	generic (N : integer := 10);
	port (
	clk : in std_logic;
	W : in std_logic_vector(N-1 downto 0);
	offset : in std_logic_vector(9 downto 0);
	s : out std_logic_vector(13 downto 0)
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

signal W_s : std_logic_vector(9 downto 0);
signal s_dds : std_logic_vector(13 downto 0);

begin

	clk_inst0: IBUFDS PORT MAP(I=>adc_clk_p_i,IB =>adc_clk_n_i,O =>clk_nobuf_s);
	clk_inst: BUFG PORT MAP(I=>clk_nobuf_s, O=>clk125); 
	
	
	W_s <= SW & GPIO & "00";
	
	u_dds : dds
	generic map (N => 10)
	port map (clk => clk125, W => W_s, offset => (others => '0'), s => s_dds);
	
	dac_clk_o <= not clk125;
	dac_wrt_o <= dac_clk_o;
	dac_rst_o <= '0';
	dac_sel_o <= '0';      -- sortie OUT1
	
	process
	begin
		wait until rising_edge(clk125);
		dac_dat_o <= s_dds;
		led_o     <= SW & GPIO;   -- permet de verifier le sens des interrupteurs
	end process;
	
	

end a;
	
