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
        LEDS      : out STD_LOGIC_VECTOR (8 downto 0);
        DISP_EN   : out STD_LOGIC_VECTOR (3 downto 0);
        SEGMENTS  : out STD_LOGIC_VECTOR (6 downto 0));
end RO_PUF;

architecture Behavioral of RO_PUF is

    component RO_PUF_Internal is
        Port ( 
            CLK     : in STD_LOGIC;
            RST     : in STD_LOGIC;
            EN      : in STD_LOGIC;
            Chal    : in STD_LOGIC_VECTOR(7 downto 0);
            Q       : out STD_LOGIC_VECTOR(7 downto 0);
            DONE    : out STD_LOGIC
            );
    end component;

    component sseg_des is
        Port (        COUNT : in std_logic_vector(15 downto 0); 				  
                        CLK : in std_logic;
                      VALID : in std_logic;
                    DISP_EN : out std_logic_vector(3 downto 0);
                   SEGMENTS : out std_logic_vector(6 downto 0)); -- Decimal Point is never used
    end component;
    
    signal response0 : std_logic_vector(7 downto 0) := "00000000";
    signal response1 : std_logic_vector(7 downto 0) := "00000000";
    signal response2 : std_logic_vector(7 downto 0) := "00000000";
    signal response3 : std_logic_vector(7 downto 0) := "00000000";
    signal response4 : std_logic_vector(7 downto 0) := "00000000";
    signal response5 : std_logic_vector(7 downto 0) := "00000000";
    signal response6 : std_logic_vector(7 downto 0) := "00000000";
    signal response7 : std_logic_vector(7 downto 0) := "00000000";
    signal response8 : std_logic_vector(7 downto 0) := "00000000";
    
    signal dones : std_logic_vector(8 downto 0) := "000000000";
    
    signal sseg_cnt : std_logic_vector(15 downto 0) := "0000000000000000";
    signal div_clk  : std_logic := '0';

begin

    div_clk_50MHZ: process(CLK)
    begin
      if(rising_edge(CLK)) then
        div_clk   <= not div_clk;
      end if;
    end process div_clk_50MHZ;
    
    RO_PUF_Internal0: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response0,
	          DONE => dones(0));
	        
    RO_PUF_Internal1: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response1,
	          DONE => dones(1));
	          
    RO_PUF_Internal2: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response2,
	          DONE => dones(2));
	          
    RO_PUF_Internal3: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response3,
	          DONE => dones(3));

    RO_PUF_Internal4: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response4,
	          DONE => dones(4));
	          
    RO_PUF_Internal5: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response5,
	          DONE => dones(5));
	          
    RO_PUF_Internal6: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response6,
	          DONE => dones(6));

    RO_PUF_Internal7: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response7,
	          DONE => dones(7));
	          
    RO_PUF_Internal8: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => BTNC,
	          EN   => '1',
	          Chal => SWITCHES,
	          Q    => response8,
	          DONE => dones(8));
	          
	sseg_cnt(0) <= '1' when response0 < response1 else '0';
	sseg_cnt(1) <= '0' when response1 < response2 else '1';
	sseg_cnt(2) <= '1' when response2 < response3 else '0';
	sseg_cnt(3) <= '0' when response3 < response4 else '1';
	sseg_cnt(4) <= '1' when response4 < response5 else '0';
	sseg_cnt(5) <= '0' when response5 < response6 else '1';
	sseg_cnt(6) <= '1' when response6 < response7 else '0';
	sseg_cnt(7) <= '0' when response7 < response8 else '1';

	LEDS(0) <= '1' when response0 < response1 else '0';
	LEDS(1) <= '0' when response1 < response2 else '1';
	LEDS(2) <= '1' when response2 < response3 else '0';
	LEDS(3) <= '0' when response3 < response4 else '1';
	LEDS(4) <= '1' when response4 < response5 else '0';
	LEDS(5) <= '0' when response5 < response6 else '1';
	LEDS(6) <= '1' when response6 < response7 else '0';
	LEDS(7) <= '0' when response7 < response8 else '1';

	
    my_sseg: sseg_des 
	port map (COUNT    => sseg_cnt,
	          CLK      => CLK,
	          VALID    => '1',
	          DISP_EN  => DISP_EN,
	          SEGMENTS => SEGMENTS);
	
	LEDS(8) <= dones(0) and dones(1) and dones(2) and dones(3) and dones(4) and dones(5) and dones(6) and dones(7) and dones(8);
	sseg_cnt(15 downto 8) <= SWITCHES;
	
end Behavioral;
