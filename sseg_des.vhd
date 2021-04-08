------------------------------------------------------------------------
-- CPE 133 VHDL File: universal_sseg_dec.vhd
--
-- Company: Ratface Engineering
-- Engineer: Samuel Cheng, James Ratner
-- 
-- 
-- Description: Special seven segment display driver. This file 
--  interprets the input(s) as an unsigned binary number
--  and displays the result on the four seven-segment
--  displays on the development board. This module implements 
--  the required multiplexing of the display based
--  upon the CLK input. For this module, the CLK frequency 
--  is expected to be in 50MHz but will work for other 
--  relatively fast frequencies. The CLK input connects to a
--  clock signal from the development board. 
--
--  The display controls are hierarchical in nature. The description 
--   below presents the input information according to it's 
--   functionality. 
-- 
--    VALID: if valid = '0', four dashes are displayed
--           if valid = '1', decimal number appears on display
--
--    COUNT: count used to display 2 bytes
--            NOTE: 16-bit count

--
------------------------------------------------------------------------

-----------------------------------------------------------------------
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------
-- Universal seven-segment display driver. Outputs are active
-- low and configured ABCEDFG in "segment" output. 
--------------------------------------------------------------
entity sseg_des is
    Port (        COUNT : in std_logic_vector(15 downto 0); 				  
                    CLK : in std_logic;
				  VALID : in std_logic;
                DISP_EN : out std_logic_vector(3 downto 0);
               SEGMENTS : out std_logic_vector(6 downto 0)); -- Decimal Point is never used
end sseg_des;


-------------------------------------------------------------
-- description of ssegment decoder
-------------------------------------------------------------
architecture my_sseg of sseg_des is
	component clk_div
        Port (  clk : in std_logic;
               sclk : out std_logic);
    end component;
	
    -- intermediate signal declaration -----------------------
    signal   cnt_dig : std_logic_vector(1 downto 0); 
    signal   digit : std_logic_vector (3 downto 0); 
    signal   sclk : std_logic;
begin	
				 
    -- instantiation of clock divider -----------------
    my_clk: clk_div 
	port map (clk => clk,
	          sclk => sclk ); 

    -- advance the count (used for display multiplexing) -----
    process (SCLK)
    begin
        if (rising_edge(SCLK)) then 
            cnt_dig <= cnt_dig + 1; 
        end if; 
    end process; 
	
    -- select the display sseg data abcdefg (active low) based on dp -----
    process (cnt_dig, digit)
    begin
        if VALID = '1' then
            case digit is
                when "0000" => segments <= "0000001";  -- 0
                when "0001" => segments <= "1001111";  -- 1
                when "0010"	=> segments <= "0010010";  -- 2
                when "0011"	=> segments <= "0000110";  -- 3
                when "0100"	=> segments <= "1001100";  -- 4
                when "0101"	=> segments <= "0100100";  -- 5
                when "0110"	=> segments <= "0100000";  -- 6
                when "0111"	=> segments <= "0001111";  -- 7
                when "1000"	=> segments <= "0000000";  -- 8
                when "1001"	=> segments <= "0000100";  -- 9
                when "1010" => segments <= "0001000";  -- A
                when "1011" => segments <= "1100000";  -- b
                when "1100" => segments <= "1110010";  -- c
                when "1101" => segments <= "1000010";  -- d
                when "1110" => segments <= "0110000";  -- E
                when "1111"	=> segments <= "0111000";  -- F
                when others	=> segments <= "1111111";  -- BLANK, should not happen
            end case;
        else
            segments <=	"1111110";
        end if;
	end process;
	
   -- actuate the correct display --------------------------
   DISP_EN <= "1110" when cnt_dig = "00" else 
              "1101" when cnt_dig = "01" else
              "1011" when cnt_dig = "10" else
              "0111" when cnt_dig = "11" else
              "1111"; 

 
	process (cnt_dig, COUNT)    
	begin
        case cnt_dig is
            when "00" => digit <= COUNT(3 downto 0); 
            when "01" => digit <= COUNT(7 downto 4); 
            when "10" => digit <= COUNT(11 downto 8); 
            when "11" => digit <= COUNT(15 downto 12); 
            when others => digit <= "0000"; 
        end case; 
	end process;
			
end my_sseg;


-----------------------------------------------------------------------
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-----------------------------------------------------------------------
-- Module to divide the clock 
-----------------------------------------------------------------------
entity clk_div is
    Port (  clk : in std_logic;
           sclk : out std_logic);
end clk_div;

architecture my_clk_div of clk_div is
   constant max_count : integer := (2200);  
   signal tmp_clk : std_logic := '0'; 
begin
   my_div: process (clk,tmp_clk)              
      variable div_cnt : integer := 0;   
   begin
      if (rising_edge(clk)) then   
         if (div_cnt = MAX_COUNT) then 
            tmp_clk <= not tmp_clk; 
            div_cnt := 0; 
         else
            div_cnt := div_cnt + 1; 
         end if; 
      end if; 
      sclk <= tmp_clk; 
   end process my_div; 
end my_clk_div;



