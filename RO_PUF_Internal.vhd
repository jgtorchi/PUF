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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RO_PUF_Internal is
    Port ( 
        CLK     : in STD_LOGIC;
        RST     : in STD_LOGIC;
        EN      : in STD_LOGIC;
        Chal    : in STD_LOGIC_VECTOR(7 downto 0);
        Q       : out STD_LOGIC_VECTOR(7 downto 0);
        --CNT     : out std_logic_vector(7 downto 0);
        DONE    : out STD_LOGIC
        );
end RO_PUF_Internal;

architecture Behavioral of RO_PUF_Internal is

    component sseg_des is
        Port (        COUNT : in std_logic_vector(15 downto 0); 				  
                        CLK : in std_logic;
                      VALID : in std_logic;
                    DISP_EN : out std_logic_vector(3 downto 0);
                   SEGMENTS : out std_logic_vector(6 downto 0)); -- Decimal Point is never used
    end component;
    
    component RO is
        Port (Sel   : in std_logic_vector(2 downto 0);
              Bx    : in std_logic_vector(2 downto 0);
              En    : in std_logic;
              Q     : out std_logic
         );
    end component;
    
    constant MAX_VALUE : std_logic_vector(19 downto 0) := (others=>'1');
    
    signal chal_sel    : std_logic_vector(2 downto 0) := "000";
    signal chal_bx     : std_logic_vector(2 downto 0) := "000";
    signal chal_mux    : std_logic_vector(1 downto 0) := "00";

    signal RO_Q        : std_logic_vector(3 downto 0) := "0000";    
    signal RO_MUX_Q    : std_logic := '0';
    
    signal RO_Counter_Q  : std_logic_vector(19 downto 0) := (others=>'0');
    signal Std_Counter_Q : std_logic_vector(19 downto 0) := (others=>'0');

    signal EN_Internal : std_logic := '0';    
    signal pre_DONE    : std_logic := '0';    
    signal xorChal     : std_logic := '0';
    signal intRst      : std_logic := '0';
    signal delChal     : std_logic_vector(7 downto 0) := (others=>'0');
    
begin
    chal_sel <= Chal(2 downto 0);
    chal_bx <= Chal(5 downto 3);
    chal_mux <= Chal(7 downto 6);
    
    Q <= RO_Counter_Q(19 downto 12);
    
    pre_DONE <= '1' when Std_Counter_Q >= MAX_VALUE else '0';
    DONE <= pre_DONE;
    --CNT <= Std_Counter_Q;

    RO_0: RO 
	port map (Sel  => chal_sel,
	          Bx   => chal_bx,
	          En   => '1',
	          Q    => RO_Q(0)); 

    RO_1: RO 
	port map (Sel  => chal_sel,
	          Bx   => chal_bx,
	          En   => '1',
	          Q    => RO_Q(1)); 
	          
    RO_2: RO 
	port map (Sel  => chal_sel,
	          Bx   => chal_bx,
	          En   => '1',
	          Q    => RO_Q(2)); 
	
    RO_3: RO 
	port map (Sel  => chal_sel,
	          Bx   => chal_bx,
	          En   => '1',
	          Q    => RO_Q(3));
	          
	          
    RO_Mux : process (chal_mux, RO_Q)
    begin
        case chal_mux is
            when "00" => RO_MUX_Q <= RO_Q(0);
            when "01" => RO_MUX_Q <= RO_Q(1);
            when "10" => RO_MUX_Q <= RO_Q(2);
            when "11" => RO_MUX_Q <= RO_Q(3); 
            when others => RO_MUX_Q <= '0'; 
        end case; 
    end process;
    
    delayed_challenge : process(CLK)
    begin
        if (rising_edge(CLK)) then
            delChal <= chal;
        end if;
    end process;
    
    intRst <= '0' when delChal = chal else '1';
    
    RO_Counter : process (RO_MUX_Q, EN_Internal, RST, Chal)
    begin
        if (RST = '1') OR (intRst = '1')then
            RO_Counter_Q <= (others => '0');
        elsif rising_edge(RO_MUX_Q) then
            if EN_Internal = '1' then
                RO_Counter_Q <= RO_Counter_Q + 1;
            end if;
        end if; 
    end process;
    
    Std_Counter : process (CLK, EN_Internal, RST, Chal)
    begin
        if (RST = '1') OR (intRst = '1') then
            Std_Counter_Q <= (others => '0');
        elsif rising_edge(CLK) then
            if EN_Internal = '1' then
                Std_Counter_Q <= Std_Counter_Q + 1;
            end if;
        end if;
    end process;
    
    EN_Internal_process : process (Std_Counter_Q, EN, pre_done)
    begin
        if (pre_DONE = '0') and (EN = '1')then
            EN_Internal <= '1';
        else
            EN_Internal <= '0';
        end if;
    end process;

end Behavioral;
