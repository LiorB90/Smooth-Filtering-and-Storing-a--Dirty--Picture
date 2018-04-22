library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_signed.all;
use work.img_proc_pack.all;

entity FSM is
	port ( 	START 				: in std_logic;
				CLK 					: in STD_LOGIC ;
				RST					: in STD_LOGIC ;
				PUSH_OUT				: out STD_LOGIC; 				
				READ_EN_OUT			: out STD_LOGIC;
				WRITE_EN_RAM_OUT	: out STD_LOGIC;	
				DONE_OUT				: out STD_LOGIC
			);
end FSM;


architecture behave of FSM is
type statetype is (s0,s1,s2,s3);
signal state 	:  statetype;
signal count		:	integer range 0 to 1024;

begin

state_machine: process(clk,rst)

begin

	if (RST = '0') then 	
		count			 <= 0;
		state 		 <=  s0 ;
		READ_EN_OUT  <= '0';
		PUSH_OUT		 <= '0';
		DONE_OUT 	 <= '0';
		WRITE_EN_RAM_OUT  <= '0';
	elsif	rising_edge(clk) then
		
		case state is
		when s0 => 
				PUSH_OUT		 <= '0';
				READ_EN_OUT  <= '0';
				WRITE_EN_RAM_OUT  <= '0';		
				if (start = '1') then
					state <= s1;
				end if;
		when s1 => 
					PUSH_OUT		 <= '1';					
					READ_EN_OUT  <= '1';
					count <= count+ 1 ;
					if(count >= 2) then
						WRITE_EN_RAM_OUT  <= '1';
					else 
						WRITE_EN_RAM_OUT  <= '0';
					end if;
					if (count = 255 ) then
						state <= s2;
					end if;
		when s2 => 
				PUSH_OUT		 <= '1';
				WRITE_EN_RAM_OUT  <= '1';
				READ_EN_OUT  <= '0';
				state <= s3;
		
		when s3 =>  
				PUSH_OUT		 <= '0';
				READ_EN_OUT  <= '0';	
				WRITE_EN_RAM_OUT  <= '0';
				DONE_OUT <= '1';
		
		end case;
				
	end if;
end process state_machine;

		
end behave;	