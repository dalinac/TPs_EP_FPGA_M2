-- fsm_spi.vhd : machine de Moore qui gere FSYNC et autorise l'envoi par spi_tx quand on appuie sur le bouton

library ieee;
use ieee.std_logic_1164.all;

entity fsm_spi is
	port (
	clk : in std_logic;
	bouton : in std_logic;
	fin : in std_logic;   -- fin d'envoi donnee par spi_tx
	fsync : out std_logic;
	en : out std_logic    -- autorise spi_tx a envoyer
	);
end fsm_spi;

architecture a of fsm_spi is

type etat_t is (ATTENTE, DEBUT, ENVOI, FIN_ENVOI);
signal etat : etat_t := ATTENTE;

begin

process begin
	wait until rising_edge(clk);
	case etat is
		when ATTENTE =>
			if bouton = '1' then
				etat <= DEBUT;
			end if;
		when DEBUT =>  -- FSYNC a 0 pendant 1 periode d'horloge avant l'envoi
			etat <= ENVOI;
		when ENVOI =>
			if fin = '1' then
				etat <= FIN_ENVOI;
			end if;
		when FIN_ENVOI => -- on attend que le bouton soit relache
			if bouton = '0' then
				etat <= ATTENTE;
			end if;
	end case;
end process;

-- sorties de Moore : ne dependent que de l'etat
fsync <= '0' when (etat = DEBUT or etat = ENVOI) else '1';
en <= '1' when etat = ENVOI else '0';

end architecture;
