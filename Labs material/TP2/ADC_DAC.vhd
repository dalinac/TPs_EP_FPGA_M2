-- SE oct 2024
-- simple transfert ADC vers DAC
-- pas de PLL donc divise avec compteur
-- aclk à 125/8 MHz et dac_clk à 125/4 MHz
-- cf. timing fig66 AD9767

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADC_DAC is
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
end ADC_DAC; 
 
architecture a of ADC_DAC is
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

      process
      begin
          wait until rising_edge (clk125);
              CASE div is
              WHEN 0 =>
              	div <= 1;
				aclk <='0';
				dac_wrt_o <= '0'; 
				dac_clk_o <= '0';
				dac_sel_o <= '1';
				dac_dat_o <= dat_b_reg;
              WHEN 1 =>
              	div <= 2;
				aclk <='1';
				dac_wrt_o <= '1'; 
				dac_clk_o <= '1';
				dac_sel_o <= '1';
				dac_dat_o <= dat_b_reg;
              WHEN 2 =>
              	div <= 3;
				aclk <='0';
				dac_wrt_o <= '1'; 
				dac_clk_o <= '1';
				dac_sel_o <= '1';
				dac_dat_o <= dat_b_reg;
              WHEN 3 =>
              	div <= 4;
				aclk <='0';
				dac_wrt_o <= '0'; 
				dac_clk_o <= '0';
				dac_sel_o <= '1';
				dac_dat_o <= dat_b_reg;	
              WHEN 4 =>
              	div <= 5;
				aclk <='0';
				dac_wrt_o <= '0'; 
				dac_clk_o <= '0';
				dac_sel_o <= '0';
				dac_dat_o <= dat_a_reg;
              WHEN 5 =>
              	div <= 6;
				aclk <='0';
				dac_wrt_o <= '1'; 
				dac_clk_o <= '1';
				dac_sel_o <= '0';
				dac_dat_o <= dat_a_reg;
              WHEN 6 =>
              	div <= 7;
				aclk <='0';
				dac_wrt_o <= '1'; 
				dac_clk_o <= '1';
				dac_sel_o <= '0';
				dac_dat_o <= dat_a_reg;
              WHEN OTHERS =>
              	div <= 0;
				aclk <='0';
				dac_wrt_o <= '0'; 
				dac_clk_o <= '0';
				dac_sel_o <= '0';
				dac_dat_o <= dat_a_reg;
			END CASE;
			
			if (aclk = '1')	then	--else latch	
	      		dat_a_reg <= adc_dat_a_i ;
	      		dat_b_reg <= adc_dat_b_i ;
	      	else
	      		dat_a_reg <= dat_a_reg ;
	      		dat_b_reg <= dat_b_reg ;	      	
	      	end if;
      end process;
      dac_rst_o <='0';
	  led_o <=adc_dat_b_i(13 downto 6);
 end a;   

