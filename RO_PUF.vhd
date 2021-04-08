----------------------------------------------------------------------------------
-- Company: Cal Poly
-- Engineer: Jacob Torchia and Vasanth Sadhasi
-- 
-- Create Date: 04/08/2021 02:45:15 AM
-- Design Name: 
-- Module Name: RO_PUF - Behavioral
-- Project Name: Ring Oscillator PUF
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RO_PUF is
    Port ( 
        CLK      : in STD_LOGIC;
        BTNC     : in STD_LOGIC;
        SWITCHES : in STD_LOGIC_VECTOR (7 downto 0);
        LEDS      : out STD_LOGIC_VECTOR (9 downto 0);
        DISP_EN   : out STD_LOGIC_VECTOR (3 downto 0);
        SEGMENTS  : out STD_LOGIC_VECTOR (6 downto 0));
end RO_PUF;

architecture Behavioral of RO_PUF is

    component sseg_des is
        Port (        COUNT : in std_logic_vector(15 downto 0); 				  
                        CLK : in std_logic;
                      VALID : in std_logic;
                    DISP_EN : out std_logic_vector(3 downto 0);
                   SEGMENTS : out std_logic_vector(6 downto 0)); -- Decimal Point is never used
    end component;
    
    signal response : std_logic_vector(7 downto 0);
    signal sseg_cnt : std_logic_vector(15 downto 0);

begin

    my_sseg: sseg_des 
	port map (COUNT    => sseg_cnt,
	          CLK      => CLK,
	          VALID    => '1',
	          DISP_EN  => DISP_EN,
	          SEGMENTS => SEGMENTS); 
	          
    response <= "10100001";  
    sseg_cnt <= SWITCHES&response;   
    LEDS(7 downto 0) <= response; 
    LEDS(8) <= BTNC;
    LEDS(9) <= BTNC;
end Behavioral;