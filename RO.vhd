----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2021 10:34:25 AM
-- Design Name: 
-- Module Name: RO - Behavioral
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

entity RO is
    Port ( Sel : in STD_LOGIC_VECTOR (2 downto 0);
           Bx  : in STD_LOGIC_VECTOR (2 downto 0);
           En  : in STD_LOGIC;
           Q    : out STD_LOGIC);
end RO;

architecture Behavioral of RO is
    component ROslice is
    Port ( Sel      : in STD_LOGIC;
           En       : in STD_LOGIC;
           Bx       : in STD_LOGIC;
           A        : in STD_LOGIC;
           Alatched : in STD_LOGIC;
           B         : out STD_LOGIC;
           Blatched  : out STD_LOGIC);
    end component;

    attribute KEEP : string;
    attribute S    : string;
    
    signal B        : std_logic_vector (2 downto 0) := "000";
    signal Blatched : std_logic_vector (2 downto 0) := "000";
    
    attribute KEEP of B        : signal is "True";
    attribute S    of B        : signal is "True";
    attribute KEEP of Blatched : signal is "True";
    attribute S    of Blatched : signal is "True";
begin
    Q <= B(0);

    RO0: ROslice
	port map (Sel      => Sel(0),
	          En       => En,
	          Bx       => Bx(0),
	          A        => B(2),
	          Alatched => Blatched(2),
	          B        => B(0),
	          Blatched => Blatched(0)); 

    RO1: ROslice
	port map (Sel      => Sel(1),
	          En       => '1',
	          Bx       => Bx(1),
	          A        => B(0),
	          Alatched => Blatched(0),
	          B        => B(1),
	          Blatched => Blatched(1));

    RO2: ROslice
    -- CHANGED
	port map (Sel      => Sel(2),
	          En       => En,
	          --CHANGED 
	          Bx       => Bx(2),
	          A        => B(1),
	          Alatched => Blatched(1),
	          B        => B(2),
	          Blatched => Blatched(2));                    
end Behavioral;
