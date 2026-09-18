-- SE Jully 2025
-- simple transfert of ADC to DAC
-- IN1 towards OUT1 at 125 MHz

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADC_DAC_channel1 is
Port ( adc_clk_p_i, adc_clk_n_i : in STD_LOGIC;
	   led_o : buffer STD_LOGIC_VECTOR (7 downto 0);
    	adc_dat_a_i : in std_logic_vector(13 downto 0);
    	adc_dat_b_i : in std_logic_vector(13 downto 0);
    
    --DAC signals
    dac_clk_o : out std_logic;
    dac_rst_o : out std_logic;
    dac_sel_o : out std_logic;
    dac_wrt_o : out std_logic;
    dac_dat_o : out std_logic_vector(13 downto 0)
    
    ); 
end ADC_DAC_channel1; 
 
architecture a of ADC_DAC_channel1 is
	signal div : integer range 0 to 7;
	signal clk125, clk_nobuf_s : std_logic;
	signal aclk : std_logic;
	signal dat_a_reg,dat_b_reg : std_logic_vector(13 downto 0);
	
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
    clk_inst: BUFG  PORT MAP(I=>clk_nobuf_s, O=>clk125);

	dac_clk_o <= not clk125;
	dac_wrt_o <= dac_clk_o;
	dac_rst_o <='0';
	dac_sel_o <='0'; -- output 1 (et non 2), contrairement à datasheet AD9767
    process
	begin
		wait until rising_edge (clk125);
		dac_dat_o <= adc_dat_a_i ; 
		led_o <=adc_dat_a_i(13 downto 6);
	end process;
 end a;   

