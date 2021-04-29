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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RO_PUF is
    Port (  
        CLK      : in STD_LOGIC;
        BTNC     : in STD_LOGIC;
        SWITCHES : in STD_LOGIC_VECTOR (15 downto 0);
        LEDS      : out STD_LOGIC_VECTOR (15 downto 0);
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
    
    component state_machine IS
       PORT(
          clk                   : IN STD_LOGIC;
          SWITCHES              : IN STD_LOGIC_VECTOR(15 downto 0);
          SWITCHES_BUFFER       : IN STD_LOGIC_VECTOR(7 downto 0);
          BTNC                  : IN STD_LOGIC;
          RO_PUF_Internal_done  : IN STD_LOGIC;
          sha128_simple_READY   : IN STD_LOGIC;
          RO_PUF_Internal_RST   : OUT STD_LOGIC;
          sha128_simple_START   : OUT STD_LOGIC;
          sha128_simple_RESET   : OUT STD_LOGIC;
          SWITCHES_buffer_w     : OUT STD_LOGIC);
    end component;
    
    component sha128_simple is
        Port ( CLK : in STD_LOGIC;
               DATA_IN : in STD_LOGIC_VECTOR (15 downto 0);
               RESET : in STD_LOGIC;
               START : in STD_LOGIC;
               READY : out STD_LOGIC;
               DATA_OUT : out STD_LOGIC_VECTOR (127 downto 0));
    end component;

    component sseg_des is
        Port (        COUNT : in std_logic_vector(15 downto 0); 				  
                        CLK : in std_logic;
                      VALID : in std_logic;
                    DISP_EN : out std_logic_vector(3 downto 0);
                   SEGMENTS : out std_logic_vector(6 downto 0)); -- Decimal Point is never used
    end component;
    
    signal SWITCHES_buffer : std_logic_vector(7 downto 0) := "00000000";
    signal SWITCHES_buffer_w : std_logic := '0';
    
    signal RO_PUF_Internal_Q : std_logic_vector(7 downto 0) := "00000000";
    signal RO_PUF_Internal_done : std_logic := '0';
    signal RO_PUF_Internal_RST : std_logic := '0';
    
    signal sha128_simple_RESET : std_logic := '0';
    signal sha128_simple_START : std_logic := '0';
    signal sha128_simple_READY : std_logic := '0';
    signal sha128_simple_DATA_OUT : std_logic_vector(127 downto 0) := (others => '0');
    signal sha128_simple_DATA_IN : std_logic_vector(15 downto 0) := (others => '0');
    
    signal sseg_cnt : std_logic_vector(15 downto 0) := "0000000000000000";
    signal div_clk  : std_logic := '0';

begin

    div_clk_50MHZ: process(CLK)
    begin
      if(rising_edge(CLK)) then
        div_clk   <= not div_clk;
      end if;
    end process div_clk_50MHZ;
    
    FSM: state_machine
    port map(
          clk                   => div_clk,
          SWITCHES              => SWITCHES,
          SWITCHES_BUFFER       => SWITCHES_buffer,
          BTNC                  => BTNC,
          RO_PUF_Internal_done  => RO_PUF_Internal_done,
          sha128_simple_READY   => sha128_simple_READY,
          RO_PUF_Internal_RST   => RO_PUF_Internal_RST,
          sha128_simple_START   => sha128_simple_START,
          sha128_simple_RESET   => sha128_simple_RESET,
          SWITCHES_buffer_w     => SWITCHES_buffer_w);
    
    RO_PUF_Internal0: RO_PUF_Internal 
	port map (CLK  => div_clk,
	          RST  => RO_PUF_Internal_RST,
	          EN   => '1',
	          Chal => SWITCHES_buffer,
	          Q    => RO_PUF_Internal_Q,
	          DONE => RO_PUF_Internal_done);


    sha128_simple_DATA_IN <= SWITCHES_buffer & RO_PUF_Internal_Q;
    sha128_simple0: sha128_simple
    port map (CLK => div_clk,
              DATA_IN => sha128_simple_DATA_IN,
              RESET => sha128_simple_RESET,
              START => sha128_simple_START,
              READY => sha128_simple_READY,
              DATA_OUT => sha128_simple_DATA_OUT);

    my_sseg: sseg_des 
	port map (COUNT    => sseg_cnt,
	          CLK      => div_clk,
	          VALID    => '1',
	          DISP_EN  => DISP_EN,
	          SEGMENTS => SEGMENTS);
	          
	LEDS(7 downto 0) <= RO_PUF_Internal_Q;
	LEDS(13 downto 8) <= "000000";
	LEDS(14) <= RO_PUF_Internal_done;
	LEDS(15) <= (sha128_simple_READY AND RO_PUF_Internal_done);
	
	sseg_cnt_driver: process(RO_PUF_Internal_Q, sha128_simple_DATA_OUT, SWITCHES)
	begin
	   if SWITCHES(15 downto 12) = "0000" then
	       sseg_cnt <= SWITCHES_buffer & RO_PUF_Internal_Q;
	   else
	       if SWITCHES(15 downto 12) > "1000" then
	           sseg_cnt <= "0000000000000000";
	       else
	           sseg_cnt <= sha128_simple_DATA_OUT(to_integer(unsigned(SWITCHES(15 downto 12))) * 2 * 8 - 1 downto to_integer(unsigned(SWITCHES(15 downto 12))) * 2 * 8 - 16);
	       end if;
	   end if;
	
	end process;
	
	SWITCHES_buffer_process: process(div_clk, SWITCHES_buffer_w, SWITCHES)
	begin
	   if rising_edge(div_clk) then
	       if SWITCHES_buffer_w = '1' then
	           SWITCHES_buffer <= SWITCHES(7 downto 0);
	       end if;
	   end if;
	end process;
	
end Behavioral;
