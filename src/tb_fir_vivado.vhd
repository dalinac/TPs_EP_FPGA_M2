----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2026 03:04:07 PM
-- Design Name: 
-- Module Name: tb_fir_vivado - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_fir_vivado is
--  Port ( );
end tb_fir_vivado;

architecture Behavioral of tb_fir_vivado is

    component design_1_wrapper is
      port (
        clk : in STD_LOGIC;
        data : in STD_LOGIC_VECTOR ( 13 downto 0 );
        data_o : out STD_LOGIC_VECTOR (13 downto 0 )
      );
    end component;

    constant CLK_PERIOD : time := 64 ns;       -- 15 MHz
	constant FS : real := 15.625e6;           -- 125/8 MHz

	signal clkt : std_logic := '0';
	signal xt : std_logic_vector(13 downto 0) := (others => '0');
	signal yt : std_logic_vector(13 downto 0);
	signal n : integer := 0;                  -- numero d'echantillon
	signal essai : integer := 1;

-- sinus non signe centre sur 8192, amplitude 8000
	function sinus(k : integer; f : real) return std_logic_vector is
		variable v : real;
	begin
		v := 4000.0*sin(2.0*MATH_PI*f*real(k)/FS);
		return std_logic_vector(to_unsigned(integer(v), 14));
	end function;

begin
    tb : design_1_wrapper
        port map (
		    clk => clkt,
		    data => xt,
		    data_o => yt
	);
	
	clk_process : process
	begin
	     clkt <= '0';
	     wait for CLK_PERIOD/2;
	     clkt <= '1';
	     wait for CLK_PERIOD/2;
	end process;

-- un nouvel echantillon a chaque validation
	stimuli : process(clkt)
	begin
		if rising_edge(clkt) then
				n <= n + 1;
				case essai is
					when 1 =>
						if n = 2 then xt <= std_logic_vector(to_unsigned(2**12, 14));
						else xt <= (others => '0'); end if;
					when 2 =>
						xt <= std_logic_vector(to_unsigned(4096, 14));
					when 3 =>
						xt <= sinus(n, 2.2e6);
					when others =>
						xt <= sinus(n, 6.0e6);
				end case;
		end if;
	end process;

	test : process
	begin

	-- t = 0 : impulsion
	essai <= 1;
	wait for 13 us;

	-- t = 2 us : echelon
	essai <= 2;
	wait for 13 us;

	-- t = 4 us : sinus a 1 MHz, dans la bande passante
	essai <= 3;
	wait for 50 us;

	-- t = 8 us : sinus a 6 MHz, hors bande
	essai <= 4;
	wait for 50 us;
	wait;
	end process;
end Behavioral;


-- coeffs filtre : 0.0039674077499581798,0.0082264532709624503,0.0076722928273722157,-0.002954502530884254,-0.021568117973937942,-0.03119951699619674,-0.011665550950779039,0.034355318247643214,0.070552343029577524,0.053812041249564666,-0.019496889893355566,-0.096256459249581011,-0.10627457219875026,-0.028702270082766376,0.080015242585829857,0.13053160563976465,0.080015242585829857,-0.028702270082766365,-0.10627457219875028,-0.096256459249581039,-0.019496889893355573,0.053812041249564686,0.07055234302957758,0.034355318247643221,-0.011665550950779043,-0.031199516996196733,-0.021568117973937938,-0.0029545025308842553,0.0076722928273722122,0.0082264532709624503,0.0039674077499581798 
