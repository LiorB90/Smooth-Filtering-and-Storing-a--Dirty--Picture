library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package img_proc_pack is
   constant pic_width   : positive := 256;
   constant pic_height  : positive := 256;
   constant color_depth : positive := 4;
   type curr_color is array (natural range <>) of std_logic_vector((color_depth-1) downto 0);
   type matrix2d is array (0 to 2) of curr_color(0 to 2);
   type row_3 is array (0 to 2) of curr_color(0 to (pic_width+1));   
   type data_arr is array (0 to (pic_height-1)) of curr_color(0 to (pic_width-1));
   constant mif_file_name_format: string := "x.mif";
   type     str_arr is array (0 to 2) of string(mif_file_name_format'range);
   constant mem_arr : str_arr := ("r.mif", "g.mif", "b.mif");
   constant filter_kind : string:= "sharpen"; -- median or smooth
   ----------------------------------------------------------------------------
   -- memory interface to internal logic
   ---------------------------------------------------------------------------- 
   function stdlv2curr_color (arg: std_logic_vector) return curr_color;
   ----------------------------------------------------------------------------
   -- internal logic to memory interface
   ----------------------------------------------------------------------------
   function curr_color2stdlv (arg: curr_color) return std_logic_vector;
   ----------------------------------------------------------------------------
   -- log 2 function
   ----------------------------------------------------------------------------
   function log2 (constant arg: integer) return integer;
   ----------------------------------------------------------------------------
   -- median filter
   ----------------------------------------------------------------------------
   function median_2d (arg : matrix2d) return std_logic_vector;
   function median_row (arg : row_3) return curr_color;
   ----------------------------------------------------------------------------
   -- smooth filter
   ----------------------------------------------------------------------------
   function smooth_row (arg : row_3) return curr_color;
   ----------------------------------------------------------------------------
   -- sharpenning filter
   ----------------------------------------------------------------------------
   function sharp_2d (arg : matrix2d) return std_logic_vector;
   function sharp_row (arg : row_3) return curr_color;
   ----------------------------------------------------------------------------
   -- binary image file translation type
   -- for test only
   ----------------------------------------------------------------------------
   -- pragma synthesis_off
   type byte is
      (
         b000, b001, b002, b003, b004, b005, b006, b007,
         b008, b009, b010, b011, b012, b013, b014, b015,
         b016, b017, b018, b019, b020, b021, b022, b023,
         b024, b025, b026, b027, b028, b029, b030, b031,
         b032, b033, b034, b035, b036, b037, b038, b039,
         b040, b041, b042, b043, b044, b045, b046, b047,
         b048, b049, b050, b051, b052, b053, b054, b055,
         b056, b057, b058, b059, b060, b061, b062, b063,
         b064, b065, b066, b067, b068, b069, b070, b071,
         b072, b073, b074, b075, b076, b077, b078, b079,
         b080, b081, b082, b083, b084, b085, b086, b087,
         b088, b089, b090, b091, b092, b093, b094, b095,
         b096, b097, b098, b099, b100, b101, b102, b103,
         b104, b105, b106, b107, b108, b109, b110, b111,
         b112, b113, b114, b115, b116, b117, b118, b119,
         b120, b121, b122, b123, b124, b125, b126, b127,
         b128, b129, b130, b131, b132, b133, b134, b135,
         b136, b137, b138, b139, b140, b141, b142, b143,
         b144, b145, b146, b147, b148, b149, b150, b151,
         b152, b153, b154, b155, b156, b157, b158, b159,
         b160, b161, b162, b163, b164, b165, b166, b167,
         b168, b169, b170, b171, b172, b173, b174, b175,
         b176, b177, b178, b179, b180, b181, b182, b183,
         b184, b185, b186, b187, b188, b189, b190, b191,
         b192, b193, b194, b195, b196, b197, b198, b199,
         b200, b201, b202, b203, b204, b205, b206, b207,
         b208, b209, b210, b211, b212, b213, b214, b215,
         b216, b217, b218, b219, b220, b221, b222, b223,
         b224, b225, b226, b227, b228, b229, b230, b231,
         b232, b233, b234, b235, b236, b237, b238, b239,
         b240, b241, b242, b243, b244, b245, b246, b247,
         b248, b249, b250, b251, b252, b253, b254, b255
         );
   
    type bit_file is file of byte;
  -- pragma synthesis_on
end package img_proc_pack;

package body img_proc_pack  is
   ----------------------------------------------------------------------------
   -- median filter
   ----------------------------------------------------------------------------
   function median_2d (arg : matrix2d) return std_logic_vector is
      variable buff : curr_color(0 to 2);
      function median(d : curr_color(0 to 2)) return std_logic_vector is
         variable temp : std_logic_vector((color_depth-1) downto 0);
      begin
         if (d(2) >= d(1) and d(2) <= d(0)) then
            temp:= d(2);
         elsif (d(2) >= d(0) and d(2) <= d(1)) then
            temp:= d(2);
         elsif (d(1) >= d(0) and d(1) <= d(2)) then
            temp:= d(1);
         elsif (d(1) >= d(2) and d(1) <= d(0)) then
            temp:= d(1);
         elsif (d(0) >= d(1) and d(0) <= d(2)) then
            temp:= d(0);
         elsif (d(0) >= d(2) and d(0) <= d(1)) then
            temp:= d(0);
         else
            temp:= d(0);
         end if;
         return temp;
      end function median;
   begin
      for i in arg'range loop
         buff(i):=median(arg(i));
      end loop;
      return median(buff);
   end function median_2d;

   function median_row (arg : row_3) return curr_color is
      variable t : curr_color(0 to (pic_width-1));
      variable curr_matrix : matrix2d;
   begin
      for i in 1 to pic_width loop
         for j in curr_matrix'range loop
           curr_matrix(j):=arg(j)((i-1) to (i+1));
         end loop;
         t(i-1):=median_2d(curr_matrix);
      end loop;
      return t;    
   end function median_row;

   ----------------------------------------------------------------------------
   -- smooth_filter
   ----------------------------------------------------------------------------
   function smooth_row (arg : row_3) return curr_color is
      variable t : curr_color(0 to (pic_width-1));
      variable curr_matrix : matrix2d;
      function smooth_filter (arg : matrix2d) return std_logic_vector is
         variable max: std_logic_vector(color_depth-1 downto 0):=(others => '0');
         variable min: std_logic_vector(color_depth-1 downto 0);
		 variable curr: std_logic_vector(color_depth-1 downto 0);
      begin
         min:=arg(0)(0);
         for i in 0 to 2 loop
            for j in 0 to 2 loop
               next when (i=1 and j=1);
               if (max<arg(i)(j)) then
                  max:=arg(i)(j);
               end if;
               if (min>arg(i)(j)) then
                  min:=arg(i)(j);
               end if;
            end loop;
         end loop;
         if (arg(1)(1)>max) then
            curr:=max;
         elsif (arg(1)(1)<min) then
            curr:=min;
         else
            curr:=arg(1)(1);
         end if;
         return curr;
      end function smooth_filter;
   begin
      for i in 1 to pic_width loop
         for j in curr_matrix'range loop
           curr_matrix(j):=arg(j)((i-1) to (i+1));
         end loop;
         t(i-1):=smooth_filter(curr_matrix);
      end loop;
      return t;    
   end function smooth_row;
   ----------------------------------------------------------------------------
   -- sharpenning filter
   ----------------------------------------------------------------------------
   function sharp_2d (arg : matrix2d) return std_logic_vector is
      variable t              : std_logic_vector(color_depth+1 downto 0);
      variable curr_pixel     : std_logic_vector(color_depth+1 downto 0);
      variable curr_pixel_new : std_logic_vector(color_depth+1 downto 0);
      variable temp           : std_logic_vector(color_depth+1 downto 0);
   begin
      t := ("00" & arg(0)(1)) +
           ("00" & arg(1)(0)) +
           ("00" & arg(1)(2)) +
           ("00" & arg(2)(1));
      curr_pixel := arg(1)(1) & "00";
      if (t > curr_pixel) then
         curr_pixel_new := t - curr_pixel;
         temp           := ("00" & arg(1)(1)) - curr_pixel_new;
         if temp(temp'high) = '1' or temp(temp'high-1) = '1' then
            temp := (others => '0');
         end if;
      else
         curr_pixel_new := curr_pixel - t;
         temp           := ("00" & arg(1)(1)) + curr_pixel_new;
         if temp(temp'high-1) = '1' then
            temp := (others => '1');
         end if;
      end if;
      return temp(color_depth-1 downto 0);
   end function sharp_2d;

   function sharp_row (arg : row_3) return curr_color is
      variable t           : curr_color(0 to (pic_width-1));
      variable curr_matrix : matrix2d;
   begin
      for i in 1 to pic_width loop
         for j in curr_matrix'range loop
            curr_matrix(j) := arg(j)((i-1) to (i+1));
         end loop;
         t(i-1) := sharp_2d(curr_matrix);
      end loop;
      return t;
   end function sharp_row;

   ----------------------------------------------------------------------------
   -- memory interface to internal logic
   ----------------------------------------------------------------------------   
   function stdlv2curr_color (arg: std_logic_vector) return curr_color is
      variable t: curr_color(0 to (pic_width-1));
   begin
	  for i in (pic_width-1) downto 0 loop
		t(pic_width-1-i):=arg(((i*color_depth) + (color_depth-1)) downto i*color_depth);
      end loop;
      return t;
   end 	function stdlv2curr_color;
   ----------------------------------------------------------------------------
   -- log 2 function
   ----------------------------------------------------------------------------
   function log2 (constant arg: integer) return integer is
   begin
    for i in 0 to arg loop
		if (2**i>=arg) then
			return i;
		end if;	
	end loop;
	return 0;
   end function log2;
   ----------------------------------------------------------------------------
   -- internal logic to memory interface
   ----------------------------------------------------------------------------
   function curr_color2stdlv (arg: curr_color) return std_logic_vector is
      variable t : std_logic_vector(((color_depth * pic_width)-1) downto 0);
   begin
      for i in 0 to pic_width-1 loop
         t((((pic_width-1-i)*color_depth) + (color_depth-1)) downto (pic_width-1-i)*color_depth):=arg(i);
      end loop;
       return t;
 end function curr_color2stdlv;   
end package body img_proc_pack;