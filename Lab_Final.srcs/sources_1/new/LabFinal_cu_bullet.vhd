----------------------------------------------------------------------------------
-- Name:	Tom Faulconer
-- Date:	Spring 2020
-- Course: 	CSCE 436
-- File: 	LabFinal_cu_bullet.vhd
-- HW:		Lab Final
-- Purp:	Control unit for the bullets and alien/bullet collision
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

entity LabFinal_cu_bullet is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           sw_bullet : in STD_LOGIC_VECTOR (26 downto 0);
           cw_bullet : out STD_LOGIC_VECTOR (20 downto 0));
end LabFinal_cu_bullet;

architecture Behavioral of LabFinal_cu_bullet is
    
    -- Finite State Machine signals
    type state_type is (Reset, WaitForFireCommand, Fire, MoveBulletUp, HitTopBoundary, Win, FullReset,
                        Alien0BottomCollision, Alien1BottomCollision, Alien2BottomCollision, Alien3BottomCollision, Alien4BottomCollision, 
                        Alien0MiddleCollision, Alien1MiddleCollision, Alien2MiddleCollision, Alien3MiddleCollision, Alien4MiddleCollision, 
                        Alien0TopCollision, Alien1TopCollision, Alien2TopCollision, Alien3TopCollision, Alien4TopCollision);
    signal state: state_type;
       
    -- Signal to help us detect alien collisions   
    signal all_alien_en_and_six_1 : std_logic_vector(20 downto 0) := '1' & '1' & '1' & '1' & '1' & '1' & sw_bullet(25) & sw_bullet(24) & sw_bullet(23) & sw_bullet(22) & sw_bullet(21) & 
                                                                      sw_bullet(20) & sw_bullet(19) & sw_bullet(18) & sw_bullet(17) & sw_bullet(16) & 
                                                                      sw_bullet(15) & sw_bullet(14) & sw_bullet(13) & sw_bullet(12) & sw_bullet(11);   
     
    signal all_alien_en : std_logic_vector(14 downto 0) := sw_bullet(25) & sw_bullet(24) & sw_bullet(23) & sw_bullet(22) & sw_bullet(21) & 
                                                                      sw_bullet(20) & sw_bullet(19) & sw_bullet(18) & sw_bullet(17) & sw_bullet(16) & 
                                                                      sw_bullet(15) & sw_bullet(14) & sw_bullet(13) & sw_bullet(12) & sw_bullet(11);  
       
    -- Status Words
    constant bullet_counter : integer := 26; -- used to keep "YOU WIN!" on the screen for a small time -- CALL THIS WIN COUNTER
    constant alien14_en : integer := 25;
    constant alien13_en : integer := 24;
    constant alien12_en : integer := 23;
    constant alien11_en : integer := 22;
    constant alien10_en : integer := 21;
    constant alien9_en : integer := 20;
    constant alien8_en : integer := 19;
    constant alien7_en : integer := 18;
    constant alien6_en : integer := 17;
    constant alien5_en : integer := 16;
    constant alien4_en : integer := 15;
    constant alien3_en : integer := 14;
    constant alien2_en : integer := 13;
    constant alien1_en : integer := 12;
    constant alien0_en : integer := 11;
    
    constant boundary_collision : integer := 10;
    constant col4_collision : integer := 9;
    constant col3_collision : integer := 8;
    constant col2_collision : integer := 7;
    constant col1_collision : integer := 6;
    constant col0_collision : integer := 5;
    constant TopRow_collision : integer := 4;
    constant MiddleRow_collision : integer := 3;
    constant BottomRow_collision : integer := 2;
    
    constant bullet_clk_en : integer := 1;
    constant z_Button : integer := 0;
    
begin


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--  STATUS WORDS:
--  bit 0 = z_button has been pressed                   (1 - z_button is pressed ////  0 - z_button is not pressed)
--  bit 1 = bullet_clk_en                               (1 - enabled //// 0 - not enabled)
--  bit 2 = bottomRow_collision                         (1 - collision //// 0 - no collision)
--  bit 3 = middleRow_collision                         (1 - collision //// 0 - no collision)
--  bit 4 = topRow_collision                            (1 - collision //// 0 - no collision) 
--  bit 5 = col0_collision                              (1 - collision //// 0 - no collision) 
--  bit 6 = col1_collision                              (1 - collision //// 0 - no collision)             
--  bit 7 = col2_collision                              (1 - collision //// 0 - no collision) 
--  bit 8 = col3_collision                              (1 - collision //// 0 - no collision) 
--  bit 9 = col4_collision                              (1 - collision //// 0 - no collision) 
--  bit10 = top boundary hit                            (1 - collision //// 0 - no collision) 
--  bit11 : bit 25 = aliexX_en                          (1 - enable //// 0 - disable) 
--  bit26 = win                                         (1 - win //// 0 - hasn't won yet) 
---------------------------------------------------------------------------------------------------------------------------------------------



    state_process: process(clk)
        begin
            if (rising_edge(clk)) then
                if (reset_n = '0') then
                    state <= Reset;
                elsif (sw_bullet(bullet_clk_en) = '1') then
                    case state is
                        when Reset =>
                            state <= WaitForFireCommand;
                        when WaitForFireCommand =>
                            if (sw_bullet(z_Button) = '1') then
                                state <= Fire;
                            elsif (all_alien_en = "000000000000000") then
                                state <= Win;
                            else 
                                state <= WaitForFireCommand;
                            end if;
                        when Win =>
                            if (sw_bullet(bullet_counter) = '1') then
                                state <= FullReset;
                            else 
                                state <= Win;    
                            end if;    
                        when FullReset =>
                            state <= Reset;        
                        when Fire =>
                            state <= MoveBulletUp;
                        when MoveBulletUp =>
                            if ( sw_bullet(boundary_collision) = '1' ) then
                                state <= HitTopBoundary;
                            elsif( sw_bullet(BottomRow_collision) = '1' AND sw_bullet(col0_collision) = '1' AND sw_bullet(alien10_en) = '1' ) then
                                state <= Alien0BottomCollision;
                            elsif ( sw_bullet(BottomRow_collision) = '1' AND sw_bullet(col1_collision) = '1' AND sw_bullet(alien11_en) = '1' ) then
                                state <= Alien1BottomCollision;
                            elsif ( sw_bullet(BottomRow_collision) = '1' AND sw_bullet(col2_collision) = '1' AND sw_bullet(alien12_en) = '1' ) then
                                state <= Alien2BottomCollision;    
                            elsif ( sw_bullet(BottomRow_collision) = '1' AND sw_bullet(col3_collision) = '1' AND sw_bullet(alien13_en) = '1' ) then
                                state <= Alien3BottomCollision;
                            elsif ( sw_bullet(BottomRow_collision) = '1' AND sw_bullet(col4_collision) = '1' AND sw_bullet(alien14_en) = '1' ) then
                                state <= Alien4BottomCollision;  
                                
                            elsif ( sw_bullet(MiddleRow_collision) = '1' AND sw_bullet(col0_collision) = '1' AND sw_bullet(alien5_en) = '1' ) then
                                state <= Alien0MiddleCollision;
                            elsif ( sw_bullet(MiddleRow_collision) = '1' AND sw_bullet(col1_collision) = '1' AND sw_bullet(alien6_en) = '1' ) then
                                state <= Alien1MiddleCollision;    
                            elsif ( sw_bullet(MiddleRow_collision) = '1' AND sw_bullet(col2_collision) = '1' AND sw_bullet(alien7_en) = '1' ) then
                                state <= Alien2MiddleCollision;
                            elsif ( sw_bullet(MiddleRow_collision) = '1' AND sw_bullet(col3_collision) = '1' AND sw_bullet(alien8_en) = '1' ) then
                                state <= Alien3MiddleCollision;
                            elsif ( sw_bullet(MiddleRow_collision) = '1' AND sw_bullet(col4_collision) = '1' AND sw_bullet(alien9_en) = '1' ) then
                                state <= Alien4MiddleCollision;      
                                    
                            elsif ( sw_bullet(TopRow_collision) = '1' AND sw_bullet(col0_collision) = '1' AND sw_bullet(alien0_en) = '1' ) then
                                state <= Alien0TopCollision;
                            elsif ( sw_bullet(TopRow_collision) = '1' AND sw_bullet(col1_collision) = '1' AND sw_bullet(alien1_en) = '1') then
                                state <= Alien1TopCollision;    
                            elsif ( sw_bullet(TopRow_collision) = '1' AND sw_bullet(col2_collision) = '1' AND sw_bullet(alien2_en) = '1' ) then
                                state <= Alien2TopCollision;
                            elsif ( sw_bullet(TopRow_collision) = '1' AND sw_bullet(col3_collision) = '1' AND sw_bullet(alien3_en) = '1' ) then
                                state <= Alien3TopCollision;
                            elsif ( sw_bullet(TopRow_collision) = '1' AND sw_bullet(col4_collision) = '1'AND sw_bullet(alien4_en) = '1'  ) then
                                state <= Alien4TopCollision;       
                            else 
                                state <= MoveBulletUp;      
                            end if;
                        when HitTopBoundary =>
                            state <= Reset;    
                        when Alien0BottomCollision =>
                            state <= Reset;
                        when Alien1BottomCollision =>
                            state <= Reset;
                        when Alien2BottomCollision =>
                            state <= Reset;        
                        when Alien3BottomCollision =>
                            state <= Reset;
                        when Alien4BottomCollision =>
                            state <= Reset;
                            
                        when Alien0MiddleCollision =>
                            state <= Reset;   
                        when Alien1MiddleCollision =>
                            state <= Reset; 
                        when Alien2MiddleCollision =>
                            state <= Reset;   
                        when Alien3MiddleCollision =>
                            state <= Reset;
                        when Alien4MiddleCollision =>
                            state <= Reset;  
                                  
                        when Alien0TopCollision =>
                            state <= Reset;   
                        when Alien1TopCollision =>
                            state <= Reset; 
                        when Alien2TopCollision =>
                            state <= Reset;   
                        when Alien3TopCollision =>
                            state <= Reset; 
                        when Alien4TopCollision =>
                            state <= Reset;           
                    end case;
               end if;
           end if;
       end process;
                                                     
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--  CONTROL WORDS:
--  bit 0 : bit 14 = aliexX_en                          (1 - enable //// 0 - disable) 
--  bit 15 = bullett_en                                 (1 - enabled //// 0 - not enabled)
--  bit 16 = move bullet up                             (1 - bullet moving up //// 0 - bullet not moving)
--  bit 17 = set bullet_column = player_location        (1 - set bullet_column to player location //// 0 - don't do anything)
--  bit 18 = soft reset bullet                          (1 - reset bullet enable and location //// 0 - don't do anything) 
--  bit 19 = win                                        (1 - Write "YOU WIN!" on screen //// 0 - nothing) 
--  bit 20 = HARD RESET                                 (1 - reset all alien enables //// 0 - nothing)             
----------------------------------------------------------------------------------------------------------------------------------------------    
    
    
    
    
    cw_bullet <= ("001000111111111111111" AND all_alien_en_and_six_1) when state = Reset else 
                 ("010000111111111111111" AND all_alien_en_and_six_1) when state = Win else
                 ("100000111111111111111")                             when state = FullReset else
                 ("000000111111111111111" AND all_alien_en_and_six_1) when state = WaitForFireCommand else
                 ("000101111111111111111" AND all_alien_en_and_six_1) when state = Fire else
                 ("000011111111111111111" AND all_alien_en_and_six_1) when state = MoveBulletUp else
                 ("000000111111111111111" AND all_alien_en_and_six_1) when state = HitTopBoundary else
                 
                 ("000000111101111111111" AND all_alien_en_and_six_1) when state = Alien0BottomCollision else
                 ("000000111011111111111" AND all_alien_en_and_six_1) when state = Alien1BottomCollision else
                 ("000000110111111111111" AND all_alien_en_and_six_1) when state = Alien2BottomCollision else
                 ("000000101111111111111" AND all_alien_en_and_six_1) when state = Alien3BottomCollision else
                 ("000000011111111111111" AND all_alien_en_and_six_1) when state = Alien4BottomCollision else
                 
                 ("000000111111111011111" AND all_alien_en_and_six_1) when state = Alien0MiddleCollision else
                 ("000000111111110111111" AND all_alien_en_and_six_1) when state = Alien1MiddleCollision else
                 ("000000111111101111111" AND all_alien_en_and_six_1) when state = Alien2MiddleCollision else
                 ("000000111111011111111" AND all_alien_en_and_six_1) when state = Alien3MiddleCollision else
                 ("000000111110111111111" AND all_alien_en_and_six_1) when state = Alien4MiddleCollision else
                 
                 ("000000111111111111110" AND all_alien_en_and_six_1) when state = Alien0TopCollision else
                 ("000000111111111111101" AND all_alien_en_and_six_1) when state = Alien1TopCollision else
                 ("000000111111111111011" AND all_alien_en_and_six_1) when state = Alien2TopCollision else
                 ("000000111111111110111" AND all_alien_en_and_six_1) when state = Alien3TopCollision else
                 ("000000111111111101111" AND all_alien_en_and_six_1) when state = Alien4TopCollision;
        
end Behavioral;