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
           B         : out STD_LOGIC := '0';
           Blatched  : out STD_LOGIC := '0');
end ROslice;

architecture Behavioral of ROslice is
    attribute KEEP : string;
    attribute S    : string;

    signal notA        : std_logic := '0';
    signal notAlatched : std_logic := '0';
    signal selG        : std_logic := '0'; --slice G signal after first mux
    signal selF        : std_logic := '0'; --slice F signal after first mux
    signal enG         : std_logic := '0';
    signal enF         : std_logic := '0';
    signal preB        : std_logic := '0';
    signal latchEn     : std_logic := '0';
    
    attribute KEEP of notA        : signal is "True";
    attribute S    of notA        : signal is "True";
    attribute KEEP of notAlatched : signal is "True";
    attribute S    of notAlatched : signal is "True";
    attribute KEEP of selG        : signal is "True";
    attribute S    of selG        : signal is "True";
    attribute KEEP of selF        : signal is "True";
    attribute S    of selF        : signal is "True";
    attribute KEEP of enG         : signal is "True";
    attribute S    of enG         : signal is "True";
    attribute KEEP of enF         : signal is "True";
    attribute S    of enF         : signal is "True";
    attribute KEEP of preB        : signal is "True";
    attribute S    of preB        : signal is "True";
    attribute KEEP of latchEn     : signal is "True";
    attribute S    of latchEn     : signal is "True";
begin
    notA        <= NOT A;
    -- Changed: Added not infront of Alatched
    notAlatched <= NOT Alatched;
    
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
        
    B <= preB after 2 ns;
    
    latchEn <= '1';
    latch : PROCESS (latchEn, preB)
    BEGIN
        IF (latchEn = '1') THEN
            Blatched <= preB after 3 ns;
        END IF;
    END PROCESS latch;    
end Behavioral;
