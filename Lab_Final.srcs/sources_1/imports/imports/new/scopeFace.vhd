----------------------------------------------------------------------------------
-- Name:	Tom Faulconer
-- Date:	Spring 2020
-- Course: 	CSCE 436
-- File: 	scopeFace.vhd
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

entity scopeFace is
    Port ( row : in  unsigned(9 downto 0);
           column : in  unsigned(9 downto 0);
		   player_location : in unsigned (9 downto 0);
                r : out  std_logic_vector(7 downto 0);
                g : out  std_logic_vector(7 downto 0);
                b : out  std_logic_vector(7 downto 0);
                
           bullet_col : in unsigned (9 downto 0);
		   bullet_row : in unsigned (8 downto 0); -- It's a row between 70 - 367 (367 is top of ship) (2^9 = 512)
			                                            -- bullet will be 4 pixels long bullet_location should be at the bottom
           bullet_en : in std_logic;
            
           alienTopRow_row : in unsigned(8 downto 0); -- := x"5A"; -- only values are less than 2^9 = 512   x"5A" = 90
           alien0_col : in unsigned(8 downto 0); -- Tells the position of alien 0
           alien0_en : in std_logic;
           alien1_col: in unsigned(8 downto 0); -- Tells the position of alien 1
           alien1_en : in std_logic;
           alien2_col : in unsigned(8 downto 0); -- Tells the position of alien 2
           alien2_en : in std_logic;
           alien3_col : in unsigned(8 downto 0); -- Tells the position of alien 3
           alien3_en : in std_logic;
           alien4_col : in unsigned(8 downto 0); -- Tells the position of alien 4
           alien4_en : in std_logic;
            
           alienMiddleRow_row : in unsigned(8 downto 0); 
           alien5_en : in std_logic;
           alien6_en : in std_logic;
           alien7_en : in std_logic;
           alien8_en : in std_logic;
           alien9_en : in std_logic;
            
           alienBottomRow_row : in unsigned(8 downto 0); 
           alien10_en : in std_logic;
           alien11_en : in std_logic;
           alien12_en : in std_logic;
           alien13_en : in std_logic;
           alien14_en : in std_logic;
           n_bits : in integer;
           win : in std_logic
           );
end scopeFace;

architecture Behavioral of scopeFace is
    
    signal grid_boundary_row : std_logic;
    signal grid_boundary_col : std_logic;
--    signal grid_player_location : std_logic;

    signal score_text : std_logic;
    signal score_0 : std_logic;
    signal score_1 : std_logic;
    signal score_2 : std_logic;
    signal score_3 : std_logic;
    signal score_4 : std_logic;
    signal score_5 : std_logic;
    signal score_6 : std_logic;
    signal score_7 : std_logic;
    signal score_8 : std_logic;
    signal score_9 : std_logic;
    signal score_10 : std_logic;
    signal score_11 : std_logic;
    signal score_12 : std_logic;
    signal score_13 : std_logic;
    signal score_14 : std_logic;
    signal score_15 : std_logic;
    
    signal score_win : std_logic;
    
    signal grid_player_location_white : std_logic;
    signal grid_player_location_red : std_logic;
    signal grid_player_location_blue: std_logic;
    signal grid_bullet_location : std_logic;
    signal grid_bullet : std_logic;
    signal grid_alien0 : std_logic;
    signal grid_alien1 : std_logic;
    signal grid_alien2 : std_logic;
    signal grid_alien3 : std_logic;
    signal grid_alien4 : std_logic;
    signal grid_alien5 : std_logic;
    signal grid_alien6 : std_logic;
    signal grid_alien7 : std_logic;
    signal grid_alien8 : std_logic;
    signal grid_alien9 : std_logic;
    signal grid_alien10 : std_logic;
    signal grid_alien11 : std_logic;
    signal grid_alien12 : std_logic;
    signal grid_alien13 : std_logic;
    signal grid_alien14 : std_logic;
    
    signal start_you_win_text : unsigned(9 downto 0) := "0100010010"; -- Decimal value = 274

begin

    -- CSA's
    
    -- (column, row)
    -- Draw white boundary TopLeft (200,70) -> TopRight (440,70) -> BottomLeft (200,370) -> BottomRight(440,370)
    -- Draw the boundary rows
    grid_boundary_row <= '1' when (( (row = 70) OR (row = 370) ) AND ( (column >= 200) AND (column <= 440) )) else '0';
    
    -- Draw white boundary columns
    grid_boundary_col <= '1' when ( ((column = 200) OR (column = 440)) AND (row >= 70 AND row <= 370) ) else '0';
    
    -- Draw "Score" at the top of the boundary
    score_text <= '1' when ( ((column = 365) and (row = 53 or row = 54 or row = 55 or row = 65)) OR
                             ((column = 366) and (row = 66 or row = 56 or row = 52)) OR
                             ((column = 367) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 368) and (row = 67 or row = 58 or row = 51)) OR
                             ((column = 369) and (row = 67 or row = 59 or row = 51)) OR
                             ((column = 370) and (row = 67 or row = 60 or row = 51)) OR
                             ((column = 371) and (row = 67 or row = 61 or row = 51)) OR
                             ((column = 372) and (row = 66 or row = 62 or row = 52)) OR
                             ((column = 373) and (row = 65 or row = 64 or row = 63 or row = 53)) OR -- "S" end
                             
                             ((column = 376) and (row >= 58 and row <= 65)) OR -- "c" start
                             ((column = 377) and (row = 66 or row = 57)) OR
                             ((column = 378) and (row = 67 or row = 56)) OR
                             ((column = 379) and (row = 67 or row = 56)) OR
                             ((column = 380) and (row = 67 or row = 56)) OR
                             ((column = 381) and (row = 66 or row = 57)) OR
                             ((column = 382) and (row = 65 or row = 58)) OR
                             
                             ((column = 385) and (row >= 58 and row <= 65)) OR -- "o" start
                             ((column = 386) and (row = 66 or row = 57)) OR
                             ((column = 387) and (row = 67 or row = 56)) OR
                             ((column = 388) and (row = 67 or row = 56)) OR
                             ((column = 389) and (row = 67 or row = 56)) OR
                             ((column = 390) and (row = 66 or row = 57)) OR
                             ((column = 391) and (row >= 58 and row <= 65)) OR
                             
                             ((column = 394) and (row >= 58 and row <= 67)) OR -- "r" start
                             ((column = 395) and (row = 57)) OR
                             ((column = 396) and (row = 56)) OR
                             ((column = 397) and (row = 56)) OR
                             ((column = 398) and (row = 56)) OR
                             ((column = 399) and (row = 57)) OR

                             ((column = 402) and (row >= 58 and row <= 65)) OR -- "e" start
                             ((column = 403) and (row = 57 or row = 60 or row = 66)) OR
                             ((column = 404) and (row = 56 or row = 60 or row = 67)) OR
                             ((column = 405) and (row = 56 or row = 60 or row = 67)) OR
                             ((column = 406) and (row = 56 or row = 60 or row = 67)) OR
                             ((column = 407) and (row = 57 or row = 60 or row = 66)) OR
                             ((column = 408) and (row = 58 or row = 60 or row = 65)) OR
                             ((column = 409) and (row = 59 or row = 60)) 

                             ) else '0';
    
    -- Draw 0
    score_0 <= '1' when ( (((column = 417) and (row >= 51 and row <= 67)) OR 
                             ((column = 418) and (row = 67 or row = 51)) OR
                             ((column = 419) and (row = 67 or row = 51)) OR
                             ((column = 420) and (row = 67 or row = 51)) OR
                             ((column = 421) and (row = 67 or row = 51)) OR
                             ((column = 422) and (row = 67 or row = 51)) OR
                             ((column = 423) and (row = 67 or row = 51)) OR
                             ((column = 424) and (row >= 51 and row <= 67))) AND 
                             (n_bits = 0) 
                             ) else '0';
                             
     -- Draw 1
    score_1 <= '1' when (    (((column = 417) and (row = 67 )) OR 
                             ((column = 418) and (row = 67 or row = 53)) OR
                             ((column = 419) and (row = 67 or row = 52)) OR
                             ((column = 420) and (row <= 67 and row >= 51)) OR
                             ((column = 421) and (row = 67 )) OR 
                             ((column = 422) and (row = 67 )) OR 
                             ((column = 423) and (row = 67))) AND 
                             (n_bits = 1) 
                             ) else '0';     
    -- Draw 2
    score_2 <= '1' when (    (((column = 417) and (row = 67 or row = 66 or row = 53)) OR 
                             ((column = 418) and (row = 67 or row = 65 or row = 52)) OR
                             ((column = 419) and (row = 67 or row = 64 or row = 51)) OR
                             ((column = 420) and (row = 67 or row = 63 or row = 51)) OR
                             ((column = 421) and (row = 67 or row = 62 or row = 51)) OR
                             ((column = 422) and (row = 67 or row = 61 or row = 51)) OR
                             ((column = 423) and (row = 67 or row = 60 or row = 51)) OR
                             ((column = 424) and (row = 67 or row = 59 or row = 51)) OR
                             ((column = 425) and (row = 67 or row = 58 or row = 51)) OR
                             ((column = 426) and (row = 67 or row = 57 or row = 52)) OR
                             ((column = 427) and (row = 67 or row = 56 or row = 55 or row = 54 or row = 53))) AND 
                             (n_bits = 2) 
                             ) else '0'; 
      
    -- Draw 3
    score_3 <= '1' when (    (((column = 417) and (row = 67 or row = 51)) OR 
                             ((column = 418) and (row = 67 or row = 51)) OR
                             ((column = 419) and (row = 67 or row = 51)) OR 
                             ((column = 420) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 421) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 422) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 423) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 424) and (row <= 67 and row >= 51))) AND 
                             (n_bits = 3) 
                             ) else '0';     
                             
    -- Draw 4
    score_4 <= '1' when (    (((column = 417) and (row = 60 or row = 59)) OR 
                             ((column = 418) and (row = 60 or row = 58)) OR
                             ((column = 419) and (row = 60 or row = 57)) OR 
                             ((column = 420) and (row = 60 or row = 56)) OR 
                             ((column = 421) and (row = 60 or row = 55)) OR
                             ((column = 422) and (row = 60 or row = 54)) OR 
                             ((column = 423) and (row = 60 or row = 53)) OR 
                             ((column = 424) and (row = 60 or row = 52)) OR
                             ((column = 425) and (row <= 67 and row >= 51)) OR
                             ((column = 426) and (row = 60)) OR 
                             ((column = 427) and (row = 60))) AND 
                             (n_bits = 4) 
                             ) else '0';        
                             
     -- Draw 5
    score_5 <= '1' when (    (((column = 417) and (row = 67 or row = 57 or row = 56 or row = 55 or row = 54 or row = 53 or row = 52 or row = 51)) OR 
                             ((column = 418) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 419) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 420) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 421) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 422) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 423) and (row = 67 or row = 57 or row = 51)) OR 
                             ((column = 424) and ((row <= 67 and row >= 57) or row = 51))) AND 
                             (n_bits = 5) 
                             ) else '0';                                                                
       
     -- Draw 6
    score_6 <= '1' when (    (((column = 417) and (row <= 67 and row >= 51)) OR 
                             ((column = 418) and (row = 67 or row = 59 or row = 51)) OR
                             ((column = 419) and (row = 67 or row = 59 or row = 51)) OR
                             ((column = 420) and (row = 67 or row = 59 or row = 51)) OR
                             ((column = 421) and (row = 67 or row = 59 or row = 51)) OR
                             ((column = 422) and (row = 67 or row = 59 or row = 51)) OR
                             ((column = 423) and (row = 67 or row = 59 or row = 51)) OR 
                             ((column = 424) and (row <= 67 and row >= 59))) AND 
                             (n_bits = 6) 
                             ) else '0';                                                                 
    
    
    -- Draw 7
    score_7 <= '1' when (    (((column = 417) and (row = 51)) OR 
                             ((column = 418) and (row = 51)) OR  
                             ((column = 419) and (row = 51)) OR 
                             ((column = 420) and (row = 51)) OR 
                             ((column = 421) and (row = 51)) OR 
                             ((column = 422) and (row = 51)) OR 
                             ((column = 423) and (row = 51)) OR 
                             ((column = 424) and (row <= 67 and row >= 51))) AND 
                             (n_bits = 7) 
                             ) else '0'; 
    
    -- Draw 8
    score_8 <= '1' when (    (((column = 417) and (row <= 67 and row >= 51)) OR 
                             ((column = 418) and (row = 51 or row = 59 or row = 67)) OR  
                             ((column = 419) and (row = 51 or row = 59 or row = 67)) OR  
                             ((column = 420) and (row = 51 or row = 59 or row = 67)) OR  
                             ((column = 421) and (row = 51 or row = 59 or row = 67)) OR  
                             ((column = 422) and (row = 51 or row = 59 or row = 67)) OR  
                             ((column = 423) and (row = 51 or row = 59 or row = 67)) OR  
                             ((column = 424) and (row <= 67 and row >= 51))) AND 
                             (n_bits = 8) 
                             ) else '0'; 
                             
                             
   -- Draw 9
    score_9 <= '1' when (    (((column = 417) and (row <= 59 and row >= 51)) OR 
                             ((column = 418) and (row = 51 or row = 59)) OR  
                             ((column = 419) and (row = 51 or row = 59)) OR  
                             ((column = 420) and (row = 51 or row = 59)) OR  
                             ((column = 421) and (row = 51 or row = 59)) OR  
                             ((column = 422) and (row = 51 or row = 59)) OR  
                             ((column = 423) and (row = 51 or row = 59)) OR  
                             ((column = 424) and (row <= 67 and row >= 51))) AND 
                             (n_bits = 9) 
                             ) else '0';                           
    
    -- Draw 10
    score_10 <= '1' when (    (((column = 417) and (row = 67 )) OR          -- 1
                             ((column = 418) and (row = 67 or row = 53)) OR
                             ((column = 419) and (row = 67 or row = 52)) OR
                             ((column = 420) and (row <= 67 and row >= 51)) OR
                             ((column = 421) and (row = 67 )) OR 
                             ((column = 422) and (row = 67 )) OR 
                             ((column = 423) and (row = 67)) OR     
                             ((column = 424) and (row >= 51 and row <= 67)) OR  -- 0
                             ((column = 425) and (row = 67 or row = 51)) OR
                             ((column = 426) and (row = 67 or row = 51)) OR
                             ((column = 427) and (row = 67 or row = 51)) OR
                             ((column = 428) and (row = 67 or row = 51)) OR
                             ((column = 429) and (row = 67 or row = 51)) OR
                             ((column = 430) and (row = 67 or row = 51)) OR
                             ((column = 431) and (row >= 51 and row <= 67))) AND 
                             (n_bits = 10) 
                             ) else '0';    
    
    -- Draw 11
    score_11 <= '1' when (    (((column = 417) and (row = 67 )) OR              -- 1
                             ((column = 418) and (row = 67 or row = 53)) OR
                             ((column = 419) and (row = 67 or row = 52)) OR
                             ((column = 420) and (row <= 67 and row >= 51)) OR
                             ((column = 421) and (row = 67 )) OR 
                             ((column = 422) and (row = 67 )) OR 
                             ((column = 423) and (row = 67)) OR                 -- 1
                             ((column = 424) and (row = 67 )) OR 
                             ((column = 425) and (row = 67 or row = 53)) OR
                             ((column = 426) and (row = 67 or row = 52)) OR
                             ((column = 427) and (row <= 67 and row >= 51)) OR
                             ((column = 428) and (row = 67 )) OR 
                             ((column = 429) and (row = 67 )) OR 
                             ((column = 430) and (row = 67))) AND 
                             (n_bits = 11) 
                             ) else '0';  
    
    -- Draw 12
    score_12 <= '1' when (   (((column = 417) and (row = 67 )) OR                       --1
                             ((column = 418) and (row = 67 or row = 53)) OR
                             ((column = 419) and (row = 67 or row = 52)) OR
                             ((column = 420) and (row <= 67 and row >= 51)) OR
                             ((column = 421) and (row = 67 )) OR 
                             ((column = 422) and (row = 67 )) OR 
                             ((column = 423) and (row = 67)) OR                             --2
                             ((column = 424) and (row = 67 or row = 66 or row = 53)) OR 
                             ((column = 425) and (row = 67 or row = 65 or row = 52)) OR
                             ((column = 426) and (row = 67 or row = 64 or row = 51)) OR
                             ((column = 427) and (row = 67 or row = 63 or row = 51)) OR
                             ((column = 428) and (row = 67 or row = 62 or row = 51)) OR
                             ((column = 429) and (row = 67 or row = 61 or row = 51)) OR
                             ((column = 430) and (row = 67 or row = 60 or row = 51)) OR
                             ((column = 431) and (row = 67 or row = 59 or row = 51)) OR
                             ((column = 432) and (row = 67 or row = 58 or row = 51)) OR
                             ((column = 433) and (row = 67 or row = 57 or row = 52)) OR
                             ((column = 434) and (row = 67 or row = 56 or row = 55 or row = 54 or row = 53))) AND 
                             (n_bits = 12) 
                             ) else '0'; 
                             
      -- Draw 13
    score_13 <= '1' when (    (((column = 417) and (row = 67 )) OR       --1
                             ((column = 418) and (row = 67 or row = 53)) OR
                             ((column = 419) and (row = 67 or row = 52)) OR
                             ((column = 420) and (row <= 67 and row >= 51)) OR
                             ((column = 421) and (row = 67 )) OR 
                             ((column = 422) and (row = 67 )) OR 
                             ((column = 423) and (row = 67)) OR                     
                             ((column = 424) and (row = 67 or row = 51)) OR             --3
                             ((column = 425) and (row = 67 or row = 51)) OR
                             ((column = 426) and (row = 67 or row = 51)) OR 
                             ((column = 427) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 428) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 429) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 430) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 431) and (row <= 67 and row >= 51))) AND 
                             (n_bits = 13) 
                             ) else '0';
                             
    -- Draw 14
    score_14 <= '1' when (   (((column = 417) and (row = 67 )) OR                   -- 1
                             ((column = 418) and (row = 67 or row = 53)) OR
                             ((column = 419) and (row = 67 or row = 52)) OR
                             ((column = 420) and (row <= 67 and row >= 51)) OR
                             ((column = 421) and (row = 67 )) OR 
                             ((column = 422) and (row = 67 )) OR 
                             ((column = 423) and (row = 67)) OR                  
                             ((column = 424) and (row = 60 or row = 59)) OR   -- 4
                             ((column = 425) and (row = 60 or row = 58)) OR
                             ((column = 426) and (row = 60 or row = 57)) OR 
                             ((column = 427) and (row = 60 or row = 56)) OR 
                             ((column = 428) and (row = 60 or row = 55)) OR
                             ((column = 429) and (row = 60 or row = 54)) OR 
                             ((column = 430) and (row = 60 or row = 53)) OR 
                             ((column = 431) and (row = 60 or row = 52)) OR
                             ((column = 432) and (row <= 67 and row >= 51)) OR
                             ((column = 433) and (row = 60)) OR 
                             ((column = 434) and (row = 60))) AND 
                             (n_bits = 14) 
                             ) else '0'; 
                             
    -- Draw 15
    score_15 <= '1' when (    (((column = 417) and (row = 67 )) OR      -- 1
                             ((column = 418) and (row = 67 or row = 53)) OR
                             ((column = 419) and (row = 67 or row = 52)) OR
                             ((column = 420) and (row <= 67 and row >= 51)) OR
                             ((column = 421) and (row = 67 )) OR 
                             ((column = 422) and (row = 67 )) OR 
                             ((column = 423) and (row = 67)) OR  --5                      
                             ((column = 424) and (row = 67 or row = 57 or row = 56 or row = 55 or row = 54 or row = 53 or row = 52 or row = 51)) OR 
                             ((column = 425) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 426) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 427) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 428) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 429) and (row = 67 or row = 57 or row = 51)) OR
                             ((column = 430) and (row = 67 or row = 57 or row = 51)) OR 
                             ((column = 431) and ((row <= 67 and row >= 57) or row = 51))) AND 
                             (n_bits = 15) 
                             ) else '0';    
                             
    -- Print "YOU WIN!" on the screen
    score_win <= '1' when (  (((column = start_you_win_text) and (row = 137 )) OR      -- Y
                             ((column = start_you_win_text+1) and (row = 138)) OR
                             ((column = start_you_win_text+2) and (row = 139)) OR
                             ((column = start_you_win_text+3) and (row = 140)) OR
                             ((column = start_you_win_text+4) and (row = 141)) OR 
                             ((column = start_you_win_text+5) and (row = 142)) OR 
                             ((column = start_you_win_text+6) and (row = 143)) OR                       
                             ((column = start_you_win_text+7) and (row <= 154 and row >= 144 )) OR 
                             ((column = start_you_win_text+8) and (row = 143)) OR
                             ((column = start_you_win_text+9) and (row = 142)) OR
                             ((column = start_you_win_text+10) and (row = 141)) OR
                             ((column = start_you_win_text+11)and (row = 140)) OR
                             ((column = start_you_win_text+12) and (row = 139)) OR
                             ((column = start_you_win_text+13) and (row = 138)) OR 
                             ((column = start_you_win_text+14) and (row = 137)) OR 
                             
                             ((column = start_you_win_text+17) and (row <= 152 and row >= 139)) OR      -- O
                             ((column = start_you_win_text+18) and (row = 153 or row = 138)) OR
                             ((column = start_you_win_text+19) and (row = 154 or row = 137)) OR
                             ((column = start_you_win_text+20) and (row = 154 or row = 137)) OR
                             ((column = start_you_win_text+21) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+22) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+23) and (row = 154 or row = 137)) OR                       
                             ((column = start_you_win_text+24) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+25) and (row = 154 or row = 137)) OR
                             ((column = start_you_win_text+26) and (row = 153 or row = 138)) OR
                             ((column = start_you_win_text+27) and (row <= 152 and row >= 139)) OR
                             
                             ((column = start_you_win_text+30) and (row <= 152 and row >= 137)) OR      -- U
                             ((column = start_you_win_text+31) and (row = 153)) OR
                             ((column = start_you_win_text+32) and (row = 154)) OR
                             ((column = start_you_win_text+33) and (row = 154)) OR
                             ((column = start_you_win_text+34) and (row = 154)) OR 
                             ((column = start_you_win_text+35) and (row = 154)) OR 
                             ((column = start_you_win_text+36) and (row = 154)) OR                       
                             ((column = start_you_win_text+37) and (row = 154)) OR 
                             ((column = start_you_win_text+38) and (row = 154)) OR
                             ((column = start_you_win_text+39) and (row = 153)) OR
                             ((column = start_you_win_text+40) and (row <= 152 and row >= 137)) OR
                             
                             
                             ((column = start_you_win_text+46) and (row <= 152 and row >= 137)) OR      -- W
                             ((column = start_you_win_text+47) and (row = 153)) OR
                             ((column = start_you_win_text+48) and (row = 154)) OR
                             ((column = start_you_win_text+49) and (row = 154)) OR
                             ((column = start_you_win_text+50) and (row = 153 or row = 152)) OR 
                             ((column = start_you_win_text+51) and (row <= 152 and row >= 149)) OR 
                             ((column = start_you_win_text+52) and (row = 152 or row = 153)) OR                       
                             ((column = start_you_win_text+53) and (row = 154)) OR 
                             ((column = start_you_win_text+54) and (row = 154)) OR
                             ((column = start_you_win_text+55) and (row = 153)) OR
                             ((column = start_you_win_text+56) and (row <= 152 and row >= 137)) OR
                             
                             ((column = start_you_win_text+59) and (row = 154 or row = 137)) OR      -- I
                             ((column = start_you_win_text+60) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+61) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+62) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+63) and (row = 154 or row = 137)) OR  
                             ((column = start_you_win_text+64) and (row <= 154 and row >= 137)) OR 
                             ((column = start_you_win_text+65) and (row = 154 or row = 137)) OR                        
                             ((column = start_you_win_text+66) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+67) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+68) and (row = 154 or row = 137)) OR 
                             ((column = start_you_win_text+69) and (row = 154 or row = 137)) OR 
                             
                             ((column = start_you_win_text+72) and (row <= 154 and row >= 137)) OR      -- N
                             ((column = start_you_win_text+73) and (row = 138)) OR 
                             ((column = start_you_win_text+74) and (row = 139)) OR 
                             ((column = start_you_win_text+75) and (row = 140 or row = 141)) OR 
                             ((column = start_you_win_text+76) and (row = 142)) OR  
                             ((column = start_you_win_text+77) and (row = 143 or row = 144)) OR 
                             ((column = start_you_win_text+78) and (row = 144 or row = 145)) OR                        
                             ((column = start_you_win_text+79) and (row = 146)) OR 
                             ((column = start_you_win_text+80) and (row = 147 or row = 148)) OR 
                             ((column = start_you_win_text+81) and (row = 148 or row = 149)) OR 
                             ((column = start_you_win_text+82) and (row = 150 or row = 151)) OR 
                             ((column = start_you_win_text+83) and (row = 151 or row = 152)) OR 
                             ((column = start_you_win_text+84) and (row = 153)) OR 
                             ((column = start_you_win_text+85) and (row <= 154 and row >= 137)) OR 
                             
                             ((column = start_you_win_text+88) and ((row <= 154 and row >= 152) OR (row <= 148 and row >= 137))) OR      -- !
                             ((column = start_you_win_text+89) and ((row <= 154 and row >= 152) OR (row <= 148 and row >= 137))) OR
                             ((column = start_you_win_text+90) and ((row <= 154 and row >= 152) OR (row <= 148 and row >= 137)))
                             ) AND 
                             (win = '1') 
                             ) else '0';                        
                             
                             
    -- Draw the player ship based on the location
--    grid_player_location <= '1' when ( ((column = player_location-3) and (row = 370)) OR 
--                                       ((column = player_location-2) and (row = 370)) OR ((column = player_location-2) and (row = 369)) OR 
--                                       ((column = player_location-1) and (row = 370)) OR ((column = player_location-1) and (row = 369)) OR ((column = player_location-1) and (row = 368)) OR
--                                       ((column = player_location) and (row = 370)) OR ((column = player_location) and (row = 369)) OR ((column = player_location) and (row = 368)) OR ((column = player_location) and (row = 367)) OR
--                                       ((column = player_location+1) and (row = 370)) OR ((column = player_location+1) and (row = 369)) OR ((column = player_location+1) and (row = 368)) OR
--                                       ((column = player_location+2) and (row = 370)) OR ((column = player_location+2) and (row = 369)) OR
--                                       ((column = player_location+3) and (row = 370)) ) else '0';   

    grid_player_location_white <= '1' when ( ((column = player_location-8) and (row >= 361 and row <= 364)) OR   
                                       ((column = player_location+8) and (row >= 361 and row <= 364)) OR 
                                       ((column = player_location-7) and (row = 364)) OR 
                                       ((column = player_location+7) and (row = 364)) OR 
                                       ((column = player_location-6) and (row = 364)) OR 
                                       ((column = player_location+6) and (row = 364)) OR 
                                       ((column = player_location-5) and (row = 364 or row = 363)) OR
                                       ((column = player_location+5) and (row = 364 or row = 363)) OR
                                       ((column = player_location-4) and (row = 364 or row = 363 or row = 361 or row = 360 or row = 359)) OR
                                       ((column = player_location+4) and (row = 364 or row = 363 or row = 361 or row = 360 or row = 359)) OR
                                       ((column = player_location-3) and (row = 364 or row = 363 or row = 362)) OR
                                       ((column = player_location+3) and (row = 364 or row = 363 or row = 362)) OR
                                       ((column = player_location-3) and (row = 364 or row = 363 or row = 362)) OR
                                       ((column = player_location+3) and (row = 364 or row = 363 or row = 362)) OR
                                       ((column = player_location-2) and (row >= 359 and row <= 363)) OR
                                       ((column = player_location+2) and (row >= 359 and row <= 363)) OR
                                       ((column = player_location-1) and ((row >= 363 and row <= 365) OR (row <= 360 and row >= 353))) OR
                                       ((column = player_location+1) and ((row >= 363 and row <= 365) OR (row <= 360 and row >= 353))) OR
                                       ((column = player_location) and ((row >= 362 and row <= 367) OR (row <= 359 and row >= 349))) ) else '0';   
    
    grid_player_location_red <= '1' when ( ((column = player_location-8) and (row = 359 or row = 360)) OR   -- Drawing the bottom of the ship upwards 
                                       ((column = player_location+8) and (row = 359 or row = 360)) OR
                                       ((column = player_location-4) and (row = 357 or row = 358)) OR
                                       ((column = player_location+4) and (row = 357 or row = 358)) OR
                                       ((column = player_location+3) and (row = 365 or row = 366)) OR 
                                       ((column = player_location-3) and (row = 365 or row = 366)) OR 
                                       ((column = player_location-2) and (row <= 366 and row >= 364)) OR   -- Drawing the bottom of the ship upwards 
                                       ((column = player_location+2) and (row <= 366 and row >= 364)) OR 
                                       ((column = player_location-1) and (row = 361 or row = 362)) OR 
                                       ((column = player_location+1) and (row = 361 or row = 362)) OR 
                                       ((column = player_location) and (row = 361 or row = 360)) ) else '0';  
                                       
    grid_player_location_blue <= '1' when ( ((column = player_location-3) and (row = 361)) OR   -- Drawing the bottom of the ship upwards 
                                       ((column = player_location+3) and (row = 361)) OR
                                       ((column = player_location-4) and (row = 362)) OR
                                       ((column = player_location+4) and (row = 362)) ) else '0';                                     
    
    -- Draw the bullet (Z button is to fire)
    grid_bullet_location <= '1' when ( ( ((row = bullet_row-5) AND (column = bullet_col)) OR ((row = bullet_row-4) AND (column = bullet_col)) OR ((row = bullet_row-3) AND (column = bullet_col)) OR ((row = bullet_row-2) AND (column = bullet_col)) OR ((row = bullet_row-1) AND (column = bullet_col)) OR ((row = bullet_row) AND (column = bullet_col)) ) 
                                        AND (bullet_en = '1') 
                                        AND (row > 70 AND row < 370)) else '0';
    
    -- Draw the Top row of aliens
    -- Alien is 8 rows tall and 11 columns wide
    
    -- Alien 0
    grid_alien0 <= '1' when ( ((row = alienTopRow_row-3) and (column = alien0_col-3)) OR -- top row of alien
                             ((row = alienTopRow_row-3) and (column = alien0_col+3)) OR 
                             ((row = alienTopRow_row-2) and (column = alien0_col-2)) OR -- 2nd row of alien
                             ((row = alienTopRow_row-2) and (column = alien0_col+2)) OR                      
                             ((row = alienTopRow_row-1) and ((column >= alien0_col-3) and (column <= alien0_col+3))) OR -- third row of alien
                             ((row = alienTopRow_row) and ((column >= alien0_col-4) and (column < alien0_col-2))) or  -- fourth row of alien
                             ((row = alienTopRow_row) and ((column >= alien0_col-1) and (column <= alien0_col+1))) or 
                             ((row = alienTopRow_row) and ((column >= alien0_col+3) and (column <= alien0_col+4))) OR 
                             ((row = alienTopRow_row+1) and ((column >= alien0_col-5) and (column <= alien0_col+5))) OR -- fifth row of alien
                             ((row = alienTopRow_row+2) and (column = alien0_col-5)) or -- sixth row
                             ((row = alienTopRow_row+2) and (column = alien0_col+5)) or
                             ((row = alienTopRow_row+2) and ((column >= alien0_col-3) and (column <= alien0_col+3))) OR
                             ((row = alienTopRow_row+3) and (column = alien0_col-5)) OR  -- seventh row
                             ((row = alienTopRow_row+3) and (column = alien0_col-3)) OR
                             ((row = alienTopRow_row+3) and (column = alien0_col+3)) OR
                             ((row = alienTopRow_row+3) and (column = alien0_col+5)) OR
                             ((row = alienTopRow_row+4) and (column = alien0_col-2)) OR -- last row of alien
                             ((row = alienTopRow_row+4) and (column = alien0_col-1)) OR
                             ((row = alienTopRow_row+4) and (column = alien0_col+2)) OR 
                             ((row = alienTopRow_row+4) and (column = alien0_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien0_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';
    -- Alien 1
    grid_alien1 <= '1' when ( ((row = alienTopRow_row-3) and (column = alien1_col-3)) OR -- top row of alien
                             ((row = alienTopRow_row-3) and (column = alien1_col+3)) OR 
                             ((row = alienTopRow_row-2) and (column = alien1_col-2)) OR -- 2nd row of alien
                             ((row = alienTopRow_row-2) and (column = alien1_col+2)) OR                      
                             ((row = alienTopRow_row-1) and ((column >= alien1_col-3) and (column <= alien1_col+3))) OR -- third row of alien
                             ((row = alienTopRow_row) and ((column >= alien1_col-4) and (column < alien1_col-2))) or  -- fourth row of alien
                             ((row = alienTopRow_row) and ((column >= alien1_col-1) and (column <= alien1_col+1))) or 
                             ((row = alienTopRow_row) and ((column >= alien1_col+3) and (column <= alien1_col+4))) OR 
                             ((row = alienTopRow_row+1) and ((column >= alien1_col-5) and (column <= alien1_col+5))) OR -- fifth row of alien
                             ((row = alienTopRow_row+2) and (column = alien1_col-5)) or -- sixth row
                             ((row = alienTopRow_row+2) and (column = alien1_col+5)) or
                             ((row = alienTopRow_row+2) and ((column >= alien1_col-3) and (column <= alien1_col+3))) OR
                             ((row = alienTopRow_row+3) and (column = alien1_col-5)) OR  -- seventh row
                             ((row = alienTopRow_row+3) and (column = alien1_col-3)) OR
                             ((row = alienTopRow_row+3) and (column = alien1_col+3)) OR
                             ((row = alienTopRow_row+3) and (column = alien1_col+5)) OR
                             ((row = alienTopRow_row+4) and (column = alien1_col-2)) OR -- last row of alien
                             ((row = alienTopRow_row+4) and (column = alien1_col-1)) OR
                             ((row = alienTopRow_row+4) and (column = alien1_col+2)) OR 
                             ((row = alienTopRow_row+4) and (column = alien1_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien1_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';   
                             
    -- Alien 2 
    grid_alien2 <= '1' when ( ((row = alienTopRow_row-3) and (column = alien2_col-3)) OR -- top row of alien
                             ((row = alienTopRow_row-3) and (column = alien2_col+3)) OR 
                             ((row = alienTopRow_row-2) and (column = alien2_col-2)) OR -- 2nd row of alien
                             ((row = alienTopRow_row-2) and (column = alien2_col+2)) OR                      
                             ((row = alienTopRow_row-1) and ((column >= alien2_col-3) and (column <= alien2_col+3))) OR -- third row of alien
                             ((row = alienTopRow_row) and ((column >= alien2_col-4) and (column < alien2_col-2))) or  -- fourth row of alien
                             ((row = alienTopRow_row) and ((column >= alien2_col-1) and (column <= alien2_col+1))) or 
                             ((row = alienTopRow_row) and ((column >= alien2_col+3) and (column <= alien2_col+4))) OR 
                             ((row = alienTopRow_row+1) and ((column >= alien2_col-5) and (column <= alien2_col+5))) OR -- fifth row of alien
                             ((row = alienTopRow_row+2) and (column = alien2_col-5)) or -- sixth row
                             ((row = alienTopRow_row+2) and (column = alien2_col+5)) or
                             ((row = alienTopRow_row+2) and ((column >= alien2_col-3) and (column <= alien2_col+3))) OR
                             ((row = alienTopRow_row+3) and (column = alien2_col-5)) OR  -- seventh row
                             ((row = alienTopRow_row+3) and (column = alien2_col-3)) OR
                             ((row = alienTopRow_row+3) and (column = alien2_col+3)) OR
                             ((row = alienTopRow_row+3) and (column = alien2_col+5)) OR
                             ((row = alienTopRow_row+4) and (column = alien2_col-2)) OR -- last row of alien
                             ((row = alienTopRow_row+4) and (column = alien2_col-1)) OR
                             ((row = alienTopRow_row+4) and (column = alien2_col+2)) OR 
                             ((row = alienTopRow_row+4) and (column = alien2_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien2_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';     
                             
    -- Alien 3 
    grid_alien3 <= '1' when ( ((row = alienTopRow_row-3) and (column = alien3_col-3)) OR -- top row of alien
                             ((row = alienTopRow_row-3) and (column = alien3_col+3)) OR 
                             ((row = alienTopRow_row-2) and (column = alien3_col-2)) OR -- 2nd row of alien
                             ((row = alienTopRow_row-2) and (column = alien3_col+2)) OR                      
                             ((row = alienTopRow_row-1) and ((column >= alien3_col-3) and (column <= alien3_col+3))) OR -- third row of alien
                             ((row = alienTopRow_row) and ((column >= alien3_col-4) and (column < alien3_col-2))) or  -- fourth row of alien
                             ((row = alienTopRow_row) and ((column >= alien3_col-1) and (column <= alien3_col+1))) or 
                             ((row = alienTopRow_row) and ((column >= alien3_col+3) and (column <= alien3_col+4))) OR 
                             ((row = alienTopRow_row+1) and ((column >= alien3_col-5) and (column <= alien3_col+5))) OR -- fifth row of alien
                             ((row = alienTopRow_row+2) and (column = alien3_col-5)) or -- sixth row
                             ((row = alienTopRow_row+2) and (column = alien3_col+5)) or
                             ((row = alienTopRow_row+2) and ((column >= alien3_col-3) and (column <= alien3_col+3))) OR
                             ((row = alienTopRow_row+3) and (column = alien3_col-5)) OR  -- seventh row
                             ((row = alienTopRow_row+3) and (column = alien3_col-3)) OR
                             ((row = alienTopRow_row+3) and (column = alien3_col+3)) OR
                             ((row = alienTopRow_row+3) and (column = alien3_col+5)) OR
                             ((row = alienTopRow_row+4) and (column = alien3_col-2)) OR -- last row of alien
                             ((row = alienTopRow_row+4) and (column = alien3_col-1)) OR
                             ((row = alienTopRow_row+4) and (column = alien3_col+2)) OR 
                             ((row = alienTopRow_row+4) and (column = alien3_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien3_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';       
                             
     -- Alien 4 
    grid_alien4 <= '1' when ( ((row = alienTopRow_row-3) and (column = alien4_col-3)) OR -- top row of alien
                             ((row = alienTopRow_row-3) and (column = alien4_col+3)) OR 
                             ((row = alienTopRow_row-2) and (column = alien4_col-2)) OR -- 2nd row of alien
                             ((row = alienTopRow_row-2) and (column = alien4_col+2)) OR                      
                             ((row = alienTopRow_row-1) and ((column >= alien4_col-3) and (column <= alien4_col+3))) OR -- third row of alien
                             ((row = alienTopRow_row) and ((column >= alien4_col-4) and (column < alien4_col-2))) or  -- fourth row of alien
                             ((row = alienTopRow_row) and ((column >= alien4_col-1) and (column <= alien4_col+1))) or 
                             ((row = alienTopRow_row) and ((column >= alien4_col+3) and (column <= alien4_col+4))) OR 
                             ((row = alienTopRow_row+1) and ((column >= alien4_col-5) and (column <= alien4_col+5))) OR -- fifth row of alien
                             ((row = alienTopRow_row+2) and (column = alien4_col-5)) or -- sixth row
                             ((row = alienTopRow_row+2) and (column = alien4_col+5)) or
                             ((row = alienTopRow_row+2) and ((column >= alien4_col-3) and (column <= alien4_col+3))) OR
                             ((row = alienTopRow_row+3) and (column = alien4_col-5)) OR  -- seventh row
                             ((row = alienTopRow_row+3) and (column = alien4_col-3)) OR
                             ((row = alienTopRow_row+3) and (column = alien4_col+3)) OR
                             ((row = alienTopRow_row+3) and (column = alien4_col+5)) OR
                             ((row = alienTopRow_row+4) and (column = alien4_col-2)) OR -- last row of alien
                             ((row = alienTopRow_row+4) and (column = alien4_col-1)) OR
                             ((row = alienTopRow_row+4) and (column = alien4_col+2)) OR 
                             ((row = alienTopRow_row+4) and (column = alien4_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien4_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';                                                                 
    
    -- Alien 5
    grid_alien5 <= '1' when ( ((row = alienMiddleRow_row-3) and (column = alien0_col-3)) OR -- top row of alien
                             ((row = alienMiddleRow_row-3) and (column = alien0_col+3)) OR 
                             ((row = alienMiddleRow_row-2) and (column = alien0_col-2)) OR -- 2nd row of alien
                             ((row = alienMiddleRow_row-2) and (column = alien0_col+2)) OR                      
                             ((row = alienMiddleRow_row-1) and ((column >= alien0_col-3) and (column <= alien0_col+3))) OR -- third row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien0_col-4) and (column < alien0_col-2))) or  -- fourth row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien0_col-1) and (column <= alien0_col+1))) or 
                             ((row = alienMiddleRow_row) and ((column >= alien0_col+3) and (column <= alien0_col+4))) OR 
                             ((row = alienMiddleRow_row+1) and ((column >= alien0_col-5) and (column <= alien0_col+5))) OR -- fifth row of alien
                             ((row = alienMiddleRow_row+2) and (column = alien0_col-5)) or -- sixth row
                             ((row = alienMiddleRow_row+2) and (column = alien0_col+5)) or
                             ((row = alienMiddleRow_row+2) and ((column >= alien0_col-3) and (column <= alien0_col+3))) OR
                             ((row = alienMiddleRow_row+3) and (column = alien0_col-5)) OR  -- seventh row
                             ((row = alienMiddleRow_row+3) and (column = alien0_col-3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien0_col+3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien0_col+5)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien0_col-2)) OR -- last row of alien
                             ((row = alienMiddleRow_row+4) and (column = alien0_col-1)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien0_col+2)) OR 
                             ((row = alienMiddleRow_row+4) and (column = alien0_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien5_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';
    -- Alien 6
    grid_alien6 <= '1' when ( ((row = alienMiddleRow_row-3) and (column = alien1_col-3)) OR -- top row of alien
                             ((row = alienMiddleRow_row-3) and (column = alien1_col+3)) OR 
                             ((row = alienMiddleRow_row-2) and (column = alien1_col-2)) OR -- 2nd row of alien
                             ((row = alienMiddleRow_row-2) and (column = alien1_col+2)) OR                      
                             ((row = alienMiddleRow_row-1) and ((column >= alien1_col-3) and (column <= alien1_col+3))) OR -- third row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien1_col-4) and (column < alien1_col-2))) or  -- fourth row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien1_col-1) and (column <= alien1_col+1))) or 
                             ((row = alienMiddleRow_row) and ((column >= alien1_col+3) and (column <= alien1_col+4))) OR 
                             ((row = alienMiddleRow_row+1) and ((column >= alien1_col-5) and (column <= alien1_col+5))) OR -- fifth row of alien
                             ((row = alienMiddleRow_row+2) and (column = alien1_col-5)) or -- sixth row
                             ((row = alienMiddleRow_row+2) and (column = alien1_col+5)) or
                             ((row = alienMiddleRow_row+2) and ((column >= alien1_col-3) and (column <= alien1_col+3))) OR
                             ((row = alienMiddleRow_row+3) and (column = alien1_col-5)) OR  -- seventh row
                             ((row = alienMiddleRow_row+3) and (column = alien1_col-3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien1_col+3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien1_col+5)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien1_col-2)) OR -- last row of alien
                             ((row = alienMiddleRow_row+4) and (column = alien1_col-1)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien1_col+2)) OR 
                             ((row = alienMiddleRow_row+4) and (column = alien1_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien6_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';   
                             
    -- Alien 7 
    grid_alien7 <= '1' when ( ((row = alienMiddleRow_row-3) and (column = alien2_col-3)) OR -- top row of alien
                             ((row = alienMiddleRow_row-3) and (column = alien2_col+3)) OR 
                             ((row = alienMiddleRow_row-2) and (column = alien2_col-2)) OR -- 2nd row of alien
                             ((row = alienMiddleRow_row-2) and (column = alien2_col+2)) OR                      
                             ((row = alienMiddleRow_row-1) and ((column >= alien2_col-3) and (column <= alien2_col+3))) OR -- third row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien2_col-4) and (column < alien2_col-2))) or  -- fourth row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien2_col-1) and (column <= alien2_col+1))) or 
                             ((row = alienMiddleRow_row) and ((column >= alien2_col+3) and (column <= alien2_col+4))) OR 
                             ((row = alienMiddleRow_row+1) and ((column >= alien2_col-5) and (column <= alien2_col+5))) OR -- fifth row of alien
                             ((row = alienMiddleRow_row+2) and (column = alien2_col-5)) or -- sixth row
                             ((row = alienMiddleRow_row+2) and (column = alien2_col+5)) or
                             ((row = alienMiddleRow_row+2) and ((column >= alien2_col-3) and (column <= alien2_col+3))) OR
                             ((row = alienMiddleRow_row+3) and (column = alien2_col-5)) OR  -- seventh row
                             ((row = alienMiddleRow_row+3) and (column = alien2_col-3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien2_col+3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien2_col+5)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien2_col-2)) OR -- last row of alien
                             ((row = alienMiddleRow_row+4) and (column = alien2_col-1)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien2_col+2)) OR 
                             ((row = alienMiddleRow_row+4) and (column = alien2_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien7_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';     
                             
    -- Alien 8 
    grid_alien8 <= '1' when ( ((row = alienMiddleRow_row-3) and (column = alien3_col-3)) OR -- top row of alien
                             ((row = alienMiddleRow_row-3) and (column = alien3_col+3)) OR 
                             ((row = alienMiddleRow_row-2) and (column = alien3_col-2)) OR -- 2nd row of alien
                             ((row = alienMiddleRow_row-2) and (column = alien3_col+2)) OR                      
                             ((row = alienMiddleRow_row-1) and ((column >= alien3_col-3) and (column <= alien3_col+3))) OR -- third row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien3_col-4) and (column < alien3_col-2))) or  -- fourth row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien3_col-1) and (column <= alien3_col+1))) or 
                             ((row = alienMiddleRow_row) and ((column >= alien3_col+3) and (column <= alien3_col+4))) OR 
                             ((row = alienMiddleRow_row+1) and ((column >= alien3_col-5) and (column <= alien3_col+5))) OR -- fifth row of alien
                             ((row = alienMiddleRow_row+2) and (column = alien3_col-5)) or -- sixth row
                             ((row = alienMiddleRow_row+2) and (column = alien3_col+5)) or
                             ((row = alienMiddleRow_row+2) and ((column >= alien3_col-3) and (column <= alien3_col+3))) OR
                             ((row = alienMiddleRow_row+3) and (column = alien3_col-5)) OR  -- seventh row
                             ((row = alienMiddleRow_row+3) and (column = alien3_col-3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien3_col+3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien3_col+5)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien3_col-2)) OR -- last row of alien
                             ((row = alienMiddleRow_row+4) and (column = alien3_col-1)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien3_col+2)) OR 
                             ((row = alienMiddleRow_row+4) and (column = alien3_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien8_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';       
                             
     -- Alien 9 
    grid_alien9 <= '1' when ( ((row = alienMiddleRow_row-3) and (column = alien4_col-3)) OR -- top row of alien
                             ((row = alienMiddleRow_row-3) and (column = alien4_col+3)) OR 
                             ((row = alienMiddleRow_row-2) and (column = alien4_col-2)) OR -- 2nd row of alien
                             ((row = alienMiddleRow_row-2) and (column = alien4_col+2)) OR                      
                             ((row = alienMiddleRow_row-1) and ((column >= alien4_col-3) and (column <= alien4_col+3))) OR -- third row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien4_col-4) and (column < alien4_col-2))) or  -- fourth row of alien
                             ((row = alienMiddleRow_row) and ((column >= alien4_col-1) and (column <= alien4_col+1))) or 
                             ((row = alienMiddleRow_row) and ((column >= alien4_col+3) and (column <= alien4_col+4))) OR 
                             ((row = alienMiddleRow_row+1) and ((column >= alien4_col-5) and (column <= alien4_col+5))) OR -- fifth row of alien
                             ((row = alienMiddleRow_row+2) and (column = alien4_col-5)) or -- sixth row
                             ((row = alienMiddleRow_row+2) and (column = alien4_col+5)) or
                             ((row = alienMiddleRow_row+2) and ((column >= alien4_col-3) and (column <= alien4_col+3))) OR
                             ((row = alienMiddleRow_row+3) and (column = alien4_col-5)) OR  -- seventh row
                             ((row = alienMiddleRow_row+3) and (column = alien4_col-3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien4_col+3)) OR
                             ((row = alienMiddleRow_row+3) and (column = alien4_col+5)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien4_col-2)) OR -- last row of alien
                             ((row = alienMiddleRow_row+4) and (column = alien4_col-1)) OR
                             ((row = alienMiddleRow_row+4) and (column = alien4_col+2)) OR 
                             ((row = alienMiddleRow_row+4) and (column = alien4_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien9_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';
      
    -- Alien 10
    grid_alien10 <= '1' when ( ((row = alienBottomRow_row-3) and (column = alien0_col-3)) OR -- top row of alien
                             ((row = alienBottomRow_row-3) and (column = alien0_col+3)) OR 
                             ((row = alienBottomRow_row-2) and (column = alien0_col-2)) OR -- 2nd row of alien
                             ((row = alienBottomRow_row-2) and (column = alien0_col+2)) OR                      
                             ((row = alienBottomRow_row-1) and ((column >= alien0_col-3) and (column <= alien0_col+3))) OR -- third row of alien
                             ((row = alienBottomRow_row) and ((column >= alien0_col-4) and (column < alien0_col-2))) or  -- fourth row of alien
                             ((row = alienBottomRow_row) and ((column >= alien0_col-1) and (column <= alien0_col+1))) or 
                             ((row = alienBottomRow_row) and ((column >= alien0_col+3) and (column <= alien0_col+4))) OR 
                             ((row = alienBottomRow_row+1) and ((column >= alien0_col-5) and (column <= alien0_col+5))) OR -- fifth row of alien
                             ((row = alienBottomRow_row+2) and (column = alien0_col-5)) or -- sixth row
                             ((row = alienBottomRow_row+2) and (column = alien0_col+5)) or
                             ((row = alienBottomRow_row+2) and ((column >= alien0_col-3) and (column <= alien0_col+3))) OR
                             ((row = alienBottomRow_row+3) and (column = alien0_col-5)) OR  -- seventh row
                             ((row = alienBottomRow_row+3) and (column = alien0_col-3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien0_col+3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien0_col+5)) OR
                             ((row = alienBottomRow_row+4) and (column = alien0_col-2)) OR -- last row of alien
                             ((row = alienBottomRow_row+4) and (column = alien0_col-1)) OR
                             ((row = alienBottomRow_row+4) and (column = alien0_col+2)) OR 
                             ((row = alienBottomRow_row+4) and (column = alien0_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien10_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';
    -- Alien 11
    grid_alien11 <= '1' when ( ((row = alienBottomRow_row-3) and (column = alien1_col-3)) OR -- top row of alien
                             ((row = alienBottomRow_row-3) and (column = alien1_col+3)) OR 
                             ((row = alienBottomRow_row-2) and (column = alien1_col-2)) OR -- 2nd row of alien
                             ((row = alienBottomRow_row-2) and (column = alien1_col+2)) OR                      
                             ((row = alienBottomRow_row-1) and ((column >= alien1_col-3) and (column <= alien1_col+3))) OR -- third row of alien
                             ((row = alienBottomRow_row) and ((column >= alien1_col-4) and (column < alien1_col-2))) or  -- fourth row of alien
                             ((row = alienBottomRow_row) and ((column >= alien1_col-1) and (column <= alien1_col+1))) or 
                             ((row = alienBottomRow_row) and ((column >= alien1_col+3) and (column <= alien1_col+4))) OR 
                             ((row = alienBottomRow_row+1) and ((column >= alien1_col-5) and (column <= alien1_col+5))) OR -- fifth row of alien
                             ((row = alienBottomRow_row+2) and (column = alien1_col-5)) or -- sixth row
                             ((row = alienBottomRow_row+2) and (column = alien1_col+5)) or
                             ((row = alienBottomRow_row+2) and ((column >= alien1_col-3) and (column <= alien1_col+3))) OR
                             ((row = alienBottomRow_row+3) and (column = alien1_col-5)) OR  -- seventh row
                             ((row = alienBottomRow_row+3) and (column = alien1_col-3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien1_col+3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien1_col+5)) OR
                             ((row = alienBottomRow_row+4) and (column = alien1_col-2)) OR -- last row of alien
                             ((row = alienBottomRow_row+4) and (column = alien1_col-1)) OR
                             ((row = alienBottomRow_row+4) and (column = alien1_col+2)) OR 
                             ((row = alienBottomRow_row+4) and (column = alien1_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien11_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';   
                             
    -- Alien 12 
    grid_alien12 <= '1' when ( ((row = alienBottomRow_row-3) and (column = alien2_col-3)) OR -- top row of alien
                             ((row = alienBottomRow_row-3) and (column = alien2_col+3)) OR 
                             ((row = alienBottomRow_row-2) and (column = alien2_col-2)) OR -- 2nd row of alien
                             ((row = alienBottomRow_row-2) and (column = alien2_col+2)) OR                      
                             ((row = alienBottomRow_row-1) and ((column >= alien2_col-3) and (column <= alien2_col+3))) OR -- third row of alien
                             ((row = alienBottomRow_row) and ((column >= alien2_col-4) and (column < alien2_col-2))) or  -- fourth row of alien
                             ((row = alienBottomRow_row) and ((column >= alien2_col-1) and (column <= alien2_col+1))) or 
                             ((row = alienBottomRow_row) and ((column >= alien2_col+3) and (column <= alien2_col+4))) OR 
                             ((row = alienBottomRow_row+1) and ((column >= alien2_col-5) and (column <= alien2_col+5))) OR -- fifth row of alien
                             ((row = alienBottomRow_row+2) and (column = alien2_col-5)) or -- sixth row
                             ((row = alienBottomRow_row+2) and (column = alien2_col+5)) or
                             ((row = alienBottomRow_row+2) and ((column >= alien2_col-3) and (column <= alien2_col+3))) OR
                             ((row = alienBottomRow_row+3) and (column = alien2_col-5)) OR  -- seventh row
                             ((row = alienBottomRow_row+3) and (column = alien2_col-3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien2_col+3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien2_col+5)) OR
                             ((row = alienBottomRow_row+4) and (column = alien2_col-2)) OR -- last row of alien
                             ((row = alienBottomRow_row+4) and (column = alien2_col-1)) OR
                             ((row = alienBottomRow_row+4) and (column = alien2_col+2)) OR 
                             ((row = alienBottomRow_row+4) and (column = alien2_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien12_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';     
                             
    -- Alien 13 
    grid_alien13 <= '1' when ( ((row = alienBottomRow_row-3) and (column = alien3_col-3)) OR -- top row of alien
                             ((row = alienBottomRow_row-3) and (column = alien3_col+3)) OR 
                             ((row = alienBottomRow_row-2) and (column = alien3_col-2)) OR -- 2nd row of alien
                             ((row = alienBottomRow_row-2) and (column = alien3_col+2)) OR                      
                             ((row = alienBottomRow_row-1) and ((column >= alien3_col-3) and (column <= alien3_col+3))) OR -- third row of alien
                             ((row = alienBottomRow_row) and ((column >= alien3_col-4) and (column < alien3_col-2))) or  -- fourth row of alien
                             ((row = alienBottomRow_row) and ((column >= alien3_col-1) and (column <= alien3_col+1))) or 
                             ((row = alienBottomRow_row) and ((column >= alien3_col+3) and (column <= alien3_col+4))) OR 
                             ((row = alienBottomRow_row+1) and ((column >= alien3_col-5) and (column <= alien3_col+5))) OR -- fifth row of alien
                             ((row = alienBottomRow_row+2) and (column = alien3_col-5)) or -- sixth row
                             ((row = alienBottomRow_row+2) and (column = alien3_col+5)) or
                             ((row = alienBottomRow_row+2) and ((column >= alien3_col-3) and (column <= alien3_col+3))) OR
                             ((row = alienBottomRow_row+3) and (column = alien3_col-5)) OR  -- seventh row
                             ((row = alienBottomRow_row+3) and (column = alien3_col-3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien3_col+3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien3_col+5)) OR
                             ((row = alienBottomRow_row+4) and (column = alien3_col-2)) OR -- last row of alien
                             ((row = alienBottomRow_row+4) and (column = alien3_col-1)) OR
                             ((row = alienBottomRow_row+4) and (column = alien3_col+2)) OR 
                             ((row = alienBottomRow_row+4) and (column = alien3_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien13_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';       
                             
     -- Alien 14 
    grid_alien14 <= '1' when ( ((row = alienBottomRow_row-3) and (column = alien4_col-3)) OR -- top row of alien
                             ((row = alienBottomRow_row-3) and (column = alien4_col+3)) OR 
                             ((row = alienBottomRow_row-2) and (column = alien4_col-2)) OR -- 2nd row of alien
                             ((row = alienBottomRow_row-2) and (column = alien4_col+2)) OR                      
                             ((row = alienBottomRow_row-1) and ((column >= alien4_col-3) and (column <= alien4_col+3))) OR -- third row of alien
                             ((row = alienBottomRow_row) and ((column >= alien4_col-4) and (column < alien4_col-2))) or  -- fourth row of alien
                             ((row = alienBottomRow_row) and ((column >= alien4_col-1) and (column <= alien4_col+1))) or 
                             ((row = alienBottomRow_row) and ((column >= alien4_col+3) and (column <= alien4_col+4))) OR 
                             ((row = alienBottomRow_row+1) and ((column >= alien4_col-5) and (column <= alien4_col+5))) OR -- fifth row of alien
                             ((row = alienBottomRow_row+2) and (column = alien4_col-5)) or -- sixth row
                             ((row = alienBottomRow_row+2) and (column = alien4_col+5)) or
                             ((row = alienBottomRow_row+2) and ((column >= alien4_col-3) and (column <= alien4_col+3))) OR
                             ((row = alienBottomRow_row+3) and (column = alien4_col-5)) OR  -- seventh row
                             ((row = alienBottomRow_row+3) and (column = alien4_col-3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien4_col+3)) OR
                             ((row = alienBottomRow_row+3) and (column = alien4_col+5)) OR
                             ((row = alienBottomRow_row+4) and (column = alien4_col-2)) OR -- last row of alien
                             ((row = alienBottomRow_row+4) and (column = alien4_col-1)) OR
                             ((row = alienBottomRow_row+4) and (column = alien4_col+2)) OR 
                             ((row = alienBottomRow_row+4) and (column = alien4_col+1))) AND
                             (row < 370 and row > 70) AND (column < 440 and column > 200) AND (alien14_en = '1') -- to make sure aliens aren't drawn outside of boundary
                             else '0';      
                             
                                                
    -- Draw the colors of the pixels (everything is white)
        -- Ship is white, red and blue
        -- Aliens are white
        -- Bullets are white
    r <= x"FF" when ( (score_win = '1') OR (score_0 = '1') OR (score_1 = '1') OR (score_2 = '1') OR (score_3 = '1') OR (score_4 = '1') OR (score_5 = '1') OR (score_6 = '1') OR (score_7 = '1') OR (score_8 = '1') OR (score_9 = '1') OR (score_10 = '1') OR (score_11 = '1') OR (score_12 = '1') OR (score_13 = '1') OR (score_14 = '1') OR (score_15 = '1') OR (score_text = '1') OR (grid_boundary_row = '1') OR (grid_boundary_col = '1') OR (grid_player_location_white = '1') OR (grid_player_location_red = '1') OR (grid_alien0 = '1') OR (grid_alien1 = '1') OR (grid_alien2 = '1') OR (grid_alien3 = '1') OR (grid_alien4 = '1') OR (grid_alien5 = '1') OR (grid_alien6 = '1') OR (grid_alien7 = '1') OR (grid_alien8 = '1') OR (grid_alien9 = '1') OR (grid_alien10 = '1') OR (grid_alien11 = '1') OR (grid_alien12 = '1') OR (grid_alien13 = '1') OR (grid_alien14 = '1') OR (grid_bullet_location = '1') ) else x"00";
    g <= x"FF" when ( (score_win = '1') OR (score_0 = '1') OR (score_1 = '1') OR (score_2 = '1') OR (score_3 = '1') OR (score_4 = '1') OR (score_5 = '1') OR (score_6 = '1') OR (score_7 = '1') OR (score_8 = '1') OR (score_9 = '1') OR (score_10 = '1') OR (score_11 = '1') OR (score_12 = '1') OR (score_13 = '1') OR (score_14 = '1') OR (score_15 = '1') OR (score_text = '1') OR (grid_boundary_row = '1') OR (grid_boundary_col = '1') OR (grid_player_location_white = '1') OR (grid_alien0 = '1') OR (grid_alien1 = '1') OR (grid_alien2 = '1') OR (grid_alien3 = '1') OR (grid_alien4 = '1') OR (grid_alien5 = '1') OR (grid_alien6 = '1') OR (grid_alien7 = '1') OR (grid_alien8 = '1') OR (grid_alien9 = '1') OR (grid_alien10 = '1') OR (grid_alien11 = '1') OR (grid_alien12 = '1') OR (grid_alien13 = '1') OR (grid_alien14 = '1') OR (grid_bullet_location = '1') ) else x"00";
    b <= x"FF" when ( (score_win = '1') OR (score_0 = '1') OR (score_1 = '1') OR (score_2 = '1') OR (score_3 = '1') OR (score_4 = '1') OR (score_5 = '1') OR (score_6 = '1') OR (score_7 = '1') OR (score_8 = '1') OR (score_9 = '1') OR (score_10 = '1') OR (score_11 = '1') OR (score_12 = '1') OR (score_13 = '1') OR (score_14 = '1') OR (score_15 = '1') OR (score_text = '1') OR (grid_boundary_row = '1') OR (grid_boundary_col = '1') OR (grid_player_location_white = '1') OR (grid_player_location_blue = '1')OR (grid_alien0 = '1') OR (grid_alien1 = '1') OR (grid_alien2 = '1') OR (grid_alien3 = '1') OR (grid_alien4 = '1') OR (grid_alien5 = '1') OR (grid_alien6 = '1') OR (grid_alien7 = '1') OR (grid_alien8 = '1') OR (grid_alien9 = '1') OR (grid_alien10 = '1') OR (grid_alien11 = '1') OR (grid_alien12 = '1') OR (grid_alien13 = '1') OR (grid_alien14 = '1') OR (grid_bullet_location = '1') ) else x"00";
    
    

end Behavioral;
