library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY VGA IS
PORT(
CLOCK_24: IN STD_LOGIC_VECTOR(1 downto 0);
pixel_clk : OUT STD_LOGIC;
VGA_HS,VGA_VS:OUT STD_LOGIC;
SW: STD_LOGIC_VECTOR(1 downto 0);
KEY: STD_LOGIC_VECTOR(3 DOWNTO 0);
VGA_R,VGA_B,VGA_G: OUT STD_LOGIC_VECTOR(3 downto 0)
);
END VGA;


ARCHITECTURE MAIN OF VGA IS 

 COMPONENT SYNC IS
 PORT(
	CLK: IN STD_LOGIC;
	HSYNC: OUT STD_LOGIC;
	VSYNC: OUT STD_LOGIC;
	R: OUT STD_LOGIC_VECTOR(3 downto 0);
	G: OUT STD_LOGIC_VECTOR(3 downto 0);
	B: OUT STD_LOGIC_VECTOR(3 downto 0);
	KEYS: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
   S: IN STD_LOGIC_VECTOR(1 downto 0)
	);
END COMPONENT SYNC;

COMPONENT altpll0 IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0				: OUT STD_LOGIC);
END COMPONENT altpll0;

SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL 	SYNTHESIZED_WIRE_5 :  STD_LOGIC;

 BEGIN
 synTHESIZED_WIRE_5 <= '0';
 pixel_clk <= SYNTHESIZED_WIRE_3;
 
 
 C1: altpll0 PORT MAP (areset => SYNTHESIZED_WIRE_5, inclk0 => CLOCK_24(0), c0 => SYNTHESIZED_WIRE_3);
 C: SYNC PORT MAP(SYNTHESIZED_WIRE_3,VGA_HS,VGA_VS,VGA_R,VGA_G,VGA_B,KEY,SW);
 
 END MAIN;