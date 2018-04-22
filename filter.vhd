library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_signed.all;
use work.img_proc_pack.all;

entity filter is
port (
		rows_from_buffer : in row_3;
		filtered_row	  : out std_logic_vector (1023 downto 0)
		);
end entity filter;

architecture arc_filter of filter is

signal row:  curr_color (0 to 255);

begin
row			 <= smooth_row (rows_from_buffer);
filtered_row <= curr_color2stdlv(row);

end architecture arc_filter;