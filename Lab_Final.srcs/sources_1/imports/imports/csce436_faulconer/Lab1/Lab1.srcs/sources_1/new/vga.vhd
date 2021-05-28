----------------------------------------------------------------------------------
-- Name:	Tom Faulconer
-- Date:	Spring 2020
-- Course: 	CSCE 436
-- File: 	vga.vhd
-- HW:		Final Project
-- Purp:	Create a VGA controller that generates a gameboard, alien locations, player ship and bullets
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


entity vga is
    Port (  clk: in STD_LOGIC;
            reset_n : in STD_LOGIC;
            h_sync : out STD_LOGIC;
            v_sync : out STD_LOGIC;
            blank : out STD_LOGIC;
            r : out STD_LOGIC_VECTOR(7 downto 0);
            g : out STD_LOGIC_VECTOR(7 downto 0);
            b : out STD_LOGIC_VECTOR(7 downto 0);
            player_location : in unsigned (9 downto 0);
            row : out unsigned (9 downto 0);
            column : out unsigned (9 downto 0);
            bullet_col : in unsigned (9 downto 0);
            bullet_row : in unsigned (8 downto 0); -- needs to be between 70 - 370 (2^9 = 512)
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
            
           alienMiddleRow_row : in unsigned(8 downto 0); -- := x"66"; -- 102
           alien5_en : in std_logic;
           alien6_en : in std_logic;
           alien7_en : in std_logic;
           alien8_en : in std_logic;
           alien9_en : in std_logic;
            
           alienBottomRow_row : in unsigned(8 downto 0); -- := x"72"; -- 114
           alien10_en : in std_logic;
           alien11_en : in std_logic;
           alien12_en : in std_logic;
           alien13_en : in std_logic;
           alien14_en : in std_logic;
           n_bits : in integer;
           win : in std_logic
         );
end vga;

architecture Behavioral of vga is

    -- DECLARE COMPONENTS
    
    -- Column Counter component
    COMPONENT col_counter is
        Port ( clk : in STD_LOGIC;
               reset_n : in STD_LOGIC;
               ctrl : in STD_LOGIC;
               Q : out unsigned (9 downto 0); -- needs to count up to 0 - 799 (10 bit number)
               roll : out STD_LOGIC);
    end COMPONENT;
    
    -- Row Counter component
    COMPONENT row_counter is
        Port ( clk : in STD_LOGIC;
               reset_n : in STD_LOGIC;
               ctrl : in STD_LOGIC;
               Q : out unsigned (9 downto 0); -- needs to count up to 0 - 799 (10 bit number)
               roll : out STD_LOGIC);
    end COMPONENT;
    
    -- scopeFace component
    COMPONENT scopeFace is
        Port ( row : in  unsigned(9 downto 0);
               column : in  unsigned(9 downto 0);
               player_location : in unsigned (9 downto 0);
		       --arduino_comm : in STD_LOGIC_VECTOR(3 downto 0); -- move left, move right, C button, Z button
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
                
               alienMiddleRow_row : in unsigned(8 downto 0); -- := x"66"; -- 102
               alien5_en : in std_logic;
               alien6_en : in std_logic;
               alien7_en : in std_logic;
               alien8_en : in std_logic;
               alien9_en : in std_logic;
                
               alienBottomRow_row : in unsigned(8 downto 0); -- := x"72"; -- 114
               alien10_en : in std_logic;
               alien11_en : in std_logic;
               alien12_en : in std_logic;
               alien13_en : in std_logic;
               alien14_en : in std_logic;
               n_bits : in integer;
               win : in std_logic
			   );
    end COMPONENT; 

    -- DECLARE SIGNALS -----------------------------------------------------------------
    signal roll_s : std_logic;
    signal ctrl_s : std_logic := '1';
    signal glue_output_s : std_logic;
    signal column_s : unsigned (9 downto 0);
    signal row_s : unsigned (9 downto 0);
    signal h_blank : std_logic;
    signal v_blank : std_logic;
    
    signal red_s : std_logic_vector(7 downto 0);
    signal green_s : std_logic_vector(7 downto 0);
    signal blue_s : std_logic_vector(7 downto 0);
        

begin

    -- column counter instantiation
    c_counter : col_counter
    
        port map (clk => clk, reset_n => reset_n, ctrl => ctrl_s,
                  Q => column_s, roll => roll_s);
                  
    -- row counter instantiation
    r_counter : row_counter
    
        port map (clk => clk, reset_n => reset_n, ctrl => glue_output_s,
                  Q => row_s, roll => open);
                  
    -- add scopeFace instantiation
    scope_Face : scopeFace
    
        port map (row => row_s, column => column_s, r => red_s, g => green_s, b => blue_s, player_location => player_location,
                    alien0_en => alien0_en, alien1_en => alien1_en, alien2_en => alien2_en, alien3_en => alien3_en, alien4_en => alien4_en,
                    alien5_en => alien5_en, alien6_en => alien6_en, alien7_en => alien7_en, alien8_en => alien8_en, alien9_en => alien9_en,
                    alien10_en => alien10_en, alien11_en => alien11_en, alien12_en => alien12_en, alien13_en => alien13_en, alien14_en => alien14_en,
                    alienTopRow_row => alienTopRow_row, alienMiddleRow_row => alienMiddleRow_row, alienBottomRow_row => alienBottomRow_row,
                    alien0_col => alien0_col, alien1_col => alien1_col, alien2_col => alien2_col, alien3_col => alien3_col, alien4_col => alien4_col,
                    bullet_row => bullet_row, bullet_en => bullet_en, bullet_col => bullet_col, n_bits => n_bits, win => win);
    
    -- CSA's ---------------------------------------------------------------------------------------
    
    -- "Glue" that connects counters together
    glue_output_s <= '1' when (ctrl_s = '1' and roll_s = '1') else '0';
    
    -- Logic that gets the h_sync and h_blank signals working
    column <= column_s;
    h_sync <= '1' when ( (column_s < 656) or (column_s > 751) ) else '0';
    h_blank <= '0' when (column_s < 640) else '1';
    
    -- Logic that gets the v_sync and v_blank signals working
    row <= row_s;
    v_sync <= '1' when ( (row_s < 490) or (row_s > 491) ) else '0';
    v_blank <= '0' when (row_s < 480) else '1';
         
    -- Logic for the blank signals         
    blank <= (h_blank or v_blank);
    
    r <= red_s;
    g <= green_s;
    b <= blue_s;
   
    
    
end Behavioral;
