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
use ieee.std_logic_arith.all;
use ieee.math_real.all;
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
		red :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		SCORE : OUT	STD_LOGIC_VECTOR(0 TO 6);
		HIGHSCORE :	OUT std_logic_vector(0 TO 6);
		ZERO : OUT	STD_LOGIC_VECTOR(0 TO 6);
		HIGHSCORELEFT :	OUT std_logic_vector(0 TO 6)
		
	);
END vga_with_hw_test_image;

ARCHITECTURE bdf_type OF vga_with_hw_test_image IS 

COMPONENT hw_image_generator
	PORT(
		 pixels_y		:	IN	INTEGER;    --row that first color will persist until
		 pixels_x		:	IN	INTEGER;
		 ROWMOVERIGHT	:	IN INTEGER;
		 ROWMOVELEFT	:	IN INTEGER;
		 GRAVITY			:  IN	INTEGER;
		 SPOT				:	IN		HOLDER(0 TO 8, 0 TO 12);
		 color			:	IN	STD_LOGIC;
		 disp_ena		:	IN STD_LOGIC;
		 column			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 row 				: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 blue 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 green 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 red 				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Lab5part2 IS
	PORT ( p, q, r, s		:IN STD_LOGIC ;
			a,b,c,d,e,f,g			:OUT STD_LOGIC );
	
END COMPONENT Lab5part2;


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
		TESTa, TESTd, TESTs, TESTr : OUT STD_LOGIC); --ASCII value
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
SIGNAL	SYNTHESIZED_WIRE_11:	 STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_12:	 STD_LOGIC;

SIGNAL	key3, key2, key1, key			 :	 STD_LOGIC;
SIGNAL	ROWMOVERIGHT 		 :	 INTEGER := 755;
SIGNAL	ROWMOVELEFT			 :	 INTEGER := 0;
SIGNAL   GRAVITY				 :	 INTEGER := 0;
SIGNAL	COUNTER				 :	 STD_LOGIC_VECTOR(31 DOWNTO 0);
TYPE	LOWES IS ARRAY (0 TO 12) OF INTEGER;
SIGNAL LOWEST					 :	 LOWES:=(OTHERS=>0);
SIGNAL	SZ						 :	 INTEGER:=60;

SIGNAL addrV 					 :  Integer range 0 to 12;
SIGNAL addrH 					 :  Integer range 0 to 8;
SIGNAL SPOT 					 :	 holder (0 TO 8,0 TO 12):=(OTHERS=>(OTHERS=>'0'));
SIGNAL SWIT						 :	 STD_LOGIC:='0';
SIGNAL RAND						 :	 STD_LOGIC:='0';
SIGNAL TIM						 :	 STD_LOGIC_VECTOR(25 DOWNTO 0):="00010111110101111000010000"; --1/8 SECOND
SIGNAL ZEROS					 :	 STD_LOGIC_VECTOR(0 TO 6):="0000001";
SIGNAL NOVALUE					 :	 STD_LOGIC_VECTOR(0 TO 3):="0000";
SIGNAL SCOR						 :	 std_logic_vector(0 to 3);
SIGNAL HIGHSCOR				 :	 std_logic_vector(0 to 3);
SIGNAL INCREASE				 :	 std_logic_vector(0 to 3);
SIGNAL SHAPE					 :	 STD_LOGIC:='0';
SIGNAL NOMOVE					 :	 sTD_LOGIC:='0';
SIGNAL LEVELUP					 :	 STD_LOGIC_VECTOR(25 DOWNTO 0):="00000000000000000000000000";

BEGIN 



PROCESS(clk, key2)
BEGIN
IF(SPOT(0,1)='1' OR SPOT(1,1)='1' OR SPOT(2,1)='1' OR SPOT(3,1)='1' OR SPOT(4,1)='1' OR SPOT(5,1)='1' OR SPOT(6,1)='1' OR SPOT(7,1)='1' OR SPOT(8,1)='1')THEN
	RAND <= RAND;
	IF(key2 = '1')THEN
		SPOT <= (OTHERS=> (OTHERS =>'0'));
		SCOR <= "0000";
		NOVALUE <= "0000";
		LEVELUP <= "00000000000000000000000000";
	ELSE
		RAND <= RAND;
	END IF;
ELSE
If clk'event and clk = '1' then

	if counter < TIM then 
		counter<= counter +1;
		IF(SWIT = '0' AND NOMOVE = '0') THEN
			SWIT <= '1';
			RAND <= NOT RAND;
			if(addrH = 8 OR addrH = 7) then
				SHAPE <= '1';
			else
				SHAPE <= NOT SHAPE;
			end if;
		END IF;
		IF(SHAPE = '0')THEN
			SZ <= 180;
		ELSE
			SZ <= 60;
		END IF;
	else		
		IF(GRAVITY MOD 60 = 0) THEN
			addrV <= GRAVITY/60;
		END IF;
		
		IF((ROWMOVELEFT + ROWMOVERIGHT-575) MOD 60 = 0) THEN
			addrH <= (ROWMOVELEFT + ROWMOVERIGHT - 575) / 60;
		END IF;
	
		IF(SHAPE='1' AND ((GRAVITY MOD 60 = 0 AND SPOT(addrH, GRAVITY/60)='1') OR GRAVITY = 720)) THEN
			SPOT(addrH,addrV) <= '1';
			LOWEST(addrH) <= addrV;
			SWIT <= '0';
			GRAVITY <= 60;
		ELSIF(SHAPE='0' AND ((GRAVITY MOD 60 = 0 AND (SPOT(addrH, GRAVITY/60)='1' OR SPOT(addrH+1, GRAVITY/60)='1' OR SPOT(addrH+2, GRAVITY/60)='1')) OR GRAVITY = 720)) THEN
			SPOT(addrH,addrV) <= '1';
			SPOT(addrH+1,addrV) <= '1';
			SPOT(addrH+2,addrV) <= '1';
			LOWEST(addrH) <= addrV;
			LOWEST(addrH+1) <= addrV;
			LOWEST(addrH+2) <= addrV;
			SWIT <= '0';
			GRAVITY <= 60;
		ELSE
			if((SPOT(0, 11)='1' AND  SPOT(1, 11)='1' AND  SPOT(2, 11)='1' AND  SPOT(3, 11)='1' AND  SPOT(4, 11)='1' AND  SPOT(5, 11)='1' AND  SPOT(6, 11)='1' AND  SPOT(7, 11)='1' AND  SPOT(8, 11)='1') OR
				(SPOT(0, 10)='1' AND  SPOT(1, 10)='1' AND  SPOT(2, 10)='1' AND  SPOT(3, 10)='1' AND  SPOT(4, 10)='1' AND  SPOT(5, 10)='1' AND  SPOT(6, 10)='1' AND  SPOT(7, 10)='1' AND  SPOT(8, 10)='1') OR
				(SPOT(0, 9)='1' AND  SPOT(1, 9)='1' AND  SPOT(2, 9)='1' AND  SPOT(3, 9)='1' AND  SPOT(4, 9)='1' AND  SPOT(5, 9)='1' AND  SPOT(6, 9)='1' AND  SPOT(7, 9)='1' AND  SPOT(8, 9)='1') OR
				(SPOT(0, 8)='1' AND  SPOT(1, 8)='1' AND  SPOT(2, 8)='1' AND  SPOT(3, 8)='1' AND  SPOT(4, 8)='1' AND  SPOT(5, 8)='1' AND  SPOT(6, 8)='1' AND  SPOT(7, 8)='1' AND  SPOT(8, 8)='1') OR
				(SPOT(0, 7)='1' AND  SPOT(1, 7)='1' AND  SPOT(2, 7)='1' AND  SPOT(3, 7)='1' AND  SPOT(4, 7)='1' AND  SPOT(5, 7)='1' AND  SPOT(6, 7)='1' AND  SPOT(7, 7)='1' AND  SPOT(8, 7)='1') OR
				(SPOT(0, 6)='1' AND  SPOT(1, 6)='1' AND  SPOT(2, 6)='1' AND  SPOT(3, 6)='1' AND  SPOT(4, 6)='1' AND  SPOT(5, 6)='1' AND  SPOT(6, 6)='1' AND  SPOT(7, 6)='1' AND  SPOT(8, 6)='1') OR
				(SPOT(0, 5)='1' AND  SPOT(1, 5)='1' AND  SPOT(2, 5)='1' AND  SPOT(3, 5)='1' AND  SPOT(4, 5)='1' AND  SPOT(5, 5)='1' AND  SPOT(6, 5)='1' AND  SPOT(7, 5)='1' AND  SPOT(8, 5)='1') OR
				(SPOT(0, 4)='1' AND  SPOT(1, 4)='1' AND  SPOT(2, 4)='1' AND  SPOT(3, 4)='1' AND  SPOT(4, 4)='1' AND  SPOT(5, 4)='1' AND  SPOT(6, 4)='1' AND  SPOT(7, 4)='1' AND  SPOT(8, 4)='1'))then
				
				IF(SCOR = "1111")THEN
					NOVALUE <= NOVALUE + 1;
				END IF;
				SCOR <= SCOR +1;
				IF(SCOR = "0100" OR SCOR = "1000" OR SCOR = "1100" OR (NOVALUE > "0000" AND SCOR = "0000"))THEN
					LEVELUP <= LEVELUP + "00000101111101011110000100";
				END IF;
				
				IF(SCOR >= HIGHSCOR)THEN
					IF(HIGHSCOR = "1111")THEN
						INCREASE <= INCREASE + 1;
					END IF;
					HIGHSCOR <= HIGHSCOR + 1;
				ELSE
					HIGHSCOR <= HIGHSCOR;
				END IF;
				
				IF(SPOT(0, 11)='1' AND  SPOT(1, 11)='1' AND  SPOT(2, 11)='1' AND  SPOT(3, 11)='1' AND  SPOT(4, 11)='1' AND  SPOT(5, 11)='1' AND  SPOT(6, 11)='1' AND  SPOT(7, 11)='1' AND  SPOT(8, 11)='1')THEN
					IF(SPOT(0, 10) = '1')THEN
						sPOT(0,11) <='1';
					ELSE
						sPOT(0,11) <='0';
					END IF;
					
					IF(SPOT(1, 10) = '1')THEN
						sPOT(1,11) <='1';
					ELSE
						sPOT(1,11) <='0';
					END IF;
					
					IF(SPOT(2, 10) = '1')THEN
						sPOT(2,11) <='1';
					ELSE
						sPOT(2,11) <='0';
					END IF;
					
					IF(SPOT(3, 10) = '1')THEN
						sPOT(3,11) <='1';
					ELSE
						sPOT(3,11) <='0';
					END IF;
					
					IF(SPOT(4, 10) = '1')THEN
						sPOT(4,11) <='1';
					ELSE
						sPOT(4,11) <='0';
					END IF;
					
					IF(SPOT(5, 10) = '1')THEN
						sPOT(5,11) <='1';
					ELSE
						sPOT(5,11) <='0';
					END IF;
					
					IF(SPOT(6, 10) = '1')THEN
						sPOT(6,11) <='1';
					ELSE
						sPOT(6,11) <='0';
					END IF;
					
					IF(SPOT(7, 10) = '1')THEN
						sPOT(7,11) <='1';
					ELSE
						sPOT(7,11) <='0';
					END IF;
					
					IF(SPOT(8, 10) = '1')THEN
						sPOT(8,11) <='1';
					ELSE
						sPOT(8,11) <='0';
					END IF;
					---------------------------------------Defined 11
					IF(SPOT(0, 9) = '1')THEN
						sPOT(0,10) <='1';
					ELSE
						sPOT(0,10) <='0';
					END IF;
					
					IF(SPOT(1, 9) = '1')THEN
						sPOT(1,10) <='1';
					ELSE
						sPOT(1,10) <='0';
					END IF;
					
					IF(SPOT(2, 9) = '1')THEN
						sPOT(2,10) <='1';
					ELSE
						sPOT(2,10) <='0';
					END IF;
					
					IF(SPOT(3, 9) = '1')THEN
						sPOT(3,10) <='1';
					ELSE
						sPOT(3,10) <='0';
					END IF;
					
					IF(SPOT(4, 9) = '1')THEN
						sPOT(4,10) <='1';
					ELSE
						sPOT(4,10) <='0';
					END IF;
					
					IF(SPOT(5, 9) = '1')THEN
						sPOT(5,10) <='1';
					ELSE
						sPOT(5,10) <='0';
					END IF;
					
					IF(SPOT(6, 9) = '1')THEN
						sPOT(6,10) <='1';
					ELSE
						sPOT(6,10) <='0';
					END IF;
					
					IF(SPOT(7, 9) = '1')THEN
						sPOT(7,10) <='1';
					ELSE
						sPOT(7,10) <='0';
					END IF;
					
					IF(SPOT(8, 9) = '1')THEN
						sPOT(8,10) <='1';
					ELSE
						sPOT(8,10) <='0';
					END IF;
					---------------------------------------Defined 10
					IF(SPOT(0, 8) = '1')THEN
						sPOT(0,9) <='1';
					ELSE
						sPOT(0,9) <='0';
					END IF;
					
					IF(SPOT(1, 8) = '1')THEN
						sPOT(1,9) <='1';
					ELSE
						sPOT(1,9) <='0';
					END IF;
					
					IF(SPOT(2, 8) = '1')THEN
						sPOT(2,9) <='1';
					ELSE
						sPOT(2,9) <='0';
					END IF;
					
					IF(SPOT(3, 8) = '1')THEN
						sPOT(3,9) <='1';
					ELSE
						sPOT(3,9) <='0';
					END IF;
					
					IF(SPOT(4, 8) = '1')THEN
						sPOT(4,9) <='1';
					ELSE
						sPOT(4,9) <='0';
					END IF;
					
					IF(SPOT(5, 8) = '1')THEN
						sPOT(5,9) <='1';
					ELSE
						sPOT(5,9) <='0';
					END IF;
					
					IF(SPOT(6, 8) = '1')THEN
						sPOT(6,9) <='1';
					ELSE
						sPOT(6,9) <='0';
					END IF;
					
					IF(SPOT(7, 8) = '1')THEN
						sPOT(7,9) <='1';
					ELSE
						sPOT(7,9) <='0';
					END IF;
					
					IF(SPOT(8, 8) = '1')THEN
						sPOT(8,9) <='1';
					ELSE
						sPOT(8,9) <='0';
					END IF;
					---------------------------------------Defined 9
					IF(SPOT(0, 7) = '1')THEN
						sPOT(0,8) <='1';
					ELSE
						sPOT(0,8) <='0';
					END IF;
					
					IF(SPOT(1, 7) = '1')THEN
						sPOT(1,8) <='1';
					ELSE
						sPOT(1,8) <='0';
					END IF;
					
					IF(SPOT(2, 7) = '1')THEN
						sPOT(2,8) <='1';
					ELSE
						sPOT(2,8) <='0';
					END IF;
					
					IF(SPOT(3, 7) = '1')THEN
						sPOT(3,8) <='1';
					ELSE
						sPOT(3,8) <='0';
					END IF;
					
					IF(SPOT(4, 7) = '1')THEN
						sPOT(4,8) <='1';
					ELSE
						sPOT(4,8) <='0';
					END IF;
					
					IF(SPOT(5, 7) = '1')THEN
						sPOT(5,8) <='1';
					ELSE
						sPOT(5,8) <='0';
					END IF;
					
					IF(SPOT(6, 7) = '1')THEN
						sPOT(6,8) <='1';
					ELSE
						sPOT(6,8) <='0';
					END IF;
					
					IF(SPOT(7, 7) = '1')THEN
						sPOT(7,8) <='1';
					ELSE
						sPOT(7,8) <='0';
					END IF;
					
					IF(SPOT(8, 7) = '1')THEN
						sPOT(8,8) <='1';
					ELSE
						sPOT(8,8) <='0';
					END IF;
					---------------------------------------Defined 8
					IF(SPOT(0, 6) = '1')THEN
						sPOT(0,7) <='1';
					ELSE
						sPOT(0,7) <='0';
					END IF;
					
					IF(SPOT(1, 6) = '1')THEN
						sPOT(1,7) <='1';
					ELSE
						sPOT(1,7) <='0';
					END IF;
					
					IF(SPOT(2, 6) = '1')THEN
						sPOT(2,7) <='1';
					ELSE
						sPOT(2,7) <='0';
					END IF;
					
					IF(SPOT(3, 6) = '1')THEN
						sPOT(3,7) <='1';
					ELSE
						sPOT(3,7) <='0';
					END IF;
					
					IF(SPOT(4, 6) = '1')THEN
						sPOT(4,7) <='1';
					ELSE
						sPOT(4,7) <='0';
					END IF;
					
					IF(SPOT(5, 6) = '1')THEN
						sPOT(5,7) <='1';
					ELSE
						sPOT(5,7) <='0';
					END IF;
					
					IF(SPOT(6, 6) = '1')THEN
						sPOT(6,7) <='1';
					ELSE
						sPOT(6,7) <='0';
					END IF;
					
					IF(SPOT(7, 6) = '1')THEN
						sPOT(7,7) <='1';
					ELSE
						sPOT(7,7) <='0';
					END IF;
					
					IF(SPOT(8, 6) = '1')THEN
						sPOT(8,7) <='1';
					ELSE
						sPOT(8,7) <='0';
					END IF;
					---------------------------------------Defined 7
					IF(SPOT(0, 5) = '1')THEN
						sPOT(0,6) <='1';
					ELSE
						sPOT(0,6) <='0';
					END IF;
					
					IF(SPOT(1, 5) = '1')THEN
						sPOT(1,6) <='1';
					ELSE
						sPOT(1,6) <='0';
					END IF;
					
					IF(SPOT(2, 5) = '1')THEN
						sPOT(2,6) <='1';
					ELSE
						sPOT(2,6) <='0';
					END IF;
					
					IF(SPOT(3, 5) = '1')THEN
						sPOT(3,6) <='1';
					ELSE
						sPOT(3,6) <='0';
					END IF;
					
					IF(SPOT(4, 5) = '1')THEN
						sPOT(4,6) <='1';
					ELSE
						sPOT(4,6) <='0';
					END IF;
					
					IF(SPOT(5, 5) = '1')THEN
						sPOT(5,6) <='1';
					ELSE
						sPOT(5,6) <='0';
					END IF;
					
					IF(SPOT(6, 5) = '1')THEN
						sPOT(6,6) <='1';
					ELSE
						sPOT(6,6) <='0';
					END IF;
					
					IF(SPOT(7, 5) = '1')THEN
						sPOT(7,6) <='1';
					ELSE
						sPOT(7,6) <='0';
					END IF;
					
					IF(SPOT(8, 5) = '1')THEN
						sPOT(8,6) <='1';
					ELSE
						sPOT(8,6) <='0';
					END IF;
					---------------------------------------Defined 6
					IF(SPOT(0, 4) = '1')THEN
						sPOT(0,5) <='1';
					ELSE
						sPOT(0,5) <='0';
					END IF;
					
					IF(SPOT(1, 4) = '1')THEN
						sPOT(1,5) <='1';
					ELSE
						sPOT(1,5) <='0';
					END IF;
					
					IF(SPOT(2, 4) = '1')THEN
						sPOT(2,5) <='1';
					ELSE
						sPOT(2,5) <='0';
					END IF;
					
					IF(SPOT(3, 4) = '1')THEN
						sPOT(3,5) <='1';
					ELSE
						sPOT(3,5) <='0';
					END IF;
					
					IF(SPOT(4, 4) = '1')THEN
						sPOT(4,5) <='1';
					ELSE
						sPOT(4,5) <='0';
					END IF;
					
					IF(SPOT(5, 4) = '1')THEN
						sPOT(5,5) <='1';
					ELSE
						sPOT(5,5) <='0';
					END IF;
					
					IF(SPOT(6, 4) = '1')THEN
						sPOT(6,5) <='1';
					ELSE
						sPOT(6,5) <='0';
					END IF;
					
					IF(SPOT(7, 4) = '1')THEN
						sPOT(7,5) <='1';
					ELSE
						sPOT(7,5) <='0';
					END IF;
					
					IF(SPOT(8, 4) = '1')THEN
						sPOT(8,5) <='1';
					ELSE
						sPOT(8,5) <='0';
					END IF;
					---------------------------------------Defined 5
					IF(SPOT(0, 3) = '1')THEN
						sPOT(0,4) <='1';
					ELSE
						sPOT(0,4) <='0';
					END IF;
					
					IF(SPOT(1, 3) = '1')THEN
						sPOT(1,4) <='1';
					ELSE
						sPOT(1,4) <='0';
					END IF;
					
					IF(SPOT(2, 3) = '1')THEN
						sPOT(2,4) <='1';
					ELSE
						sPOT(2,4) <='0';
					END IF;
					
					IF(SPOT(3, 3) = '1')THEN
						sPOT(3,4) <='1';
					ELSE
						sPOT(3,4) <='0';
					END IF;
					
					IF(SPOT(4, 3) = '1')THEN
						sPOT(4,4) <='1';
					ELSE
						sPOT(4,4) <='0';
					END IF;
					
					IF(SPOT(5, 3) = '1')THEN
						sPOT(5,4) <='1';
					ELSE
						sPOT(5,4) <='0';
					END IF;
					
					IF(SPOT(6, 3) = '1')THEN
						sPOT(6,4) <='1';
					ELSE
						sPOT(6,4) <='0';
					END IF;
					
					IF(SPOT(7, 3) = '1')THEN
						sPOT(7,4) <='1';
					ELSE
						sPOT(7,4) <='0';
					END IF;
					
					IF(SPOT(8, 3) = '1')THEN
						sPOT(8,4) <='1';
					ELSE
						sPOT(8,4) <='0';
					END IF;
					---------------------------------------Defined 4
					IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
				END IF;
				-------------------------------------------------------Line 11 deleted
				IF(SPOT(0, 10)='1' AND  SPOT(1, 10)='1' AND  SPOT(2, 10)='1' AND  SPOT(3, 10)='1' AND  SPOT(4, 10)='1' AND  SPOT(5, 10)='1' AND  SPOT(6, 10)='1' AND  SPOT(7, 10)='1' AND  SPOT(8, 10)='1')THEN
					IF(SPOT(0, 9) = '1')THEN
						sPOT(0,10) <='1';
					ELSE
						sPOT(0,10) <='0';
					END IF;
					
					IF(SPOT(1, 9) = '1')THEN
						sPOT(1,10) <='1';
					ELSE
						sPOT(1,10) <='0';
					END IF;
					
					IF(SPOT(2, 9) = '1')THEN
						sPOT(2,10) <='1';
					ELSE
						sPOT(2,10) <='0';
					END IF;
					
					IF(SPOT(3, 9) = '1')THEN
						sPOT(3,10) <='1';
					ELSE
						sPOT(3,10) <='0';
					END IF;
					
					IF(SPOT(4, 9) = '1')THEN
						sPOT(4,10) <='1';
					ELSE
						sPOT(4,10) <='0';
					END IF;
					
					IF(SPOT(5, 9) = '1')THEN
						sPOT(5,10) <='1';
					ELSE
						sPOT(5,10) <='0';
					END IF;
					
					IF(SPOT(6, 9) = '1')THEN
						sPOT(6,10) <='1';
					ELSE
						sPOT(6,10) <='0';
					END IF;
					
					IF(SPOT(7, 9) = '1')THEN
						sPOT(7,10) <='1';
					ELSE
						sPOT(7,10) <='0';
					END IF;
					
					IF(SPOT(8, 9) = '1')THEN
						sPOT(8,10) <='1';
					ELSE
						sPOT(8,10) <='0';
					END IF;
					---------------------------------------Defined 10
					IF(SPOT(0, 8) = '1')THEN
						sPOT(0,9) <='1';
					ELSE
						sPOT(0,9) <='0';
					END IF;
					
					IF(SPOT(1, 8) = '1')THEN
						sPOT(1,9) <='1';
					ELSE
						sPOT(1,9) <='0';
					END IF;
					
					IF(SPOT(2, 8) = '1')THEN
						sPOT(2,9) <='1';
					ELSE
						sPOT(2,9) <='0';
					END IF;
					
					IF(SPOT(3, 8) = '1')THEN
						sPOT(3,9) <='1';
					ELSE
						sPOT(3,9) <='0';
					END IF;
					
					IF(SPOT(4, 8) = '1')THEN
						sPOT(4,9) <='1';
					ELSE
						sPOT(4,9) <='0';
					END IF;
					
					IF(SPOT(5, 8) = '1')THEN
						sPOT(5,9) <='1';
					ELSE
						sPOT(5,9) <='0';
					END IF;
					
					IF(SPOT(6, 8) = '1')THEN
						sPOT(6,9) <='1';
					ELSE
						sPOT(6,9) <='0';
					END IF;
					
					IF(SPOT(7, 8) = '1')THEN
						sPOT(7,9) <='1';
					ELSE
						sPOT(7,9) <='0';
					END IF;
					
					IF(SPOT(8, 8) = '1')THEN
						sPOT(8,9) <='1';
					ELSE
						sPOT(8,9) <='0';
					END IF;
					---------------------------------------Defined 9
					IF(SPOT(0, 7) = '1')THEN
						sPOT(0,8) <='1';
					ELSE
						sPOT(0,8) <='0';
					END IF;
					
					IF(SPOT(1, 7) = '1')THEN
						sPOT(1,8) <='1';
					ELSE
						sPOT(1,8) <='0';
					END IF;
					
					IF(SPOT(2, 7) = '1')THEN
						sPOT(2,8) <='1';
					ELSE
						sPOT(2,8) <='0';
					END IF;
					
					IF(SPOT(3, 7) = '1')THEN
						sPOT(3,8) <='1';
					ELSE
						sPOT(3,8) <='0';
					END IF;
					
					IF(SPOT(4, 7) = '1')THEN
						sPOT(4,8) <='1';
					ELSE
						sPOT(4,8) <='0';
					END IF;
					
					IF(SPOT(5, 7) = '1')THEN
						sPOT(5,8) <='1';
					ELSE
						sPOT(5,8) <='0';
					END IF;
					
					IF(SPOT(6, 7) = '1')THEN
						sPOT(6,8) <='1';
					ELSE
						sPOT(6,8) <='0';
					END IF;
					
					IF(SPOT(7, 7) = '1')THEN
						sPOT(7,8) <='1';
					ELSE
						sPOT(7,8) <='0';
					END IF;
					
					IF(SPOT(8, 7) = '1')THEN
						sPOT(8,8) <='1';
					ELSE
						sPOT(8,8) <='0';
					END IF;
					---------------------------------------Defined 8
					IF(SPOT(0, 6) = '1')THEN
						sPOT(0,7) <='1';
					ELSE
						sPOT(0,7) <='0';
					END IF;
					
					IF(SPOT(1, 6) = '1')THEN
						sPOT(1,7) <='1';
					ELSE
						sPOT(1,7) <='0';
					END IF;
					
					IF(SPOT(2, 6) = '1')THEN
						sPOT(2,7) <='1';
					ELSE
						sPOT(2,7) <='0';
					END IF;
					
					IF(SPOT(3, 6) = '1')THEN
						sPOT(3,7) <='1';
					ELSE
						sPOT(3,7) <='0';
					END IF;
					
					IF(SPOT(4, 6) = '1')THEN
						sPOT(4,7) <='1';
					ELSE
						sPOT(4,7) <='0';
					END IF;
					
					IF(SPOT(5, 6) = '1')THEN
						sPOT(5,7) <='1';
					ELSE
						sPOT(5,7) <='0';
					END IF;
					
					IF(SPOT(6, 6) = '1')THEN
						sPOT(6,7) <='1';
					ELSE
						sPOT(6,7) <='0';
					END IF;
					
					IF(SPOT(7, 6) = '1')THEN
						sPOT(7,7) <='1';
					ELSE
						sPOT(7,7) <='0';
					END IF;
					
					IF(SPOT(8, 6) = '1')THEN
						sPOT(8,7) <='1';
					ELSE
						sPOT(8,7) <='0';
					END IF;
					---------------------------------------Defined 7
					IF(SPOT(0, 5) = '1')THEN
						sPOT(0,6) <='1';
					ELSE
						sPOT(0,6) <='0';
					END IF;
					
					IF(SPOT(1, 5) = '1')THEN
						sPOT(1,6) <='1';
					ELSE
						sPOT(1,6) <='0';
					END IF;
					
					IF(SPOT(2, 5) = '1')THEN
						sPOT(2,6) <='1';
					ELSE
						sPOT(2,6) <='0';
					END IF;
					
					IF(SPOT(3, 5) = '1')THEN
						sPOT(3,6) <='1';
					ELSE
						sPOT(3,6) <='0';
					END IF;
					
					IF(SPOT(4, 5) = '1')THEN
						sPOT(4,6) <='1';
					ELSE
						sPOT(4,6) <='0';
					END IF;
					
					IF(SPOT(5, 5) = '1')THEN
						sPOT(5,6) <='1';
					ELSE
						sPOT(5,6) <='0';
					END IF;
					
					IF(SPOT(6, 5) = '1')THEN
						sPOT(6,6) <='1';
					ELSE
						sPOT(6,6) <='0';
					END IF;
					
					IF(SPOT(7, 5) = '1')THEN
						sPOT(7,6) <='1';
					ELSE
						sPOT(7,6) <='0';
					END IF;
					
					IF(SPOT(8, 5) = '1')THEN
						sPOT(8,6) <='1';
					ELSE
						sPOT(8,6) <='0';
					END IF;
					---------------------------------------Defined 6
					IF(SPOT(0, 4) = '1')THEN
						sPOT(0,5) <='1';
					ELSE
						sPOT(0,5) <='0';
					END IF;
					
					IF(SPOT(1, 4) = '1')THEN
						sPOT(1,5) <='1';
					ELSE
						sPOT(1,5) <='0';
					END IF;
					
					IF(SPOT(2, 4) = '1')THEN
						sPOT(2,5) <='1';
					ELSE
						sPOT(2,5) <='0';
					END IF;
					
					IF(SPOT(3, 4) = '1')THEN
						sPOT(3,5) <='1';
					ELSE
						sPOT(3,5) <='0';
					END IF;
					
					IF(SPOT(4, 4) = '1')THEN
						sPOT(4,5) <='1';
					ELSE
						sPOT(4,5) <='0';
					END IF;
					
					IF(SPOT(5, 4) = '1')THEN
						sPOT(5,5) <='1';
					ELSE
						sPOT(5,5) <='0';
					END IF;
					
					IF(SPOT(6, 4) = '1')THEN
						sPOT(6,5) <='1';
					ELSE
						sPOT(6,5) <='0';
					END IF;
					
					IF(SPOT(7, 4) = '1')THEN
						sPOT(7,5) <='1';
					ELSE
						sPOT(7,5) <='0';
					END IF;
					
					IF(SPOT(8, 4) = '1')THEN
						sPOT(8,5) <='1';
					ELSE
						sPOT(8,5) <='0';
					END IF;
					---------------------------------------Defined 5
					IF(SPOT(0, 3) = '1')THEN
						sPOT(0,4) <='1';
					ELSE
						sPOT(0,4) <='0';
					END IF;
					
					IF(SPOT(1, 3) = '1')THEN
						sPOT(1,4) <='1';
					ELSE
						sPOT(1,4) <='0';
					END IF;
					
					IF(SPOT(2, 3) = '1')THEN
						sPOT(2,4) <='1';
					ELSE
						sPOT(2,4) <='0';
					END IF;
					
					IF(SPOT(3, 3) = '1')THEN
						sPOT(3,4) <='1';
					ELSE
						sPOT(3,4) <='0';
					END IF;
					
					IF(SPOT(4, 3) = '1')THEN
						sPOT(4,4) <='1';
					ELSE
						sPOT(4,4) <='0';
					END IF;
					
					IF(SPOT(5, 3) = '1')THEN
						sPOT(5,4) <='1';
					ELSE
						sPOT(5,4) <='0';
					END IF;
					
					IF(SPOT(6, 3) = '1')THEN
						sPOT(6,4) <='1';
					ELSE
						sPOT(6,4) <='0';
					END IF;
					
					IF(SPOT(7, 3) = '1')THEN
						sPOT(7,4) <='1';
					ELSE
						sPOT(7,4) <='0';
					END IF;
					
					IF(SPOT(8, 3) = '1')THEN
						sPOT(8,4) <='1';
					ELSE
						sPOT(8,4) <='0';
					END IF;
					---------------------------------------Defined 4
					IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
				END IF;
				-------------------------------------------------------Line 10 deleted
				
        IF(SPOT(0, 8) = '1')THEN
						sPOT(0,9) <='1';
					ELSE
						sPOT(0,9) <='0';
					END IF;
					
					IF(SPOT(1, 8) = '1')THEN
						sPOT(1,9) <='1';
					ELSE
						sPOT(1,9) <='0';
					END IF;
					
					IF(SPOT(2, 8) = '1')THEN
						sPOT(2,9) <='1';
					ELSE
						sPOT(2,9) <='0';
					END IF;
					
					IF(SPOT(3, 8) = '1')THEN
						sPOT(3,9) <='1';
					ELSE
						sPOT(3,9) <='0';
					END IF;
					
					IF(SPOT(4, 8) = '1')THEN
						sPOT(4,9) <='1';
					ELSE
						sPOT(4,9) <='0';
					END IF;
					
					IF(SPOT(5, 8) = '1')THEN
						sPOT(5,9) <='1';
					ELSE
						sPOT(5,9) <='0';
					END IF;
					
					IF(SPOT(6, 8) = '1')THEN
						sPOT(6,9) <='1';
					ELSE
						sPOT(6,9) <='0';
					END IF;
					
					IF(SPOT(7, 8) = '1')THEN
						sPOT(7,9) <='1';
					ELSE
						sPOT(7,9) <='0';
					END IF;
					
					IF(SPOT(8, 8) = '1')THEN
						sPOT(8,9) <='1';
					ELSE
						sPOT(8,9) <='0';
					END IF;
					---------------------------------------Defined 9
					IF(SPOT(0, 7) = '1')THEN
						sPOT(0,8) <='1';
					ELSE
						sPOT(0,8) <='0';
					END IF;
					
					IF(SPOT(1, 7) = '1')THEN
						sPOT(1,8) <='1';
					ELSE
						sPOT(1,8) <='0';
					END IF;
					
					IF(SPOT(2, 7) = '1')THEN
						sPOT(2,8) <='1';
					ELSE
						sPOT(2,8) <='0';
					END IF;
					
					IF(SPOT(3, 7) = '1')THEN
						sPOT(3,8) <='1';
					ELSE
						sPOT(3,8) <='0';
					END IF;
					
					IF(SPOT(4, 7) = '1')THEN
						sPOT(4,8) <='1';
					ELSE
						sPOT(4,8) <='0';
					END IF;
					
					IF(SPOT(5, 7) = '1')THEN
						sPOT(5,8) <='1';
					ELSE
						sPOT(5,8) <='0';
					END IF;
					
					IF(SPOT(6, 7) = '1')THEN
						sPOT(6,8) <='1';
					ELSE
						sPOT(6,8) <='0';
					END IF;
					
					IF(SPOT(7, 7) = '1')THEN
						sPOT(7,8) <='1';
					ELSE
						sPOT(7,8) <='0';
					END IF;
					
					IF(SPOT(8, 7) = '1')THEN
						sPOT(8,8) <='1';
					ELSE
						sPOT(8,8) <='0';
					END IF;
					---------------------------------------Defined 8
					IF(SPOT(0, 6) = '1')THEN
						sPOT(0,7) <='1';
					ELSE
						sPOT(0,7) <='0';
					END IF;
					
					IF(SPOT(1, 6) = '1')THEN
						sPOT(1,7) <='1';
					ELSE
						sPOT(1,7) <='0';
					END IF;
					
					IF(SPOT(2, 6) = '1')THEN
						sPOT(2,7) <='1';
					ELSE
						sPOT(2,7) <='0';
					END IF;
					
					IF(SPOT(3, 6) = '1')THEN
						sPOT(3,7) <='1';
					ELSE
						sPOT(3,7) <='0';
					END IF;
					
					IF(SPOT(4, 6) = '1')THEN
						sPOT(4,7) <='1';
					ELSE
						sPOT(4,7) <='0';
					END IF;
					
					IF(SPOT(5, 6) = '1')THEN
						sPOT(5,7) <='1';
					ELSE
						sPOT(5,7) <='0';
					END IF;
					
					IF(SPOT(6, 6) = '1')THEN
						sPOT(6,7) <='1';
					ELSE
						sPOT(6,7) <='0';
					END IF;
					
					IF(SPOT(7, 6) = '1')THEN
						sPOT(7,7) <='1';
					ELSE
						sPOT(7,7) <='0';
					END IF;
					
					IF(SPOT(8, 6) = '1')THEN
						sPOT(8,7) <='1';
					ELSE
						sPOT(8,7) <='0';
					END IF;
					---------------------------------------Defined 7
					IF(SPOT(0, 5) = '1')THEN
						sPOT(0,6) <='1';
					ELSE
						sPOT(0,6) <='0';
					END IF;
					
					IF(SPOT(1, 5) = '1')THEN
						sPOT(1,6) <='1';
					ELSE
						sPOT(1,6) <='0';
					END IF;
					
					IF(SPOT(2, 5) = '1')THEN
						sPOT(2,6) <='1';
					ELSE
						sPOT(2,6) <='0';
					END IF;
					
					IF(SPOT(3, 5) = '1')THEN
						sPOT(3,6) <='1';
					ELSE
						sPOT(3,6) <='0';
					END IF;
					
					IF(SPOT(4, 5) = '1')THEN
						sPOT(4,6) <='1';
					ELSE
						sPOT(4,6) <='0';
					END IF;
					
					IF(SPOT(5, 5) = '1')THEN
						sPOT(5,6) <='1';
					ELSE
						sPOT(5,6) <='0';
					END IF;
					
					IF(SPOT(6, 5) = '1')THEN
						sPOT(6,6) <='1';
					ELSE
						sPOT(6,6) <='0';
					END IF;
					
					IF(SPOT(7, 5) = '1')THEN
						sPOT(7,6) <='1';
					ELSE
						sPOT(7,6) <='0';
					END IF;
					
					IF(SPOT(8, 5) = '1')THEN
						sPOT(8,6) <='1';
					ELSE
						sPOT(8,6) <='0';
					END IF;
					---------------------------------------Defined 6
					IF(SPOT(0, 4) = '1')THEN
						sPOT(0,5) <='1';
					ELSE
						sPOT(0,5) <='0';
					END IF;
					
					IF(SPOT(1, 4) = '1')THEN
						sPOT(1,5) <='1';
					ELSE
						sPOT(1,5) <='0';
					END IF;
					
					IF(SPOT(2, 4) = '1')THEN
						sPOT(2,5) <='1';
					ELSE
						sPOT(2,5) <='0';
					END IF;
					
					IF(SPOT(3, 4) = '1')THEN
						sPOT(3,5) <='1';
					ELSE
						sPOT(3,5) <='0';
					END IF;
					
					IF(SPOT(4, 4) = '1')THEN
						sPOT(4,5) <='1';
					ELSE
						sPOT(4,5) <='0';
					END IF;
					
					IF(SPOT(5, 4) = '1')THEN
						sPOT(5,5) <='1';
					ELSE
						sPOT(5,5) <='0';
					END IF;
					
					IF(SPOT(6, 4) = '1')THEN
						sPOT(6,5) <='1';
					ELSE
						sPOT(6,5) <='0';
					END IF;
					
					IF(SPOT(7, 4) = '1')THEN
						sPOT(7,5) <='1';
					ELSE
						sPOT(7,5) <='0';
					END IF;
					
					IF(SPOT(8, 4) = '1')THEN
						sPOT(8,5) <='1';
					ELSE
						sPOT(8,5) <='0';
					END IF;
					---------------------------------------Defined 5
					IF(SPOT(0, 3) = '1')THEN
						sPOT(0,4) <='1';
					ELSE
						sPOT(0,4) <='0';
					END IF;
					
					IF(SPOT(1, 3) = '1')THEN
						sPOT(1,4) <='1';
					ELSE
						sPOT(1,4) <='0';
					END IF;
					
					IF(SPOT(2, 3) = '1')THEN
						sPOT(2,4) <='1';
					ELSE
						sPOT(2,4) <='0';
					END IF;
					
					IF(SPOT(3, 3) = '1')THEN
						sPOT(3,4) <='1';
					ELSE
						sPOT(3,4) <='0';
					END IF;
					
					IF(SPOT(4, 3) = '1')THEN
						sPOT(4,4) <='1';
					ELSE
						sPOT(4,4) <='0';
					END IF;
					
					IF(SPOT(5, 3) = '1')THEN
						sPOT(5,4) <='1';
					ELSE
						sPOT(5,4) <='0';
					END IF;
					
					IF(SPOT(6, 3) = '1')THEN
						sPOT(6,4) <='1';
					ELSE
						sPOT(6,4) <='0';
					END IF;
					
					IF(SPOT(7, 3) = '1')THEN
						sPOT(7,4) <='1';
					ELSE
						sPOT(7,4) <='0';
					END IF;
					
					IF(SPOT(8, 3) = '1')THEN
						sPOT(8,4) <='1';
					ELSE
						sPOT(8,4) <='0';
					END IF;
					---------------------------------------Defined 4
					IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
        END IF;
				-------------------------------------------------------Line 9 deleted
        
				IF(SPOT(0, 8)='1' AND  SPOT(1, 8)='1' AND  SPOT(2, 8)='1' AND  SPOT(3, 8)='1' AND  SPOT(4, 8)='1' AND  SPOT(5, 8)='1' AND  SPOT(6, 8)='1' AND  SPOT(7, 8)='1' AND  SPOT(8, 8)='1')THEN
					IF(SPOT(0, 7) = '1')THEN
						sPOT(0,8) <='1';
					ELSE
						sPOT(0,8) <='0';
					END IF;
					
					IF(SPOT(1, 7) = '1')THEN
						sPOT(1,8) <='1';
					ELSE
						sPOT(1,8) <='0';
					END IF;
					
					IF(SPOT(2, 7) = '1')THEN
						sPOT(2,8) <='1';
					ELSE
						sPOT(2,8) <='0';
					END IF;
					
					IF(SPOT(3, 7) = '1')THEN
						sPOT(3,8) <='1';
					ELSE
						sPOT(3,8) <='0';
					END IF;
					
					IF(SPOT(4, 7) = '1')THEN
						sPOT(4,8) <='1';
					ELSE
						sPOT(4,8) <='0';
					END IF;
					
					IF(SPOT(5, 7) = '1')THEN
						sPOT(5,8) <='1';
					ELSE
						sPOT(5,8) <='0';
					END IF;
					
					IF(SPOT(6, 7) = '1')THEN
						sPOT(6,8) <='1';
					ELSE
						sPOT(6,8) <='0';
					END IF;
					
					IF(SPOT(7, 7) = '1')THEN
						sPOT(7,8) <='1';
					ELSE
						sPOT(7,8) <='0';
					END IF;
					
					IF(SPOT(8, 7) = '1')THEN
						sPOT(8,8) <='1';
					ELSE
						sPOT(8,8) <='0';
					END IF;
					---------------------------------------Defined 8
					IF(SPOT(0, 6) = '1')THEN
						sPOT(0,7) <='1';
					ELSE
						sPOT(0,7) <='0';
					END IF;
					
					IF(SPOT(1, 6) = '1')THEN
						sPOT(1,7) <='1';
					ELSE
						sPOT(1,7) <='0';
					END IF;
					
					IF(SPOT(2, 6) = '1')THEN
						sPOT(2,7) <='1';
					ELSE
						sPOT(2,7) <='0';
					END IF;
					
					IF(SPOT(3, 6) = '1')THEN
						sPOT(3,7) <='1';
					ELSE
						sPOT(3,7) <='0';
					END IF;
					
					IF(SPOT(4, 6) = '1')THEN
						sPOT(4,7) <='1';
					ELSE
						sPOT(4,7) <='0';
					END IF;
					
					IF(SPOT(5, 6) = '1')THEN
						sPOT(5,7) <='1';
					ELSE
						sPOT(5,7) <='0';
					END IF;
					
					IF(SPOT(6, 6) = '1')THEN
						sPOT(6,7) <='1';
					ELSE
						sPOT(6,7) <='0';
					END IF;
					
					IF(SPOT(7, 6) = '1')THEN
						sPOT(7,7) <='1';
					ELSE
						sPOT(7,7) <='0';
					END IF;
					
					IF(SPOT(8, 6) = '1')THEN
						sPOT(8,7) <='1';
					ELSE
						sPOT(8,7) <='0';
					END IF;
					---------------------------------------Defined 7
					IF(SPOT(0, 5) = '1')THEN
						sPOT(0,6) <='1';
					ELSE
						sPOT(0,6) <='0';
					END IF;
					
					IF(SPOT(1, 5) = '1')THEN
						sPOT(1,6) <='1';
					ELSE
						sPOT(1,6) <='0';
					END IF;
					
					IF(SPOT(2, 5) = '1')THEN
						sPOT(2,6) <='1';
					ELSE
						sPOT(2,6) <='0';
					END IF;
					
					IF(SPOT(3, 5) = '1')THEN
						sPOT(3,6) <='1';
					ELSE
						sPOT(3,6) <='0';
					END IF;
					
					IF(SPOT(4, 5) = '1')THEN
						sPOT(4,6) <='1';
					ELSE
						sPOT(4,6) <='0';
					END IF;
					
					IF(SPOT(5, 5) = '1')THEN
						sPOT(5,6) <='1';
					ELSE
						sPOT(5,6) <='0';
					END IF;
					
					IF(SPOT(6, 5) = '1')THEN
						sPOT(6,6) <='1';
					ELSE
						sPOT(6,6) <='0';
					END IF;
					
					IF(SPOT(7, 5) = '1')THEN
						sPOT(7,6) <='1';
					ELSE
						sPOT(7,6) <='0';
					END IF;
					
					IF(SPOT(8, 5) = '1')THEN
						sPOT(8,6) <='1';
					ELSE
						sPOT(8,6) <='0';
					END IF;
					---------------------------------------Defined 6
					IF(SPOT(0, 4) = '1')THEN
						sPOT(0,5) <='1';
					ELSE
						sPOT(0,5) <='0';
					END IF;
					
					IF(SPOT(1, 4) = '1')THEN
						sPOT(1,5) <='1';
					ELSE
						sPOT(1,5) <='0';
					END IF;
					
					IF(SPOT(2, 4) = '1')THEN
						sPOT(2,5) <='1';
					ELSE
						sPOT(2,5) <='0';
					END IF;
					
					IF(SPOT(3, 4) = '1')THEN
						sPOT(3,5) <='1';
					ELSE
						sPOT(3,5) <='0';
					END IF;
					
					IF(SPOT(4, 4) = '1')THEN
						sPOT(4,5) <='1';
					ELSE
						sPOT(4,5) <='0';
					END IF;
					
					IF(SPOT(5, 4) = '1')THEN
						sPOT(5,5) <='1';
					ELSE
						sPOT(5,5) <='0';
					END IF;
					
					IF(SPOT(6, 4) = '1')THEN
						sPOT(6,5) <='1';
					ELSE
						sPOT(6,5) <='0';
					END IF;
					
					IF(SPOT(7, 4) = '1')THEN
						sPOT(7,5) <='1';
					ELSE
						sPOT(7,5) <='0';
					END IF;
					
					IF(SPOT(8, 4) = '1')THEN
						sPOT(8,5) <='1';
					ELSE
						sPOT(8,5) <='0';
					END IF;
					---------------------------------------Defined 5
					IF(SPOT(0, 3) = '1')THEN
						sPOT(0,4) <='1';
					ELSE
						sPOT(0,4) <='0';
					END IF;
					
					IF(SPOT(1, 3) = '1')THEN
						sPOT(1,4) <='1';
					ELSE
						sPOT(1,4) <='0';
					END IF;
					
					IF(SPOT(2, 3) = '1')THEN
						sPOT(2,4) <='1';
					ELSE
						sPOT(2,4) <='0';
					END IF;
					
					IF(SPOT(3, 3) = '1')THEN
						sPOT(3,4) <='1';
					ELSE
						sPOT(3,4) <='0';
					END IF;
					
					IF(SPOT(4, 3) = '1')THEN
						sPOT(4,4) <='1';
					ELSE
						sPOT(4,4) <='0';
					END IF;
					
					IF(SPOT(5, 3) = '1')THEN
						sPOT(5,4) <='1';
					ELSE
						sPOT(5,4) <='0';
					END IF;
					
					IF(SPOT(6, 3) = '1')THEN
						sPOT(6,4) <='1';
					ELSE
						sPOT(6,4) <='0';
					END IF;
					
					IF(SPOT(7, 3) = '1')THEN
						sPOT(7,4) <='1';
					ELSE
						sPOT(7,4) <='0';
					END IF;
					
					IF(SPOT(8, 3) = '1')THEN
						sPOT(8,4) <='1';
					ELSE
						sPOT(8,4) <='0';
					END IF;
					---------------------------------------Defined 4
					IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
				END IF;
				-------------------------------------------------------Line 8 deleted
        
				IF(SPOT(0, 7)='1' AND  SPOT(1, 7)='1' AND  SPOT(2, 7)='1' AND  SPOT(3, 7)='1' AND  SPOT(4, 7)='1' AND  SPOT(5, 7)='1' AND  SPOT(6, 7)='1' AND  SPOT(7, 7)='1' AND  SPOT(8, 7)='1')THEN
					IF(SPOT(0, 6) = '1')THEN
						sPOT(0,7) <='1';
					ELSE
						sPOT(0,7) <='0';
					END IF;
					
					IF(SPOT(1, 6) = '1')THEN
						sPOT(1,7) <='1';
					ELSE
						sPOT(1,7) <='0';
					END IF;
					
					IF(SPOT(2, 6) = '1')THEN
						sPOT(2,7) <='1';
					ELSE
						sPOT(2,7) <='0';
					END IF;
					
					IF(SPOT(3, 6) = '1')THEN
						sPOT(3,7) <='1';
					ELSE
						sPOT(3,7) <='0';
					END IF;
					
					IF(SPOT(4, 6) = '1')THEN
						sPOT(4,7) <='1';
					ELSE
						sPOT(4,7) <='0';
					END IF;
					
					IF(SPOT(5, 6) = '1')THEN
						sPOT(5,7) <='1';
					ELSE
						sPOT(5,7) <='0';
					END IF;
					
					IF(SPOT(6, 6) = '1')THEN
						sPOT(6,7) <='1';
					ELSE
						sPOT(6,7) <='0';
					END IF;
					
					IF(SPOT(7, 6) = '1')THEN
						sPOT(7,7) <='1';
					ELSE
						sPOT(7,7) <='0';
					END IF;
					
					IF(SPOT(8, 6) = '1')THEN
						sPOT(8,7) <='1';
					ELSE
						sPOT(8,7) <='0';
					END IF;
					---------------------------------------Defined 7
					IF(SPOT(0, 5) = '1')THEN
						sPOT(0,6) <='1';
					ELSE
						sPOT(0,6) <='0';
					END IF;
					
					IF(SPOT(1, 5) = '1')THEN
						sPOT(1,6) <='1';
					ELSE
						sPOT(1,6) <='0';
					END IF;
					
					IF(SPOT(2, 5) = '1')THEN
						sPOT(2,6) <='1';
					ELSE
						sPOT(2,6) <='0';
					END IF;
					
					IF(SPOT(3, 5) = '1')THEN
						sPOT(3,6) <='1';
					ELSE
						sPOT(3,6) <='0';
					END IF;
					
					IF(SPOT(4, 5) = '1')THEN
						sPOT(4,6) <='1';
					ELSE
						sPOT(4,6) <='0';
					END IF;
					
					IF(SPOT(5, 5) = '1')THEN
						sPOT(5,6) <='1';
					ELSE
						sPOT(5,6) <='0';
					END IF;
					
					IF(SPOT(6, 5) = '1')THEN
						sPOT(6,6) <='1';
					ELSE
						sPOT(6,6) <='0';
					END IF;
					
					IF(SPOT(7, 5) = '1')THEN
						sPOT(7,6) <='1';
					ELSE
						sPOT(7,6) <='0';
					END IF;
					
					IF(SPOT(8, 5) = '1')THEN
						sPOT(8,6) <='1';
					ELSE
						sPOT(8,6) <='0';
					END IF;
					---------------------------------------Defined 6
					IF(SPOT(0, 4) = '1')THEN
						sPOT(0,5) <='1';
					ELSE
						sPOT(0,5) <='0';
					END IF;
					
					IF(SPOT(1, 4) = '1')THEN
						sPOT(1,5) <='1';
					ELSE
						sPOT(1,5) <='0';
					END IF;
					
					IF(SPOT(2, 4) = '1')THEN
						sPOT(2,5) <='1';
					ELSE
						sPOT(2,5) <='0';
					END IF;
					
					IF(SPOT(3, 4) = '1')THEN
						sPOT(3,5) <='1';
					ELSE
						sPOT(3,5) <='0';
					END IF;
					
					IF(SPOT(4, 4) = '1')THEN
						sPOT(4,5) <='1';
					ELSE
						sPOT(4,5) <='0';
					END IF;
					
					IF(SPOT(5, 4) = '1')THEN
						sPOT(5,5) <='1';
					ELSE
						sPOT(5,5) <='0';
					END IF;
					
					IF(SPOT(6, 4) = '1')THEN
						sPOT(6,5) <='1';
					ELSE
						sPOT(6,5) <='0';
					END IF;
					
					IF(SPOT(7, 4) = '1')THEN
						sPOT(7,5) <='1';
					ELSE
						sPOT(7,5) <='0';
					END IF;
					
					IF(SPOT(8, 4) = '1')THEN
						sPOT(8,5) <='1';
					ELSE
						sPOT(8,5) <='0';
					END IF;
					---------------------------------------Defined 5
					IF(SPOT(0, 3) = '1')THEN
						sPOT(0,4) <='1';
					ELSE
						sPOT(0,4) <='0';
					END IF;
					
					IF(SPOT(1, 3) = '1')THEN
						sPOT(1,4) <='1';
					ELSE
						sPOT(1,4) <='0';
					END IF;
					
					IF(SPOT(2, 3) = '1')THEN
						sPOT(2,4) <='1';
					ELSE
						sPOT(2,4) <='0';
					END IF;
					
					IF(SPOT(3, 3) = '1')THEN
						sPOT(3,4) <='1';
					ELSE
						sPOT(3,4) <='0';
					END IF;
					
					IF(SPOT(4, 3) = '1')THEN
						sPOT(4,4) <='1';
					ELSE
						sPOT(4,4) <='0';
					END IF;
					
					IF(SPOT(5, 3) = '1')THEN
						sPOT(5,4) <='1';
					ELSE
						sPOT(5,4) <='0';
					END IF;
					
					IF(SPOT(6, 3) = '1')THEN
						sPOT(6,4) <='1';
					ELSE
						sPOT(6,4) <='0';
					END IF;
					
					IF(SPOT(7, 3) = '1')THEN
						sPOT(7,4) <='1';
					ELSE
						sPOT(7,4) <='0';
					END IF;
					
					IF(SPOT(8, 3) = '1')THEN
						sPOT(8,4) <='1';
					ELSE
						sPOT(8,4) <='0';
					END IF;
					---------------------------------------Defined 4
					IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
				END IF;
        -------------------------------------------------------Line 7 deleted
        
        IF(SPOT(0, 6)='1' AND  SPOT(1, 6)='1' AND  SPOT(2, 6)='1' AND  SPOT(3, 6)='1' AND  SPOT(4, 6)='1' AND  SPOT(5, 6)='1' AND  SPOT(6, 6)='1' AND  SPOT(7, 6)='1' AND  SPOT(8, 6)='1')THEN
          IF(SPOT(0, 5) = '1')THEN
						sPOT(0,6) <='1';
					ELSE
						sPOT(0,6) <='0';
					END IF;
					
					IF(SPOT(1, 5) = '1')THEN
						sPOT(1,6) <='1';
					ELSE
						sPOT(1,6) <='0';
					END IF;
					
					IF(SPOT(2, 5) = '1')THEN
						sPOT(2,6) <='1';
					ELSE
						sPOT(2,6) <='0';
					END IF;
					
					IF(SPOT(3, 5) = '1')THEN
						sPOT(3,6) <='1';
					ELSE
						sPOT(3,6) <='0';
					END IF;
					
					IF(SPOT(4, 5) = '1')THEN
						sPOT(4,6) <='1';
					ELSE
						sPOT(4,6) <='0';
					END IF;
					
					IF(SPOT(5, 5) = '1')THEN
						sPOT(5,6) <='1';
					ELSE
						sPOT(5,6) <='0';
					END IF;
					
					IF(SPOT(6, 5) = '1')THEN
						sPOT(6,6) <='1';
					ELSE
						sPOT(6,6) <='0';
					END IF;
					
					IF(SPOT(7, 5) = '1')THEN
						sPOT(7,6) <='1';
					ELSE
						sPOT(7,6) <='0';
					END IF;
					
					IF(SPOT(8, 5) = '1')THEN
						sPOT(8,6) <='1';
					ELSE
						sPOT(8,6) <='0';
					END IF;
					---------------------------------------Defined 6
					IF(SPOT(0, 4) = '1')THEN
						sPOT(0,5) <='1';
					ELSE
						sPOT(0,5) <='0';
					END IF;
					
					IF(SPOT(1, 4) = '1')THEN
						sPOT(1,5) <='1';
					ELSE
						sPOT(1,5) <='0';
					END IF;
					
					IF(SPOT(2, 4) = '1')THEN
						sPOT(2,5) <='1';
					ELSE
						sPOT(2,5) <='0';
					END IF;
					
					IF(SPOT(3, 4) = '1')THEN
						sPOT(3,5) <='1';
					ELSE
						sPOT(3,5) <='0';
					END IF;
					
					IF(SPOT(4, 4) = '1')THEN
						sPOT(4,5) <='1';
					ELSE
						sPOT(4,5) <='0';
					END IF;
					
					IF(SPOT(5, 4) = '1')THEN
						sPOT(5,5) <='1';
					ELSE
						sPOT(5,5) <='0';
					END IF;
					
					IF(SPOT(6, 4) = '1')THEN
						sPOT(6,5) <='1';
					ELSE
						sPOT(6,5) <='0';
					END IF;
					
					IF(SPOT(7, 4) = '1')THEN
						sPOT(7,5) <='1';
					ELSE
						sPOT(7,5) <='0';
					END IF;
					
					IF(SPOT(8, 4) = '1')THEN
						sPOT(8,5) <='1';
					ELSE
						sPOT(8,5) <='0';
					END IF;
					---------------------------------------Defined 5
					IF(SPOT(0, 3) = '1')THEN
						sPOT(0,4) <='1';
					ELSE
						sPOT(0,4) <='0';
					END IF;
					
					IF(SPOT(1, 3) = '1')THEN
						sPOT(1,4) <='1';
					ELSE
						sPOT(1,4) <='0';
					END IF;
					
					IF(SPOT(2, 3) = '1')THEN
						sPOT(2,4) <='1';
					ELSE
						sPOT(2,4) <='0';
					END IF;
					
					IF(SPOT(3, 3) = '1')THEN
						sPOT(3,4) <='1';
					ELSE
						sPOT(3,4) <='0';
					END IF;
					
					IF(SPOT(4, 3) = '1')THEN
						sPOT(4,4) <='1';
					ELSE
						sPOT(4,4) <='0';
					END IF;
					
					IF(SPOT(5, 3) = '1')THEN
						sPOT(5,4) <='1';
					ELSE
						sPOT(5,4) <='0';
					END IF;
					
					IF(SPOT(6, 3) = '1')THEN
						sPOT(6,4) <='1';
					ELSE
						sPOT(6,4) <='0';
					END IF;
					
					IF(SPOT(7, 3) = '1')THEN
						sPOT(7,4) <='1';
					ELSE
						sPOT(7,4) <='0';
					END IF;
					
					IF(SPOT(8, 3) = '1')THEN
						sPOT(8,4) <='1';
					ELSE
						sPOT(8,4) <='0';
					END IF;
					---------------------------------------Defined 4
					IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
        END IF;
        -------------------------------------------------------Line 6 deleted
        
        IF(SPOT(0, 5)='1' AND  SPOT(1, 5)='1' AND  SPOT(2, 5)='1' AND  SPOT(3, 5)='1' AND  SPOT(4, 5)='1' AND  SPOT(5, 5)='1' AND  SPOT(6, 5)='1' AND  SPOT(7, 5)='1' AND  SPOT(8, 5)='1')THEN
          IF(SPOT(0, 4) = '1')THEN
						sPOT(0,5) <='1';
					ELSE
						sPOT(0,5) <='0';
					END IF;
					
					IF(SPOT(1, 4) = '1')THEN
						sPOT(1,5) <='1';
					ELSE
						sPOT(1,5) <='0';
					END IF;
					
					IF(SPOT(2, 4) = '1')THEN
						sPOT(2,5) <='1';
					ELSE
						sPOT(2,5) <='0';
					END IF;
					
					IF(SPOT(3, 4) = '1')THEN
						sPOT(3,5) <='1';
					ELSE
						sPOT(3,5) <='0';
					END IF;
					
					IF(SPOT(4, 4) = '1')THEN
						sPOT(4,5) <='1';
					ELSE
						sPOT(4,5) <='0';
					END IF;
					
					IF(SPOT(5, 4) = '1')THEN
						sPOT(5,5) <='1';
					ELSE
						sPOT(5,5) <='0';
					END IF;
					
					IF(SPOT(6, 4) = '1')THEN
						sPOT(6,5) <='1';
					ELSE
						sPOT(6,5) <='0';
					END IF;
					
					IF(SPOT(7, 4) = '1')THEN
						sPOT(7,5) <='1';
					ELSE
						sPOT(7,5) <='0';
					END IF;
					
					IF(SPOT(8, 4) = '1')THEN
						sPOT(8,5) <='1';
					ELSE
						sPOT(8,5) <='0';
					END IF;
					---------------------------------------Defined 5
					IF(SPOT(0, 3) = '1')THEN
						sPOT(0,4) <='1';
					ELSE
						sPOT(0,4) <='0';
					END IF;
					
					IF(SPOT(1, 3) = '1')THEN
						sPOT(1,4) <='1';
					ELSE
						sPOT(1,4) <='0';
					END IF;
					
					IF(SPOT(2, 3) = '1')THEN
						sPOT(2,4) <='1';
					ELSE
						sPOT(2,4) <='0';
					END IF;
					
					IF(SPOT(3, 3) = '1')THEN
						sPOT(3,4) <='1';
					ELSE
						sPOT(3,4) <='0';
					END IF;
					
					IF(SPOT(4, 3) = '1')THEN
						sPOT(4,4) <='1';
					ELSE
						sPOT(4,4) <='0';
					END IF;
					
					IF(SPOT(5, 3) = '1')THEN
						sPOT(5,4) <='1';
					ELSE
						sPOT(5,4) <='0';
					END IF;
					
					IF(SPOT(6, 3) = '1')THEN
						sPOT(6,4) <='1';
					ELSE
						sPOT(6,4) <='0';
					END IF;
					
					IF(SPOT(7, 3) = '1')THEN
						sPOT(7,4) <='1';
					ELSE
						sPOT(7,4) <='0';
					END IF;
					
					IF(SPOT(8, 3) = '1')THEN
						sPOT(8,4) <='1';
					ELSE
						sPOT(8,4) <='0';
					END IF;
					---------------------------------------Defined 4
					IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
        END IF;
        -------------------------------------------------------Line 5 deleted
        
        IF(SPOT(0, 4)='1' AND  SPOT(1, 4)='1' AND  SPOT(2, 4)='1' AND  SPOT(3, 4)='1' AND  SPOT(4, 4)='1' AND  SPOT(5, 4)='1' AND  SPOT(6, 4)='1' AND  SPOT(7, 4)='1' AND  SPOT(8, 4)='1')THEN
          IF(SPOT(0, 3) = '1')THEN
						sPOT(0,4) <='1';
					ELSE
						sPOT(0,4) <='0';
					END IF;
					
					IF(SPOT(1, 3) = '1')THEN
						sPOT(1,4) <='1';
					ELSE
						sPOT(1,4) <='0';
					END IF;
					
					IF(SPOT(2, 3) = '1')THEN
						sPOT(2,4) <='1';
					ELSE
						sPOT(2,4) <='0';
					END IF;
					
					IF(SPOT(3, 3) = '1')THEN
						sPOT(3,4) <='1';
					ELSE
						sPOT(3,4) <='0';
					END IF;
					
					IF(SPOT(4, 3) = '1')THEN
						sPOT(4,4) <='1';
					ELSE
						sPOT(4,4) <='0';
					END IF;
					
					IF(SPOT(5, 3) = '1')THEN
						sPOT(5,4) <='1';
					ELSE
						sPOT(5,4) <='0';
					END IF;
					
					IF(SPOT(6, 3) = '1')THEN
						sPOT(6,4) <='1';
					ELSE
						sPOT(6,4) <='0';
					END IF;
					
					IF(SPOT(7, 3) = '1')THEN
						sPOT(7,4) <='1';
					ELSE
						sPOT(7,4) <='0';
					END IF;
					
					IF(SPOT(8, 3) = '1')THEN
						sPOT(8,4) <='1';
					ELSE
						sPOT(8,4) <='0';
					END IF;
					---------------------------------------Defined 4
					IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
        END IF;
        -------------------------------------------------------Line 4 deleted
        
        IF(SPOT(0, 3)='1' AND  SPOT(1, 3)='1' AND  SPOT(2, 3)='1' AND  SPOT(3, 3)='1' AND  SPOT(4, 3)='1' AND  SPOT(5, 3)='1' AND  SPOT(6, 3)='1' AND  SPOT(7, 3)='1' AND  SPOT(8, 3)='1')THEN
          IF(SPOT(0, 2) = '1')THEN
						sPOT(0,3) <='1';
					ELSE
						sPOT(0,3) <='0';
					END IF;
					
					IF(SPOT(1, 2) = '1')THEN
						sPOT(1,3) <='1';
					ELSE
						sPOT(1,3) <='0';
					END IF;
					
					IF(SPOT(2, 2) = '1')THEN
						sPOT(2,3) <='1';
					ELSE
						sPOT(2,3) <='0';
					END IF;
					
					IF(SPOT(3, 2) = '1')THEN
						sPOT(3,3) <='1';
					ELSE
						sPOT(3,3) <='0';
					END IF;
					
					IF(SPOT(4, 2) = '1')THEN
						sPOT(4,3) <='1';
					ELSE
						sPOT(4,3) <='0';
					END IF;
					
					IF(SPOT(5, 2) = '1')THEN
						sPOT(5,3) <='1';
					ELSE
						sPOT(5,3) <='0';
					END IF;
					
					IF(SPOT(6, 2) = '1')THEN
						sPOT(6,3) <='1';
					ELSE
						sPOT(6,3) <='0';
					END IF;
					
					IF(SPOT(7, 2) = '1')THEN
						sPOT(7,3) <='1';
					ELSE
						sPOT(7,3) <='0';
					END IF;
					
					IF(SPOT(8, 2) = '1')THEN
						sPOT(8,3) <='1';
					ELSE
						sPOT(8,3) <='0';
					END IF;
					---------------------------------------Defined 3
					IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
        END IF;
        -------------------------------------------------------Line 3 deleted
        
        IF(SPOT(0, 2)='1' AND  SPOT(1, 2)='1' AND  SPOT(2, 2)='1' AND  SPOT(3, 2)='1' AND  SPOT(4, 2)='1' AND  SPOT(5, 2)='1' AND  SPOT(6, 2)='1' AND  SPOT(7, 2)='1' AND  SPOT(8, 2)='1')THEN
          IF(SPOT(0, 1) = '1')THEN
						sPOT(0,2) <='1';
					ELSE
						sPOT(0,2) <='0';
					END IF;
					
					IF(SPOT(1, 1) = '1')THEN
						sPOT(1,2) <='1';
					ELSE
						sPOT(1,2) <='0';
					END IF;
					
					IF(SPOT(2, 1) = '1')THEN
						sPOT(2,2) <='1';
					ELSE
						sPOT(2,2) <='0';
					END IF;
					
					IF(SPOT(3, 1) = '1')THEN
						sPOT(3,2) <='1';
					ELSE
						sPOT(3,2) <='0';
					END IF;
					
					IF(SPOT(4, 1) = '1')THEN
						sPOT(4,2) <='1';
					ELSE
						sPOT(4,2) <='0';
					END IF;
					
					IF(SPOT(5, 1) = '1')THEN
						sPOT(5,2) <='1';
					ELSE
						sPOT(5,2) <='0';
					END IF;
					
					IF(SPOT(6, 1) = '1')THEN
						sPOT(6,2) <='1';
					ELSE
						sPOT(6,2) <='0';
					END IF;
					
					IF(SPOT(7, 1) = '1')THEN
						sPOT(7,2) <='1';
					ELSE
						sPOT(7,2) <='0';
					END IF;
					
					IF(SPOT(8, 1) = '1')THEN
						sPOT(8,2) <='1';
					ELSE
						sPOT(8,2) <='0';
					END IF;
					---------------------------------------Defined 2
					IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
        END IF;
        -------------------------------------------------------Line 2 deleted
        
        IF(SPOT(0, 1)='1' AND  SPOT(1, 1)='1' AND  SPOT(2, 1)='1' AND  SPOT(3, 1)='1' AND  SPOT(4, 1)='1' AND  SPOT(5, 1)='1' AND  SPOT(6, 1)='1' AND  SPOT(7, 1)='1' AND  SPOT(8, 1)='1')THEN
          IF(SPOT(0, 0) = '1')THEN
						sPOT(0,1) <='1';
					ELSE
						sPOT(0,1) <='0';
					END IF;
					
					IF(SPOT(1, 0) = '1')THEN
						sPOT(1,1) <='1';
					ELSE
						sPOT(1,1) <='0';
					END IF;
					
					IF(SPOT(2, 0) = '1')THEN
						sPOT(2,1) <='1';
					ELSE
						sPOT(2,1) <='0';
					END IF;
					
					IF(SPOT(3, 0) = '1')THEN
						sPOT(3,1) <='1';
					ELSE
						sPOT(3,1) <='0';
					END IF;
					
					IF(SPOT(4, 0) = '1')THEN
						sPOT(4,1) <='1';
					ELSE
						sPOT(4,1) <='0';
					END IF;
					
					IF(SPOT(5, 0) = '1')THEN
						sPOT(5,1) <='1';
					ELSE
						sPOT(5,1) <='0';
					END IF;
					
					IF(SPOT(6, 0) = '1')THEN
						sPOT(6,1) <='1';
					ELSE
						sPOT(6,1) <='0';
					END IF;
					
					IF(SPOT(7, 0) = '1')THEN
						sPOT(7,1) <='1';
					ELSE
						sPOT(7,1) <='0';
					END IF;
					
					IF(SPOT(8, 0) = '1')THEN
						sPOT(8,1) <='1';
					ELSE
						sPOT(8,1) <='0';
					END IF;
					---------------------------------------Defined 1
        END IF;
        -------------------------------------------------------Line 1 deleted
		  GRAVITY <= GRAVITY + 30;
		END IF;
		counter <= (others => '0');
	end if;
end if;
END IF;
END PROCESS;

PROCESS(key1)
BEGIN

IF(key1 = '1') THEN -- "d" key
	IF(SHAPE = '1')THEN
		IF(ROWMOVELEFT + ROWMOVERIGHT + 60 > 1114) THEN
			ROWMOVERIGHT <= 1115 - ROWMOVELEFT-60;
		ELSIF(SPOT(addrH+1,addrV)='1' OR NOMOVE = '1') THEN
			ROWMOVERIGHT <= ROWMOVERIGHT;
		ELSE
			ROWMOVERIGHT <= ROWMOVERIGHT + 60;
		END IF;
	ELSE
		IF(ROWMOVELEFT + ROWMOVERIGHT + 180 > 1114) THEN
			ROWMOVERIGHT <= 1115 - ROWMOVELEFT-180;
		ELSIF(SPOT(addrH+3,addrV)='1' OR SPOT(addrH+2,addrV)='1' OR NOMOVE = '1') THEN
			ROWMOVERIGHT <= ROWMOVERIGHT;
		ELSE
			ROWMOVERIGHT <= ROWMOVERIGHT + 60;
		END IF;
	END IF;
END IF;
END PROCESS;

PROCESS(key)
BEGIN

IF(key = '1') THEN --" a" key
	IF(ROWMOVELEFT + ROWMOVERIGHT < 576) THEN
		ROWMOVELEFT <= 575 - ROWMOVERIGHT;
	ELSIF(SPOT(addrH-1,addrV)='1' OR NOMOVE = '1') THEN
		ROWMOVELEFT <= ROWMOVELEFT;
	ELSE
		ROWMOVELEFT <= ROWMOVELEFT - 60;
	END IF;
END IF;
END PROCESS;

PROCESS(key2)
BEGIN
IF(key2='1')THEN
	TIM <= "00000101111101011110000100";    --1/32 SEC
ELSE
	TIM <=  "00010111110101111000010000" - LEVELUP;	  --1/8 SEC
END IF;
END PROCESS;


pixel_clk <= SYNTHESIZED_WIRE_3;
key<=SYNTHESIZED_WIRE_9;
key1<=SYNTHESIZED_WIRE_10;
key2<=SYNTHESIZED_WIRE_11;
SYNTHESIZED_WIRE_4 <= '1';
SYNTHESIZED_WIRE_5 <= '0';
SYNTHESIZED_WIRE_8 <= '0';


b2v_inst : hw_image_generator
PORT MAP(
		 pixels_y => SZ,
		 pixels_x => SZ,
		 ROWMOVERIGHT => ROWMOVERIGHT,
		 ROWMOVELEFT => ROWMOVELEFT,
		 GRAVITY => GRAVITY,
		 SPOT=>SPOT,
		 color=>RAND,
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
PORT MAP(clk=>clk, ps2_clk=>ps2_clk, ps2_data=>ps2_data, ascii_new =>SYNTHESIZED_WIRE_8, TESTa=>SYNTHESIZED_WIRE_9, TESTd=>SYNTHESIZED_WIRE_10, TESTs=>SYNTHESIZED_WIRE_11, TESTr=>SYNTHESIZED_WIRE_12);


b2v_inst4 : Lab5part2
PORT MAP( p=>SCOR(0), q=>SCOR(1), r=>SCOR(2), s=>SCOR(3),
	a=>ZERO(0),b=>ZERO(1),c=>ZERO(2),d=>ZERO(3),e=>ZERO(4),f=>ZERO(5),g=>ZERO(6)); --Zero and Score have been switch to reflect an accuarte score keeping on the board

b2v_inst5 : Lab5part2
PORT MAP( p=>NOVALUE(0), q=>NOVALUE(1), r=>NOVALUE(2), s=>NOVALUE(3),
	a=>SCORE(0),b=>SCORE(1),c=>SCORE(2),d=>SCORE(3),e=>SCORE(4),f=>SCORE(5),g=>SCORE(6));
	
b2v_inst6 : Lab5part2
PORT MAP( p=>HIGHSCOR(0), q=>HIGHSCOR(1), r=>HIGHSCOR(2), s=>HIGHSCOR(3),
	a=>HIGHSCORE(0),b=>HIGHSCORE(1),c=>HIGHSCORE(2),d=>HIGHSCORE(3),e=>HIGHSCORE(4),f=>HIGHSCORE(5),g=>HIGHSCORE(6));

b2v_inst7 : Lab5part2
PORT MAP( p=>INCREASE(0), q=>INCREASE(1), r=>INCREASE(2), s=>INCREASE(3),
	a=>HIGHSCORELEFT(0),b=>HIGHSCORELEFT(1),c=>HIGHSCORELEFT(2),d=>HIGHSCORELEFT(3),e=>HIGHSCORELEFT(4),f=>HIGHSCORELEFT(5),g=>HIGHSCORELEFT(6));	
END bdf_type;