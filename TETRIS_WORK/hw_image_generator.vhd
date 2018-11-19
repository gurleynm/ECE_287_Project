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
use work.my_types_pkg.all;

ENTITY hw_image_generator IS
	GENERIC(
		pixels_y :	INTEGER := 60;    --row that first color will persist until
		pixels_x	:	INTEGER := 60);   --column that first color will persist until
	PORT(
		ROWMOVERIGHT:	IN 	INTEGER;
		ROWMOVELEFT	:	IN 	INTEGER;
		GRAVITY		:	IN		INTEGER;
		SPOT			:	IN		HOLDER(0 TO 8,0 TO 12);
		color			:	IN		STD_LOGIC;
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

BEGIN
	PROCESS(disp_ena, row, column)
	BEGIN
		IF(disp_ena = '1') THEN		--display time
			
			IF(SPOT(0,11)='1' AND 576<row AND row<634 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,10)='1' AND 576<row AND row<634 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,9)='1' AND 576<row AND row<634 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,8)='1' AND 576<row AND row<634 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,7)='1' AND 576<row AND row<634 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,6)='1' AND 576<row AND row<634 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,5)='1' AND 576<row AND row<634 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,4)='1' AND 576<row AND row<634 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,3)='1' AND 576<row AND row<634 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,2)='1' AND 576<row AND row<634 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,1)='1' AND 576<row AND row<634 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(0,0)='1' AND 576<row AND row<634 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
			ELSIF(SPOT(1,11)='1' AND 636<row AND row<694 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,10)='1' AND 636<row AND row<694 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,9)='1' AND 636<row AND row<694 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,8)='1' AND 636<row AND row<694 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,7)='1' AND 636<row AND row<694 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,6)='1' AND 636<row AND row<694 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,5)='1' AND 636<row AND row<694 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,4)='1' AND 636<row AND row<694 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,3)='1' AND 636<row AND row<694 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,2)='1' AND 636<row AND row<694 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,1)='1' AND 636<row AND row<694 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(1,0)='1' AND 636<row AND row<694 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
				
				
			ELSIF(SPOT(2,11)='1' AND 696<row AND row<754 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,10)='1' AND 696<row AND row<754 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,9)='1' AND 696<row AND row<754 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,8)='1' AND 696<row AND row<754 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,7)='1' AND 696<row AND row<754 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,6)='1' AND 696<row AND row<754 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,5)='1' AND 696<row AND row<754 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,4)='1' AND 696<row AND row<754 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,3)='1' AND 696<row AND row<754 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,2)='1' AND 696<row AND row<754 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,1)='1' AND 696<row AND row<754 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(2,0)='1' AND 696<row AND row<754 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
			ELSIF(SPOT(3,11)='1' AND 756<row AND row<814 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,10)='1' AND 756<row AND row<814 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,9)='1' AND 756<row AND row<814 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,8)='1' AND 756<row AND row<814 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,7)='1' AND 756<row AND row<814 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,6)='1' AND 756<row AND row<814 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,5)='1' AND 756<row AND row<814 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,4)='1' AND 756<row AND row<814 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,3)='1' AND 756<row AND row<814 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,2)='1' AND 756<row AND row<814 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,1)='1' AND 756<row AND row<814 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(3,0)='1' AND 756<row AND row<814 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
			ELSIF(SPOT(4,11)='1' AND 816<row AND row<874 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,10)='1' AND 816<row AND row<874 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,9)='1' AND 816<row AND row<874 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,8)='1' AND 816<row AND row<874 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,7)='1' AND 816<row AND row<874 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,6)='1' AND 816<row AND row<874 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,5)='1' AND 816<row AND row<874 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,4)='1' AND 816<row AND row<874 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,3)='1' AND 816<row AND row<874 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,2)='1' AND 816<row AND row<874 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,1)='1' AND 816<row AND row<874 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(4,0)='1' AND 816<row AND row<874 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
			ELSIF(SPOT(5,11)='1' AND 876<row AND row<934 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,10)='1' AND 876<row AND row<934 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,9)='1' AND 876<row AND row<934 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,8)='1' AND 876<row AND row<934 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,7)='1' AND 876<row AND row<934 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,6)='1' AND 876<row AND row<934 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,5)='1' AND 876<row AND row<934 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,4)='1' AND 876<row AND row<934 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,3)='1' AND 876<row AND row<934 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,2)='1' AND 876<row AND row<934 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,1)='1' AND 876<row AND row<934 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(5,0)='1' AND 876<row AND row<934 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
			ELSIF(SPOT(6,11)='1' AND 936<row AND row<994 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,10)='1' AND 936<row AND row<994 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,9)='1' AND 936<row AND row<994 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,8)='1' AND 936<row AND row<994 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,7)='1' AND 936<row AND row<994 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,6)='1' AND 936<row AND row<994 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,5)='1' AND 936<row AND row<994 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,4)='1' AND 936<row AND row<994 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,3)='1' AND 936<row AND row<994 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,2)='1' AND 936<row AND row<994 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,1)='1' AND 936<row AND row<994 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(6,0)='1' AND 936<row AND row<994 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
			ELSIF(SPOT(7,11)='1' AND 996<row AND row<1054 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,10)='1' AND 996<row AND row<1054 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,9)='1' AND 996<row AND row<1054 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,8)='1' AND 996<row AND row<1054 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,7)='1' AND 996<row AND row<1054 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,6)='1' AND 996<row AND row<1054 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,5)='1' AND 996<row AND row<1054 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,4)='1' AND 996<row AND row<1054 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,3)='1' AND 996<row AND row<1054 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,2)='1' AND 996<row AND row<1054 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,1)='1' AND 996<row AND row<1054 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(7,0)='1' AND 996<row AND row<1054 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
				
			ELSIF(SPOT(8,11)='1' AND 1056<row AND row<1114 AND 659<column AND column<720)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,10)='1' AND 1056<row AND row<1114 AND 599<column AND column<659)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,9)='1' AND 1056<row AND row<1114 AND 539<column AND column<599)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,8)='1' AND 1056<row AND row<1114 AND 479<column AND column<539)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,7)='1' AND 1056<row AND row<1114 AND 419<column AND column<479)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,6)='1' AND 1056<row AND row<1114 AND 359<column AND column<419)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,5)='1' AND 1056<row AND row<1114 AND 299<column AND column<359)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,4)='1' AND 1056<row AND row<1114 AND 239<column AND column<299)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,3)='1' AND 1056<row AND row<1114 AND 179<column AND column<239)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,2)='1' AND 1056<row AND row<1114 AND 119<column AND column<179)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,1)='1' AND 1056<row AND row<1114 AND 59<column AND column<119)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSIF(SPOT(8,0)='1' AND 1056<row AND row<1114 AND -1<column AND column<59)THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
				
			ELSIF(ROWMOVERIGHT + ROWMOVELEFT < row AND row < pixels_y + ROWMOVERIGHT + ROWMOVELEFT AND column < GRAVITY AND column > GRAVITY - 60 AND column < pixels_x + GRAVITY) THEN
				IF(color = '1') THEN
					red <= (OTHERS => '0');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '1');
				ELSE
					red <= (OTHERS => '1');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '0');
				END IF;				
			ELSIF((row < 576 AND row > 570 AND column < 720) OR (row < 1120 AND row > 1115 AND column < 720) OR (row < 1115 AND row > 576 AND column > 720 AND column < 725)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
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