----------------------------------------------------------------------------------
-- Name:	Tom Faulconer
-- Date:	Spring 2020
-- Course: 	CSCE 436
-- File: 	LabFinal_cu.vhd
-- HW:		Lab Final
-- Purp:	Control unit for the aliens moving
-- 			
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

entity LabFinal_cu is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (3 downto 0);
           cw : out STD_LOGIC_VECTOR (3 downto 0));
end LabFinal_cu;

architecture Behavioral of LabFinal_cu is
    
    -- Finite State Machine signals
    type state_type is (Reset, MoveRight, WaitForEnableR, HitRBoundary, DecreaseRowR, MoveLeft, WaitForEnableL, HitLBoundary, DecreaseRowL);
    signal state: state_type;
    
    
    signal alien_counter : unsigned(21 downto 0) := (others => '0');
    signal alien_clk_enable : std_logic;
    
    -- Status Words
    constant alienBottomRow_row :  integer := 3; 
    constant alien0_col :  integer := 2; 
    constant alien4_col :  integer := 1; 
    constant alien_clk_en :      integer := 0;
    
begin

-- UPDATE THIS
--------------------------------------------------------------------
--                 Status Words
--                   btn                               ready                
--               bit[5:1]                              bit 0              
--               "00001"    incr ampl.                 0 - not ready          
--               "00010"    decr. phase
--               "00100"    incr. phase                1 - ready (new sample)       
--               "01000"    decr. ampl.
--               "10000"    change waveform
--
--------------------------------------------------------------------    



    state_process: process(clk)
        begin
            if (rising_edge(clk)) then
                if (reset_n = '0') then
                    state <= Reset;
                elsif (sw(alien_clk_en) = '1') then
                    case state is
                        when Reset =>
                            state <= MoveRight;
                        when MoveRight =>
                            state <= WaitForEnableR;
                        when WaitForEnableR =>
                            if (sw(alien4_col) = '1') then
                                state <= HitRBoundary;
                            else 
                                state <= MoveRight;
                            end if;
                        when HitRBoundary =>
                            state <= DecreaseRowR;
                        when DecreaseRowR =>
                            state <= MoveLeft;
                        when MoveLeft =>
                            state <= WaitForEnableL;
                        when WaitForEnableL =>
                            if (sw(alien0_col) = '1') then
                                state <= HitLBoundary;   
                            else 
                                state <= MoveLeft;
                            end if;
                        when HitLBoundary =>
                            state <= DecreaseRowL;
                        when DecreaseRowL =>
                            if (sw(alienBottomRow_row) = '1') then
                                state <= Reset; 
                            else 
                                state <= MoveRight;
                            end if;      
                    end case;
               end if;
           end if;
       end process;
                                                     


	--------------------------------------------------------------------------------------------------------------------------------------
    --                          OUTPUT EQUATIONS 
	--		    bit 3                 bit 2                          bit 1                         bit 0                   
	--		    RESET                 decrease row                  move right                     move left               			
	--          0      dont reset     0  don't decrease row         0   don't move aliens right    0  dont move aliens left            
    --          1      RESET          1  move aliens dwn 1 row      1   move aliens right          1  move aliens left               
	--
	-------------------------------------------------------------------------------------------------------------------------------------- 
    cw <= "1000" when state = Reset else -- Reset = 1 which means we need to return aliens and ship to all default locations
          "0010" when state = MoveRight else
          "0000" when state = WaitForEnableR else
          "0000" when state = HitRBoundary else
          "0100" when state = DecreaseRowR else
          "0001" when state = MoveLeft else
          "0000" when state = WaitForEnableL else
          "0000" when state = HitLBoundary else
          "0100" when state = DecreaseRowL;
        
end Behavioral;
