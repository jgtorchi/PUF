----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2018 10:00:17 AM
-- Design Name: 
-- Module Name: sha128_simple - Behavioral
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

entity sha128_simple is
    Port ( CLK : in STD_LOGIC;
           DATA_IN : in STD_LOGIC_VECTOR (15 downto 0);
           RESET : in STD_LOGIC;
           START : in STD_LOGIC;
           READY : out STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (127 downto 0));
end sha128_simple;

architecture Behavioral of sha128_simple is
    signal input_addr : std_logic_vector(3 downto 0);
    signal input_word : std_logic_vector(31 downto 0);
    signal hash_out : std_logic_vector(255 downto 0);
    
    component sha256 is 
        port(
            clk    : in std_logic;
            reset  : in std_logic;
            enable : in std_logic;
    
            ready  : out std_logic; -- Ready to process the next block
            update : in  std_logic; -- Start processing the next block
    
            -- Connections to the input buffer; we assume block RAM that presents
            -- valid data the cycle after the address has changed:
            word_address : out std_logic_vector(3 downto 0); -- Word 0 .. 15
            word_input   : in std_logic_vector(31 downto 0);
    
            -- Intermediate/final hash values:
            hash_output : out std_logic_vector(255 downto 0);
    
            -- Debug port, used in simulation; leave unconnected:
            debug_port : out std_logic_vector(31 downto 0)
        );
    end component;
begin

    sha256_comp : sha256 port map ( clk => CLK,
                                    reset => RESET,
                                    enable => '1',
                                    ready => READY,
                                    update => START,
                                    word_address => input_addr,
                                    word_input => input_word,
                                    hash_output => hash_out);

    process (input_addr, DATA_IN)
    begin
        case input_addr is
            when x"0" => input_word <= DATA_IN & x"8000";
            when x"F" => input_word <= x"0000" & DATA_IN;
            when others => input_word <= (others => '0');
        end case;
    end process;
    
    DATA_OUT <= hash_out(127 downto 0);

end Behavioral;
