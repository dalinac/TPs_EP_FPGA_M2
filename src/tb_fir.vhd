-- tb_fir.vhd : test du filtre passe-bas
-- ce qu'il faut simuler :
-- essai 1 : impulsion -> on relit les coefficients : y = 16383*b_i/512
-- essai 2 : echelon -> gain continu = 1, la sortie rejoint l'entree
-- essai 3 : sinus a 1 MHz (dans la bande) -> amplitude quasi inchangee
-- essai 4 : sinus a 6 MHz (hors bande) -> amplitude fortement attenuee

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_fir is
end tb_fir;


architecture sim of tb_fir is
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

	constant CLK_PERIOD : time := 8 ns;       -- 125 MHz
	constant FS : real := 15.625e6;           -- 125/8 MHz

	signal clkt : std_logic := '0';
	signal enat : std_logic := '0';
	signal xt : std_logic_vector(13 downto 0) := (others => '0');
	signal yt : std_logic_vector(13 downto 0);
	signal n : integer := 0;                  -- numero d'echantillon
	signal essai : integer := 1;

-- sinus non signe centre sur 8192, amplitude 8000
	function sinus(k : integer; f : real) return std_logic_vector is
		variable v : real;
	begin
		v := 8192.0 + 8000.0*sin(2.0*MATH_PI*f*real(k)/FS);
		return std_logic_vector(to_unsigned(integer(v), 14));
	end function;

begin
	tb : fir
		port map (
		    clk    => clkt,
		    ena    => enat,
		    data_i => xt,
		    data_o => yt
	);

	clk_process : process
	begin
	     clkt <= '0';
	     wait for CLK_PERIOD/2;
	     clkt <= '1';
	     wait for CLK_PERIOD/2;
	end process;

-- validation 1 cycle sur 8 : fs = 15,625 MHz avec une seule horloge
	ena_process : process(clkt)
		variable cpt : integer range 0 to 7 := 0;
	begin
		if rising_edge(clkt) then
			if cpt = 7 then
				enat <= '1';
				cpt := 0;
			else
				enat <= '0';
				cpt := cpt + 1;
			end if;
		end if;
	end process;

-- un nouvel echantillon a chaque validation
	stimuli : process(clkt)
	begin
		if rising_edge(clkt) then
			if enat = '1' then
				n <= n + 1;
				case essai is
					when 1 =>
						if n = 2 then xt <= std_logic_vector(to_unsigned(16383, 14));
						else xt <= (others => '0'); end if;
					when 2 =>
						xt <= std_logic_vector(to_unsigned(10000, 14));
					when 3 =>
						xt <= sinus(n, 1.0e6);
					when others =>
						xt <= sinus(n, 6.0e6);
				end case;
			end if;
		end if;
	end process;

	test : process
	begin

	-- t = 0 : impulsion
	essai <= 1;
	wait for 2 us;

	-- t = 2 us : echelon
	essai <= 2;
	wait for 2 us;

	-- t = 4 us : sinus a 1 MHz, dans la bande passante
	essai <= 3;
	wait for 4 us;

	-- t = 8 us : sinus a 6 MHz, hors bande
	essai <= 4;
	wait for 4 us;
	wait;
	end process;
end sim;
