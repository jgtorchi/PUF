----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2021 09:58:39 AM
-- Design Name: 
-- Module Name: ROslice - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

entity ROslice is
    Port ( Sel      : in STD_LOGIC;
           En       : in STD_LOGIC;
           Bx       : in STD_LOGIC;
           A        : in STD_LOGIC;
           Alatched : in STD_LOGIC;
           B         : out STD_LOGIC;
           Blatched  : out STD_LOGIC);
end ROslice;

architecture Behavioral of ROslice is
    signal notA        : std_logic;
    signal notAlatched : std_logic;
    signal selG        : std_logic; --slice G signal after first mux
    signal selF        : std_logic; --slice F signal after first mux
    signal enG         : std_logic;
    signal enF         : std_logic;
    signal preB        : std_logic;
    signal latchEn     : std_logic;
begin
    notA        <= NOT A;
    notAlatched <= Alatched;
    
    with Sel select
        selG <= notA when '1',
        notAlatched when others;
    
    with Sel select
        selG <= notA when '1',
        notAlatched when others;

    with En select
        enG <= selG when '1',
        '0' when others;   
        
    with En select
        enF <= selF when '1',
        '0' when others;     
    
    with Bx select
        preB <= selF when '1',
        selG when others;
        
    B <= preB;
    
    latchEn <= '1';
    latch : PROCESS (latchEn, preB)
    BEGIN
        IF (latchEn = '1') THEN
            Blatched <= preB;
        END IF;
    END PROCESS latch;    
end Behavioral;
