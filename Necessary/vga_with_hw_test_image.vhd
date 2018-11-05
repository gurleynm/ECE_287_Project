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

LIBRARY ieee;
USE ieee.std_logic_1164.all; 


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
		 ROWMOVERIGHT	 :	IN INTEGER;
		 ROWMOVELEFT	:	IN 	INTEGER;
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

SIGNAL	keys, key			 :	 STD_LOGIC;
SIGNAL	ROWMOVERIGHT 		 :	 INTEGER := 10;
SIGNAL	ROWMOVELEFT			 :	 INTEGER := 0;

BEGIN 

PROCESS(keys)
BEGIN

IF(keys = '0') THEN
	ROWMOVERIGHT <= ROWMOVERIGHT + 5;

END IF;
END PROCESS;

PROCESS(key)
BEGIN

IF(key = '0') THEN
	ROWMOVELEFT <= ROWMOVELEFT - 5;

END IF;
END PROCESS;


pixel_clk <= SYNTHESIZED_WIRE_3;
key<=SYNTHESIZED_WIRE_9;
keys<=SYNTHESIZED_WIRE_10;
SYNTHESIZED_WIRE_4 <= '1';
SYNTHESIZED_WIRE_5 <= '0';
SYNTHESIZED_WIRE_8 <= '0';


b2v_inst : hw_image_generator
GENERIC MAP(pixels_x => 478,
			pixels_y => 600
			)
PORT MAP(
		 ROWMOVERIGHT => ROWMOVERIGHT,
		 ROWMOVELEFT => ROWMOVELEFT,
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