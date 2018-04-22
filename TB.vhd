library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_signed.all;
use work.img_proc_pack.all;


entity TB is
 port (
 start	: in std_logic ;	
 clk 		: in std_logic ;
 rst 		: in std_logic ;
 done		: out std_logic
);
end TB;

ARCHITECTURE arc_TB of TB is
--signal start	: std_logic := '0';	
--signal clk 		: std_logic := '0';
--signal rst 		: std_logic := '0';
--signal done		: std_logic := '0';
	
signal rows_to_filter_R 	:  row_3	;
signal rows_to_filter_G 	:  row_3	;
signal rows_to_filter_B 	:  row_3	;
signal push_out				:	STD_LOGIC;
signal write_en_ram			: 	STD_LOGIC;
signal read_en					:	STD_LOGIC; 
signal write_add_ram			:  STD_LOGIC_VECTOR (7 DOWNTO 0);
signal read_add_rom   		:  STD_LOGIC_VECTOR (7 DOWNTO 0);
signal rom_r_data				:  STD_LOGIC_VECTOR (1023 DOWNTO 0);
signal rom_g_data				:  STD_LOGIC_VECTOR (1023 DOWNTO 0);
signal rom_b_data				:  STD_LOGIC_VECTOR (1023 DOWNTO 0);
signal ram_r_data				:  STD_LOGIC_VECTOR (1023 DOWNTO 0);
signal ram_g_data				:  STD_LOGIC_VECTOR (1023 DOWNTO 0);
signal ram_b_data				:  STD_LOGIC_VECTOR (1023 DOWNTO 0);

 

component FSM is
	port ( 	START 				: in std_logic;
				CLK 					: in STD_LOGIC ;
				RST					: in STD_LOGIC ;
				PUSH_OUT				: out STD_LOGIC; 						
				READ_EN_OUT			: out STD_LOGIC;						
				WRITE_EN_RAM_OUT	: out STD_LOGIC;			
				DONE_OUT				: out STD_LOGIC
			); 
end component  FSM;

component filter is
port (
		rows_from_buffer : in row_3;
		filtered_row	  : out std_logic_vector (1023 downto 0)
		);
end component filter;


component buff is
	port ( 	
				RST					: in	STD_LOGIC;
				CLK 					: in	STD_LOGIC;
				push					: in  std_logic;
				R_IN					: in 	STD_LOGIC_VECTOR (1023 DOWNTO 0);
				G_IN					: in 	STD_LOGIC_VECTOR (1023 DOWNTO 0);
				B_IN					: in 	STD_LOGIC_VECTOR (1023 DOWNTO 0);
				re						: in  STD_LOGIC;
				we						: in  STD_LOGIC;
				
				add_rom				: out std_logic_vector(log2(pic_height) -1 downto 0);
				add_ram				: out std_logic_vector(log2(pic_height) -1 downto 0);
				R_OUT					: out row_3;
				G_OUT					: out row_3;
				B_OUT					: out row_3

			);
end component buff;

COMPONENT r_ram IS
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (1023 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		   : OUT STD_LOGIC_VECTOR (1023 DOWNTO 0)
	);
	END COMPONENT;
	
COMPONENT g_ram IS
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (1023 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		   : OUT STD_LOGIC_VECTOR (1023 DOWNTO 0)
	);
	END COMPONENT;
	
COMPONENT b_ram IS
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (1023 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		   : OUT STD_LOGIC_VECTOR (1023 DOWNTO 0)
	);
	END COMPONENT;

COMPONENT r_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		rden		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (1023 DOWNTO 0)
	);
	end COMPONENT;

COMPONENT g_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		rden		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (1023 DOWNTO 0)
	);
	
	
	end COMPONENT; 
	 
COMPONENT b_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		rden		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (1023 DOWNTO 0)
	);
	end COMPONENT;




begin
       
	ROM_R: r_rom PORT MAP (read_add_rom,clk,read_en,rom_r_data);
	ROM_G: g_rom PORT MAP (read_add_rom,clk,read_en,rom_g_data);
	ROM_B: b_rom PORT MAP (read_add_rom,clk,read_en,rom_b_data);
	
	SM : FSM PORT MAP (start,clk, rst,push_out,read_en,write_en_ram ,done);

	BUF:  buff PORT MAP  (rst,clk,push_out,rom_r_data,rom_g_data,rom_b_data,read_en,write_en_ram,read_add_rom,write_add_ram	,rows_to_filter_R,rows_to_filter_G,rows_to_filter_B);
	
	
	MED_R: filter PORT MAP  (rows_to_filter_R,ram_r_data);
	MED_G: filter PORT MAP  (rows_to_filter_G,ram_g_data);
	MED_B: filter PORT MAP  (rows_to_filter_B,ram_b_data);
	
	RAM_R: r_ram PORT MAP (write_add_ram,clk,ram_r_data,write_en_ram,open);
	RAM_G: g_ram PORT MAP (write_add_ram,clk,ram_g_data,write_en_ram,open);
	RAM_B: b_ram PORT MAP (write_add_ram,clk,ram_b_data,write_en_ram,open);
	

	

	

--	clk 	<= not clk  after 25 ns;
--	rst 	<= '1' 		after 5 ns;
--	start <= '1' 		after 6 ns;

end architecture arc_TB;