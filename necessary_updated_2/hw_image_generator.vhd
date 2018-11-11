--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY hw_image_generator IS
	GENERIC(
		pixels_y :	INTEGER := 60;    --row that first color will persist until
		pixels_x	:	INTEGER := 60);   --column that first color will persist until
	PORT(
		ROWMOVERIGHT:	IN 	INTEGER;
		ROWMOVELEFT	:	IN 	INTEGER;
		GRAVITY		:	IN		INTEGER;
		LOWEST		:  IN		INTEGER;
		addrV			:	IN		INTEGER;
		addrH			:	IN		INTEGER;
		YES			:	IN		STD_LOGIC;
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
type SPOTi is array (0 TO 8,0 TO 17) of std_logic;
SIGNAL SPOT : SPOTi:=(OTHERS=>(OTHERS=>'0'));
type GREE is array (0 TO 8) of INTEGER;
SIGNAL GHOR:GREE:=(OTHERS=>100000);

SIGNAL hold : INTEGER :=0;


BEGIN

	PROCESS(YES)
	BEGIN
		IF(YES='1') THEN
			SPOT(addrH,addrV)<= '1';
			GHOR(addrH)<=LOWEST;
		ELSE
			SPOT(addrH,addrV)<= '0';
		END IF;
	END PROCESS;

	PROCESS(disp_ena, row, column)
	BEGIN
		IF(disp_ena = '1') THEN		--display time
			IF(ROWMOVERIGHT + ROWMOVELEFT < row AND row < pixels_y + ROWMOVERIGHT + ROWMOVELEFT AND column < GRAVITY AND column > GRAVITY - 60 AND column < pixels_x + GRAVITY) THEN
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF((row < 575 AND row > 570 AND column < 720) OR (row < 1120 AND row > 1115 AND column < 720) OR (row < 1115 AND row > 575 AND column > 720 AND column < 725)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			ELSIF(addrV<12 AND SPOT(addrH,addrV)='1' AND addrV*60< column AND column<720 AND (addrH*30+575)< row and row<(addrH*30+635))THEN
				red <= (OTHERS => '0');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '0');
			ELSIF((row-575) MOD 60 = 0 AND column MOD 60 = 0 AND SPOT((row-575)/60,column/60)='1' and GHOR((row-575)/60)<COLUMN AND COLUMN<720) THEN
				red <= (OTHERS => '0');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '0');
			ELSE
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	
	END PROCESS;
END behavior;