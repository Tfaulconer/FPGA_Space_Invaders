----------------------------------------------------------------------------------
-- Name:	Tom Faulconer
-- Date:	Spring 2020
-- Course: 	CSCE 436
-- File: 	col_counter.vhd
-- HW:		Lab Final
-- Purp:	Create a VGA controller that generates a game display which consists of
-- 			a white boundary, player ship, bullets, and aliens
--
-- Doc:	I did not assist anyone
-- 		Professor Falkinburg helped me via his website, labs and his powerpoints
-- 	
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity col_counter is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           ctrl : in STD_LOGIC; -- this just needs to always count up
           Q : out unsigned (9 downto 0); -- needs to count up to 0 - 799 (10 bit number)
           roll : out STD_LOGIC);
end col_counter;

architecture Behavioral of col_counter is

    signal roll_s : STD_LOGIC;
    signal Q_s : unsigned (9 downto 0);


begin
    
    -----------------------------------------------------------------------------
	--		ctrl
	--		0			hold
	--		1			count up 
	-----------------------------------------------------------------------------
    process(clk)
    begin 
        if rising_edge(clk) then
            if (reset_n = '0') then
                Q_s <= (others => '0');
                roll_s <= '0';
            elsif (ctrl = '0') then
                Q_s <= Q_s;
                roll_s <= '0';
            elsif (ctrl = '1' and  Q_s < 799) then
                Q_s <= Q_s + 1;
                roll_s <= '0';
            elsif (ctrl = '1' and Q_s = 799) then
                Q_s <= (others => '0');
                roll_s <= '1';             
            end if;
        end if;
    end process;
    
    -- CSA
    Q <= Q_s;
    roll <= '1' when (Q_s = 799) else '0';

   
end Behavioral;
