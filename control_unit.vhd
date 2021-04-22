----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2021 01:38:01 PM
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

ENTITY state_machine IS
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
END state_machine;

ARCHITECTURE Behavioral OF state_machine IS
   TYPE STATE_TYPE IS (init, puf_compute, sha_compute, done);
   SIGNAL state   : STATE_TYPE;
BEGIN    
   PROCESS (clk, BTNC)
   BEGIN
      IF BTNC = '1' THEN
         state <= init;
      ELSIF (clk'EVENT AND clk = '1') THEN
         CASE state IS
            WHEN init=>
               state <= puf_compute;
            WHEN puf_compute=>
               IF RO_PUF_Internal_done = '1' THEN
                  state <= sha_compute;
               ELSE
                  state <= puf_compute;
               END IF;
            WHEN sha_compute=>
               IF sha128_simple_READY = '1' THEN
                  state <= done;
               ELSE
                  state <= sha_compute;
               END IF;
            WHEN done =>
                IF SWITCHES_BUFFER = SWITCHES(7 downto 0) then
                    state <= done;
                ELSE
                    state <= init;
                END IF;
         END CASE;
      END IF;
   END PROCESS;
   
   PROCESS (state)
   BEGIN
      CASE state IS
         WHEN init =>
            RO_PUF_Internal_RST <= '1';
            sha128_simple_START <= '0';
            sha128_simple_RESET <= '1';
            SWITCHES_buffer_w   <= '1';
         WHEN puf_compute =>
            RO_PUF_Internal_RST <= '0';
            sha128_simple_START <= '0';
            sha128_simple_RESET <= '0';
            SWITCHES_buffer_w   <= '0';
         WHEN sha_compute =>
            RO_PUF_Internal_RST <= '0';
            sha128_simple_START <= '1';
            sha128_simple_RESET <= '0';
            SWITCHES_buffer_w   <= '0';
         WHEN done =>
            RO_PUF_Internal_RST <= '0';
            sha128_simple_START <= '0';
            sha128_simple_RESET <= '0';
            SWITCHES_buffer_w   <= '0';
      END CASE;
   END PROCESS;
   
END Behavioral;
