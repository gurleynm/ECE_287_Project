-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"
-- CREATED		"Sun Nov 04 15:55:27 2018"

LIBRARY IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.my_types_pkg.all;

ENTITY vga_with_hw_test_image IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
		ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
		pixel_clk :  OUT  STD_LOGIC;
		h_sync :  OUT  STD_LOGIC;
		v_sync :  OUT  STD_LOGIC;
		n_blank :  OUT  STD_LOGIC;
		n_sync :  OUT  STD_LOGIC;
		blue :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		green :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		red :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END vga_with_hw_test_image;

ARCHITECTURE bdf_type OF vga_with_hw_test_image IS 

COMPONENT hw_image_generator
GENERIC (pixels_x : INTEGER;
			pixels_y : INTEGER
			);
	PORT(
		 ROWMOVERIGHT	:	IN INTEGER;
		 ROWMOVELEFT	:	IN INTEGER;
		 GRAVITY			:  IN	INTEGER;
		 SPOT			:	IN		HOLDER(0 TO 8, 0 TO 12);
		 disp_ena : IN STD_LOGIC;
		 column : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 row : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 red : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT vga_controller
GENERIC (h_bp : INTEGER;
			h_fp : INTEGER;
			h_pixels : INTEGER;
			h_pol : STD_LOGIC;
			h_pulse : INTEGER;
			v_bp : INTEGER;
			v_fp : INTEGER;
			v_pixels : INTEGER;
			v_pol : STD_LOGIC;
			v_pulse : INTEGER
			);
	PORT(pixel_clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 h_sync : OUT STD_LOGIC;
		 v_sync : OUT STD_LOGIC;
		 disp_ena : OUT STD_LOGIC;
		 n_blank : OUT STD_LOGIC;
		 n_sync : OUT STD_LOGIC;
		 column : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 row : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT altpll0
	PORT(inclk0 : IN STD_LOGIC;
		 areset : IN STD_LOGIC;
		 c0 : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT ps2_keyboard_to_ascii IS
  GENERIC(
      clk_freq                  : INTEGER := 50_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 8);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
		TESTa, TESTd : OUT STD_LOGIC); --ASCII value
END COMPONENT ps2_keyboard_to_ascii;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :	 STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :	 STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :	 STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :	 STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10:	 STD_LOGIC;

SIGNAL	key1, key			 :	 STD_LOGIC;
SIGNAL	ROWMOVERIGHT 		 :	 INTEGER := 755;
SIGNAL	ROWMOVELEFT			 :	 INTEGER := 0;
SIGNAL   GRAVITY				 :	 INTEGER := 0;
SIGNAL	COUNTER				 :	 STD_LOGIC_VECTOR(31 DOWNTO 0);
TYPE	LOWES IS ARRAY (0 TO 12) OF INTEGER;
SIGNAL LOWEST					 :	 LOWES:=(OTHERS=>0);

SIGNAL addrV 					 :  Integer range 0 to 12;
SIGNAL addrH 					 :  Integer range 0 to 8;
SIGNAL SPOT 					 : holder (0 TO 8,0 TO 12):=(OTHERS=>(OTHERS=>'0'));

BEGIN 
PROCESS(clk, key, key1)
BEGIN
If clk'event and clk = '1' then
	if counter < "10111110101111000010000" then 
		counter<= counter +1;
	else		
		IF(GRAVITY MOD 60 = 0) THEN
			addrV <= GRAVITY/60;
		END IF;
		
		IF((ROWMOVELEFT + ROWMOVERIGHT-575) MOD 60 = 0) THEN
			addrH <= (ROWMOVELEFT + ROWMOVERIGHT - 575) / 60;
		END IF;
	
		IF((GRAVITY MOD 60 = 0 AND SPOT(addrH, GRAVITY/60)='1') OR GRAVITY = 720) THEN
			SPOT(addrH,addrV) <= '1';
			LOWEST(addrH) <= addrV;
			GRAVITY <= 60;
		ELSE
			if(SPOT(0, 11)='1' AND  SPOT(1, 11)='1' AND  SPOT(2, 11)='1' AND  SPOT(3, 11)='1' AND  SPOT(4, 11)='1' AND  SPOT(5, 11)='1' AND  SPOT(6, 11)='1' AND  SPOT(7, 11)='1' AND  SPOT(8, 11)='1')then
				SPOT(0, LOWEST(0))<='0';
				SPOT(1, LOWEST(1))<='0';
				SPOT(2, LOWEST(2))<='0';
				SPOT(3, LOWEST(3))<='0';
				SPOT(4, LOWEST(4))<='0';
				SPOT(5, LOWEST(5))<='0';
				SPOT(6, LOWEST(6))<='0';
				SPOT(7, LOWEST(7))<='0';
				SPOT(8, LOWEST(8))<='0';
				
				LOWEST(0) <= LOWEST(0) + 1;
				LOWEST(1) <= LOWEST(1) + 1;
				LOWEST(2) <= LOWEST(2) + 1;
				LOWEST(3) <= LOWEST(3) + 1;
				LOWEST(4) <= LOWEST(4) + 1;
				LOWEST(5) <= LOWEST(5) + 1;
				LOWEST(6) <= LOWEST(6) + 1;
				LOWEST(7) <= LOWEST(7) + 1;
				LOWEST(8) <= LOWEST(8) + 1;
			end if;
			GRAVITY <= GRAVITY + 30;
		END IF;
		
		counter <= (others => '0');
	end if;
end if;

END PROCESS;

PROCESS(key1)
BEGIN

IF(key1 = '0') THEN
	
	IF(ROWMOVELEFT + ROWMOVERIGHT + 60 > 1114) THEN
		ROWMOVERIGHT <= 1115 - ROWMOVELEFT-60;
	ELSIF(SPOT(addrH+1,addrV)='1' OR SPOT(addrH+2,addrV)='1') THEN
		ROWMOVERIGHT <= ROWMOVERIGHT;
	ELSE
		ROWMOVERIGHT <= ROWMOVERIGHT + 60;
	END IF;
END IF;
END PROCESS;

PROCESS(key)
BEGIN

IF(key = '0') THEN
	IF(ROWMOVELEFT + ROWMOVERIGHT < 576) THEN
		ROWMOVELEFT <= 575 - ROWMOVERIGHT;
	ELSIF(SPOT(addrH-1,addrV)='1' OR SPOT(addrH-2,addrV)='1') THEN
		ROWMOVELEFT <= ROWMOVELEFT;
	ELSE
		ROWMOVELEFT <= ROWMOVELEFT - 60;
	END IF;
END IF;
END PROCESS;


pixel_clk <= SYNTHESIZED_WIRE_3;
key<=SYNTHESIZED_WIRE_9;
key1<=SYNTHESIZED_WIRE_10;
SYNTHESIZED_WIRE_4 <= '1';
SYNTHESIZED_WIRE_5 <= '0';
SYNTHESIZED_WIRE_8 <= '0';


b2v_inst : hw_image_generator
GENERIC MAP(pixels_x => 60,
			pixels_y => 60
			)
PORT MAP(
		 ROWMOVERIGHT => ROWMOVERIGHT,
		 ROWMOVELEFT => ROWMOVELEFT,
		 GRAVITY => GRAVITY,
		 SPOT=>SPOT,
		 disp_ena => SYNTHESIZED_WIRE_0,
		 column => SYNTHESIZED_WIRE_1,
		 row => SYNTHESIZED_WIRE_2,
		 blue => blue,
		 green => green,
		 red => red);


b2v_inst1 : vga_controller
GENERIC MAP(h_bp => 148,
			h_fp => 88,
			h_pixels => 1920,
			h_pol => '0',
			h_pulse => 44,
			v_bp => 36,
			v_fp => 4,
			v_pixels => 1080,
			v_pol => '1',
			v_pulse => 5
			)
PORT MAP(pixel_clk => SYNTHESIZED_WIRE_3,
		 reset_n => SYNTHESIZED_WIRE_4,
		 h_sync => h_sync,
		 v_sync => v_sync,
		 disp_ena => SYNTHESIZED_WIRE_0,
		 n_blank => n_blank,
		 n_sync => n_sync,
		 column => SYNTHESIZED_WIRE_2,
		 row => SYNTHESIZED_WIRE_1);


b2v_inst2 : altpll0
PORT MAP(inclk0 => clk,
		 areset => SYNTHESIZED_WIRE_5,
		 c0 => SYNTHESIZED_WIRE_3);

b2v_inst3 : ps2_keyboard_to_ascii
PORT MAP(clk=>clk, ps2_clk=>ps2_clk, ps2_data=>ps2_data, ascii_new =>SYNTHESIZED_WIRE_8, TESTa=>SYNTHESIZED_WIRE_9, TESTd=>SYNTHESIZED_WIRE_10);


END bdf_type;