-- top_fir.vhdl : encapsulation du filtre passe-bas pour la red pitaya (openXC7)
-- But : IN1 -> filtre -> OUT1, et IN1 recopie brut sur OUT2 pour comparer
--       l'entree et la sortie directement a l'oscilloscope (mesure du gain)
-- Sequencement du DAC repris de ADC_DAC.vhd : la machine d'etats sur 8 cycles
-- fournit aclk (= '1' un cycle sur 8, soit fs = 15,625 MHz) qui sert de
-- validation au filtre, et pilote dac_clk_o / dac_wrt_o / dac_sel_o en mode
-- entrelace (etats 0 a 3 : voie B, etats 4 a 7 : voie A) comme le AD9767
-- Format : l'ADC code +1 V par 0 et -1 V par 2**14-1 en complement a 2 (bit 13
-- = signe). Le filtre travaille en non signe : sans conversion, le bit 13
-- bascule a chaque passage par 0 V et on voit un sinus tronque avec des
-- morceaux decales. Inverser le MSb fait passer du complement a 2 au binaire
-- decale (cela revient a ajouter 8192), a l'entree et a la sortie du filtre.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_fir is
port (
	adc_clk_p_i, adc_clk_n_i : in std_logic;
	led_o : out std_logic_vector(7 downto 0);
	adc_dat_a_i : in std_logic_vector(13 downto 0);
	adc_dat_b_i : in std_logic_vector(13 downto 0);
	--DAC signals
	dac_clk_o : out std_logic;
	dac_rst_o : out std_logic;
	dac_sel_o : out std_logic;
	dac_wrt_o : out std_logic;
	dac_dat_o : out std_logic_vector(13 downto 0)
	);
end top_fir;


architecture a of top_fir is

component fir is
	generic (
	W : integer := 14;
	b0 : integer := 18;
	b1 : integer := 123;
	b2 : integer := 230;
	NF : integer := 9
	);
	port (
	clk : in std_logic;
	ena : in std_logic;
	data_i : in std_logic_vector(W-1 downto 0);
	data_o : out std_logic_vector(W-1 downto 0)
	);
end component;

component IBUFDS is
   port(I, IB: IN std_logic;
	O : OUT std_logic);
end component;

component BUFG is
	port(I: IN std_logic;
	O : OUT std_logic);
end component;

signal div : integer range 0 to 7;
signal clk125, clk_nobuf_s : std_logic;
signal aclk : std_logic;                             -- validation a fs = 125/8 MHz
signal dat_a_reg, dat_b_reg : std_logic_vector(13 downto 0);
signal x_u, y_u : std_logic_vector(13 downto 0);     -- entree / sortie du filtre
signal y_dac : std_logic_vector(13 downto 0);        -- sortie remise au format DAC

begin

	clk_inst0: IBUFDS PORT MAP(I=>adc_clk_p_i, IB=>adc_clk_n_i, O=>clk_nobuf_s);
	clk_inst: BUFG PORT MAP(I=>clk_nobuf_s, O=>clk125);

-- complement a 2 -> non signe (inverser le MSb revient a ajouter 8192)
	x_u <= (not dat_a_reg(13)) & dat_a_reg(12 downto 0);

	u_fir : fir
	generic map (W => 14, b0 => 18, b1 => 123, b2 => 230, NF => 9)
	port map (clk => clk125, ena => aclk, data_i => x_u, data_o => y_u);

-- non signe -> complement a 2 pour le DAC (operation symetrique)
	y_dac <= (not y_u(13)) & y_u(12 downto 0);

sequencement:
process
begin
	wait until rising_edge(clk125);
		CASE div is
		WHEN 0 =>
			div <= 1;
			aclk <= '0';
			dac_wrt_o <= '0';
			dac_clk_o <= '0';
			dac_sel_o <= '1';
			dac_dat_o <= dat_a_reg;   -- voie B (OUT2) : entree non filtree
		WHEN 1 =>
			div <= 2;
			aclk <= '1';
			dac_wrt_o <= '1';
			dac_clk_o <= '1';
			dac_sel_o <= '1';
			dac_dat_o <= dat_a_reg;
		WHEN 2 =>
			div <= 3;
			aclk <= '0';
			dac_wrt_o <= '1';
			dac_clk_o <= '1';
			dac_sel_o <= '1';
			dac_dat_o <= dat_a_reg;
		WHEN 3 =>
			div <= 4;
			aclk <= '0';
			dac_wrt_o <= '0';
			dac_clk_o <= '0';
			dac_sel_o <= '1';
			dac_dat_o <= dat_a_reg;
		WHEN 4 =>
			div <= 5;
			aclk <= '0';
			dac_wrt_o <= '0';
			dac_clk_o <= '0';
			dac_sel_o <= '0';
			dac_dat_o <= y_dac;       -- voie A (OUT1) : signal filtre
		WHEN 5 =>
			div <= 6;
			aclk <= '0';
			dac_wrt_o <= '1';
			dac_clk_o <= '1';
			dac_sel_o <= '0';
			dac_dat_o <= y_dac;
		WHEN 6 =>
			div <= 7;
			aclk <= '0';
			dac_wrt_o <= '1';
			dac_clk_o <= '1';
			dac_sel_o <= '0';
			dac_dat_o <= y_dac;
		WHEN OTHERS =>
			div <= 0;
			aclk <= '0';
			dac_wrt_o <= '0';
			dac_clk_o <= '0';
			dac_sel_o <= '0';
			dac_dat_o <= y_dac;
		END CASE;

		if (aclk = '1') then	--else latch
			dat_a_reg <= adc_dat_a_i;
			dat_b_reg <= adc_dat_b_i;
		else
			dat_a_reg <= dat_a_reg;
			dat_b_reg <= dat_b_reg;
		end if;
end process;

	dac_rst_o <= '0';
	led_o <= y_u(13 downto 6);   -- visualisation du signal filtre

end a;
