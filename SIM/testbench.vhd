library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RO_PUF_Internal_test is
end RO_PUF_Internal_test;

architecture Behavioral of RO_PUF_Internal_test is

    component RO_PUF_Internal is
        Port (        CLK     : in STD_LOGIC;
        RST     : in STD_LOGIC;
        EN      : in STD_LOGIC;
        Chal    : in STD_LOGIC_VECTOR(7 downto 0);
        Q       : out STD_LOGIC_VECTOR(7 downto 0);
        DONE    : out STD_LOGIC);
    end component;
      
	signal CLK     : std_logic := '0';
	signal rst     : std_logic := '0';
	signal en      : std_logic := '0';
	signal chal    : std_logic_vector(7 downto 0) := "00000000";
    signal q       : std_logic_vector(7 downto 0);
    signal done    : std_logic;
	constant CLK_period    : time := 20 ns;

  begin
  
        puf: RO_PUF_Internal PORT MAP (
            clk     => clk,
            rst     => rst,
            en      => en,
            chal    => chal,
            q       => q,
            done    => done
            );
		CLK_process : process
		begin
			CLK <= '0';
			wait for CLK_period/2;
			CLK <= '1'; 
			wait for CLK_period/2;
		end process;
		
		
        main: process
        begin
            wait for CLK_period;
            en <= '1';
            wait until done = '1';
            wait for CLK_period * 3;
            rst <= '1';
            wait for CLK_period * 3;
            rst <= '0';
            wait;
        end process;
end Behavioral;
