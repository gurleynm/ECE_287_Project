LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package my_types_pkg is
  type HOLDER is array (natural range <>,natural range <>) of std_logic;
end package;