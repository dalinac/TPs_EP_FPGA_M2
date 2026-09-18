-- dds.vhd : synthetiseur numerique direct (DDS)
-- But : generer un sinus 14 bits non signe dont la frequence vaut
-- f_out = f_clk * W / 2**N et dont la phase est decalee de offset*2pi/1024


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dds is
	generic (
	N : integer := 10 -- >= PHASE_TRUNC_WIDTH, >= 10
	);

	port (
	clk : in std_logic; -- horloge maitre (125MHz)
	W : in std_logic_vector(N-1 downto 0); -- increment de phase (phase_delta)
	offset : in std_logic_vector(9 downto 0); -- decalage de phase (1024 <-> 2pi)
	s : out std_logic_vector(13 downto 0) 
	);
end dds;

architecture a of dds is 

type ram_t is array (0 to 1023) of integer range 0 to 2**14-1;
constant RAM : ram_t := ( x"0",x"65",x"c9",x"12e",x"192",x"1f7",x"25b",x"2c0",x"324",x"388",x"3ed",x"451",x"4b5",x"51a",x"57e",x"5e2",x"646",x"6aa",x"70e",x"772",x"7d6",x"839",x"89d",x"901",x"964",x"9c7",x"a2b",x"a8e",x"af1",x"b54",x"bb7",x"c1a",x"c7c",x"cdf",x"d41",x"da4",x"e06",x"e68",x"eca",x"f2b",x"f8d",x"fee",x"1050",x"10b1",x"1112",x"1173",x"11d3",x"1234",x"1294",x"12f4",x"1354",x"13b4",x"1413",x"1473",x"14d2",x"1531",x"1590",x"15ee",x"164c",x"16ab",x"1709",x"1766",x"17c4",x"1821",x"187e",x"18db",x"1937",x"1993",x"19ef",x"1a4b",x"1aa7",x"1b02",x"1b5d",x"1bb8",x"1c12",x"1c6c",x"1cc6",x"1d20",x"1d79",x"1dd3",x"1e2b",x"1e84",x"1edc",x"1f34",x"1f8c",x"1fe3",x"203a",x"2091",x"20e7",x"213d",x"2193",x"21e8",x"223d",x"2292",x"22e7",x"233b",x"238e",x"23e2",x"2435",x"2488",x"24da",x"252c",x"257e",x"25cf",x"2620",x"2671",x"26c1",x"2711",x"2760",x"27af",x"27fe",x"284c",x"289a",x"28e7",x"2935",x"2981",x"29ce",x"2a1a",x"2a65",x"2ab0",x"2afb",x"2b45",x"2b8f",x"2bd8",x"2c21",x"2c6a",x"2cb2",x"2cfa",x"2d41",x"2d88",x"2dcf",x"2e15",x"2e5a",x"2e9f",x"2ee4",x"2f28",x"2f6c",x"2faf",x"2ff2",x"3034",x"3076",x"30b8",x"30f9",x"3139",x"3179",x"31b9",x"31f8",x"3236",x"3274",x"32b2",x"32ef",x"332c",x"3368",x"33a3",x"33df",x"3419",x"3453",x"348d",x"34c6",x"34ff",x"3537",x"356e",x"35a5",x"35dc",x"3612",x"3648",x"367d",x"36b1",x"36e5",x"3718",x"374b",x"377e",x"37b0",x"37e1",x"3812",x"3842",x"3871",x"38a1",x"38cf",x"38fd",x"392b",x"3958",x"3984",x"39b0",x"39db",x"3a06",x"3a30",x"3a59",x"3a82",x"3aab",x"3ad3",x"3afa",x"3b21",x"3b47",x"3b6d",x"3b92",x"3bb6",x"3bda",x"3bfd",x"3c20",x"3c42",x"3c64",x"3c85",x"3ca5",x"3cc5",x"3ce4",x"3d03",x"3d21",x"3d3f",x"3d5b",x"3d78",x"3d93",x"3daf",x"3dc9",x"3de3",x"3dfc",x"3e15",x"3e2d",x"3e45",x"3e5c",x"3e72",x"3e88",x"3e9d",x"3eb1",x"3ec5",x"3ed8",x"3eeb",x"3efd",x"3f0f",x"3f20",x"3f30",x"3f40",x"3f4f",x"3f5d",x"3f6b",x"3f78",x"3f85",x"3f91",x"3f9c",x"3fa7",x"3fb1",x"3fbb",x"3fc4",x"3fcc",x"3fd4",x"3fdb",x"3fe1",x"3fe7",x"3fec",x"3ff1",x"3ff5",x"3ff8",x"3ffb",x"3ffd",x"3fff",x"4000",x"4000",x"4000",x"3fff",x"3ffd",x"3ffb",x"3ff8",x"3ff5",x"3ff1",x"3fec",x"3fe7",x"3fe1",x"3fdb",x"3fd4",x"3fcc",x"3fc4",x"3fbb",x"3fb1",x"3fa7",x"3f9c",x"3f91",x"3f85",x"3f78",x"3f6b",x"3f5d",x"3f4f",x"3f40",x"3f30",x"3f20",x"3f0f",x"3efd",x"3eeb",x"3ed8",x"3ec5",x"3eb1",x"3e9d",x"3e88",x"3e72",x"3e5c",x"3e45",x"3e2d",x"3e15",x"3dfc",x"3de3",x"3dc9",x"3daf",x"3d93",x"3d78",x"3d5b",x"3d3f",x"3d21",x"3d03",x"3ce4",x"3cc5",x"3ca5",x"3c85",x"3c64",x"3c42",x"3c20",x"3bfd",x"3bda",x"3bb6",x"3b92",x"3b6d",x"3b47",x"3b21",x"3afa",x"3ad3",x"3aab",x"3a82",x"3a59",x"3a30",x"3a06",x"39db",x"39b0",x"3984",x"3958",x"392b",x"38fd",x"38cf",x"38a1",x"3871",x"3842",x"3812",x"37e1",x"37b0",x"377e",x"374b",x"3718",x"36e5",x"36b1",x"367d",x"3648",x"3612",x"35dc",x"35a5",x"356e",x"3537",x"34ff",x"34c6",x"348d",x"3453",x"3419",x"33df",x"33a3",x"3368",x"332c",x"32ef",x"32b2",x"3274",x"3236",x"31f8",x"31b9",x"3179",x"3139",x"30f9",x"30b8",x"3076",x"3034",x"2ff2",x"2faf",x"2f6c",x"2f28",x"2ee4",x"2e9f",x"2e5a",x"2e15",x"2dcf",x"2d88",x"2d41",x"2cfa",x"2cb2",x"2c6a",x"2c21",x"2bd8",x"2b8f",x"2b45",x"2afb",x"2ab0",x"2a65",x"2a1a",x"29ce",x"2981",x"2935",x"28e7",x"289a",x"284c",x"27fe",x"27af",x"2760",x"2711",x"26c1",x"2671",x"2620",x"25cf",x"257e",x"252c",x"24da",x"2488",x"2435",x"23e2",x"238e",x"233b",x"22e7",x"2292",x"223d",x"21e8",x"2193",x"213d",x"20e7",x"2091",x"203a",x"1fe3",x"1f8c",x"1f34",x"1edc",x"1e84",x"1e2b",x"1dd3",x"1d79",x"1d20",x"1cc6",x"1c6c",x"1c12",x"1bb8",x"1b5d",x"1b02",x"1aa7",x"1a4b",x"19ef",x"1993",x"1937",x"18db",x"187e",x"1821",x"17c4",x"1766",x"1709",x"16ab",x"164c",x"15ee",x"1590",x"1531",x"14d2",x"1473",x"1413",x"13b4",x"1354",x"12f4",x"1294",x"1234",x"11d3",x"1173",x"1112",x"10b1",x"1050",x"fee",x"f8d",x"f2b",x"eca",x"e68",x"e06",x"da4",x"d41",x"cdf",x"c7c",x"c1a",x"bb7",x"b54",x"af1",x"a8e",x"a2b",x"9c7",x"964",x"901",x"89d",x"839",x"7d6",x"772",x"70e",x"6aa",x"646",x"5e2",x"57e",x"51a",x"4b5",x"451",x"3ed",x"388",x"324",x"2c0",x"25b",x"1f7",x"192",x"12e",x"c9",x"65",x"0",x"3f9b",x"3f37",x"3ed2",x"3e6e",x"3e09",x"3da5",x"3d40",x"3cdc",x"3c78",x"3c13",x"3baf",x"3b4b",x"3ae6",x"3a82",x"3a1e",x"39ba",x"3956",x"38f2",x"388e",x"382a",x"37c7",x"3763",x"36ff",x"369c",x"3639",x"35d5",x"3572",x"350f",x"34ac",x"3449",x"33e6",x"3384",x"3321",x"32bf",x"325c",x"31fa",x"3198",x"3136",x"30d5",x"3073",x"3012",x"2fb0",x"2f4f",x"2eee",x"2e8d",x"2e2d",x"2dcc",x"2d6c",x"2d0c",x"2cac",x"2c4c",x"2bed",x"2b8d",x"2b2e",x"2acf",x"2a70",x"2a12",x"29b4",x"2955",x"28f7",x"289a",x"283c",x"27df",x"2782",x"2725",x"26c9",x"266d",x"2611",x"25b5",x"2559",x"24fe",x"24a3",x"2448",x"23ee",x"2394",x"233a",x"22e0",x"2287",x"222d",x"21d5",x"217c",x"2124",x"20cc",x"2074",x"201d",x"1fc6",x"1f6f",x"1f19",x"1ec3",x"1e6d",x"1e18",x"1dc3",x"1d6e",x"1d19",x"1cc5",x"1c72",x"1c1e",x"1bcb",x"1b78",x"1b26",x"1ad4",x"1a82",x"1a31",x"19e0",x"198f",x"193f",x"18ef",x"18a0",x"1851",x"1802",x"17b4",x"1766",x"1719",x"16cb",x"167f",x"1632",x"15e6",x"159b",x"1550",x"1505",x"14bb",x"1471",x"1428",x"13df",x"1396",x"134e",x"1306",x"12bf",x"1278",x"1231",x"11eb",x"11a6",x"1161",x"111c",x"10d8",x"1094",x"1051",x"100e",x"fcc",x"f8a",x"f48",x"f07",x"ec7",x"e87",x"e47",x"e08",x"dca",x"d8c",x"d4e",x"d11",x"cd4",x"c98",x"c5d",x"c21",x"be7",x"bad",x"b73",x"b3a",x"b01",x"ac9",x"a92",x"a5b",x"a24",x"9ee",x"9b8",x"983",x"94f",x"91b",x"8e8",x"8b5",x"882",x"850",x"81f",x"7ee",x"7be",x"78f",x"75f",x"731",x"703",x"6d5",x"6a8",x"67c",x"650",x"625",x"5fa",x"5d0",x"5a7",x"57e",x"555",x"52d",x"506",x"4df",x"4b9",x"493",x"46e",x"44a",x"426",x"403",x"3e0",x"3be",x"39c",x"37b",x"35b",x"33b",x"31c",x"2fd",x"2df",x"2c1",x"2a5",x"288",x"26d",x"251",x"237",x"21d",x"204",x"1eb",x"1d3",x"1bb",x"1a4",x"18e",x"178",x"163",x"14f",x"13b",x"128",x"115",x"103",x"f1",x"e0",x"d0",x"c0",x"b1",x"a3",x"95",x"88",x"7b",x"6f",x"64",x"59",x"4f",x"45",x"3c",x"34",x"2c",x"25",x"1f",x"19",x"14",x"f",x"b",x"8",x"5",x"3",x"1",x"0",x"0",x"0",x"1",x"3",x"5",x"8",x"b",x"f",x"14",x"19",x"1f",x"25",x"2c",x"34",x"3c",x"45",x"4f",x"59",x"64",x"6f",x"7b",x"88",x"95",x"a3",x"b1",x"c0",x"d0",x"e0",x"f1",x"103",x"115",x"128",x"13b",x"14f",x"163",x"178",x"18e",x"1a4",x"1bb",x"1d3",x"1eb",x"204",x"21d",x"237",x"251",x"26d",x"288",x"2a5",x"2c1",x"2df",x"2fd",x"31c",x"33b",x"35b",x"37b",x"39c",x"3be",x"3e0",x"403",x"426",x"44a",x"46e",x"493",x"4b9",x"4df",x"506",x"52d",x"555",x"57e",x"5a7",x"5d0",x"5fa",x"625",x"650",x"67c",x"6a8",x"6d5",x"703",x"731",x"75f",x"78f",x"7be",x"7ee",x"81f",x"850",x"882",x"8b5",x"8e8",x"91b",x"94f",x"983",x"9b8",x"9ee",x"a24",x"a5b",x"a92",x"ac9",x"b01",x"b3a",x"b73",x"bad",x"be7",x"c21",x"c5d",x"c98",x"cd4",x"d11",x"d4e",x"d8c",x"dca",x"e08",x"e47",x"e87",x"ec7",x"f07",x"f48",x"f8a",x"fcc",x"100e",x"1051",x"1094",x"10d8",x"111c",x"1161",x"11a6",x"11eb",x"1231",x"1278",x"12bf",x"1306",x"134e",x"1396",x"13df",x"1428",x"1471",x"14bb",x"1505",x"1550",x"159b",x"15e6",x"1632",x"167f",x"16cb",x"1719",x"1766",x"17b4",x"1802",x"1851",x"18a0",x"18ef",x"193f",x"198f",x"19e0",x"1a31",x"1a82",x"1ad4",x"1b26",x"1b78",x"1bcb",x"1c1e",x"1c72",x"1cc5",x"1d19",x"1d6e",x"1dc3",x"1e18",x"1e6d",x"1ec3",x"1f19",x"1f6f",x"1fc6",x"201d",x"2074",x"20cc",x"2124",x"217c",x"21d5",x"222d",x"2287",x"22e0",x"233a",x"2394",x"23ee",x"2448",x"24a3",x"24fe",x"2559",x"25b5",x"2611",x"266d",x"26c9",x"2725",x"2782",x"27df",x"283c",x"289a",x"28f7",x"2955",x"29b4",x"2a12",x"2a70",x"2acf",x"2b2e",x"2b8d",x"2bed",x"2c4c",x"2cac",x"2d0c",x"2d6c",x"2dcc",x"2e2d",x"2e8d",x"2eee",x"2f4f",x"2fb0",x"3012",x"3073",x"30d5",x"3136",x"3198",x"31fa",x"325c",x"32bf",x"3321",x"3384",x"33e6",x"3449",x"34ac",x"350f",x"3572",x"35d5",x"3639",x"369c",x"36ff",x"3763",x"37c7",x"382a",x"388e",x"38f2",x"3956",x"39ba",x"3a1e",x"3a82",x"3ae6",x"3b4b",x"3baf",x"3c13",x"3c78",x"3cdc",x"3d40",x"3da5",x"3e09",x"3e6e",x"3ed2",x"3f37",x"3f9b"
);


signal phase_acc : unsigned(N-1 downto 0) := (others => '0');
signal addr : unsigned(9 downto 0);
signal sinus : integer range 0 to 2**14-1 := 0;

begin 

phase_acc_register: 
process(clk) 
	begin 
	if rising_edge(clk) then 
	acc <= acc + unsigned(W);
	end if 
end process 


