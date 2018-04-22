library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_signed.all;
use work.img_proc_pack.all;


entity buff is
	port ( 	
				RST					: in	STD_LOGIC;
				CLK 					: in	STD_LOGIC;
				push					: in  std_logic;
				R_IN					: in 	STD_LOGIC_VECTOR (1023 DOWNTO 0);
				G_IN					: in 	STD_LOGIC_VECTOR (1023 DOWNTO 0);
				B_IN					: in 	STD_LOGIC_VECTOR (1023 DOWNTO 0);
				re						: in  STD_LOGIC;
				we						: in  STD_LOGIC;
				
				add_rom				: out std_logic_vector((log2(pic_height) -1) downto 0);
				add_ram				: out std_logic_vector((log2(pic_height) -1) downto 0);
				R_OUT					: out row_3;
				G_OUT					: out row_3;
				B_OUT					: out row_3	
			);
end buff;

architecture arc_Buff of buff is
signal memor,memog,memob: std_logic_vector((pic_width*color_depth) -1 downto 0); 
signal ccr,ccg, ccb:curr_color(0 to (pic_width+1)); 
signal br, bg, bb: row_3;
signal cntr, cntw: std_logic_vector(log2(pic_height)-1  downto 0);

begin

memor	<= R_IN;
memog	<= G_IN;
memob	<= B_IN;



ccr<= memor(memor'high downto memor'high -color_depth +1) & stdlv2curr_color(memor)& memor(color_depth-1 downto memor'low) ;
ccg<= memog(memog'high downto memog'high -color_depth +1) & stdlv2curr_color(memog)&  memog(color_depth-1 downto memog'low) ;
ccb<= memob(memob'high downto memob'high -color_depth +1) & stdlv2curr_color(memob)& memob(color_depth-1 downto memob'low) ;	  
process (clk,rst) is
begin
	if(rst='0') then	
		br<=(others=>(others=>(others=>'0')));
		bg<=(others=>(others=>(others=>'0')));
		bb<=(others=>(others=>(others=>'0')));
		cntr<=(others=>'0');
		cntw<=(others=>'0');
    elsif rising_edge(clk) then
        cntr<=cntr+ re;
		  if(cntr = x"01") then
			add_rom <= x"00";		  
		  elsif(cntr + x"01" >= x"101") then
			add_rom<= x"ff";
		  else
		  add_rom<=cntr;
		  end if;
			cntw<=cntw+ we;
			add_ram<=cntw;
		if(push='1') then	
			br<=ccr & br(0 to 1);
			bg<=ccg & bg(0 to 1);
			bb<=ccb & bb(0 to 1);			
					
		end if;
		if( we = '1') then
			R_OUT <= br;
			G_OUT <= bg;
			B_OUT <= bb;
		end if;
	end if;
end process;	

end arc_buff;