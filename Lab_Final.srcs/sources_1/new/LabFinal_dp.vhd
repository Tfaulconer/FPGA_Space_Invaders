---------------------------------------------------------------------------------
-- Name:	Tom Faulconer
-- Date:	Spring 2020
-- Course: 	CSCE 436
-- File: 	LabFinal_dp.vhd
-- HW:		Final Lab
-- Purp:	Datapath of final lab project. Deploys logic to determine alien/bullet collisions and get
--          arduino commands input
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

entity LabFinal_dp is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           arduino_comm : in STD_LOGIC_VECTOR(3 downto 0);
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
           sw : out STD_LOGIC_VECTOR (3 downto 0);
           cw : in STD_LOGIC_VECTOR (3 downto 0);
           sw_bullet : out STD_LOGIC_VECTOR (26 downto 0);
           cw_bullet : in STD_LOGIC_VECTOR (20 downto 0)
           );
end LabFinal_dp;

architecture Behavioral of LabFinal_dp is

    -- Clock signal
    
    -- Signal use with Clock
    signal player_move_counter : unsigned(31 downto 0); -- needs to count up to something to slow down the player ship location
    
    signal alien_clk_en : std_logic; -- needs to count up to something to slow down the aliens moving
    signal alien_counter : unsigned(21 downto 0);
    
    signal bullet_clk_en: std_logic; -- needs to count up to something to slow down the bullet moving
    signal bullet_counter : unsigned(19 downto 0);
    
    signal win_clk_en : std_logic;
    signal win_counter : unsigned(27 downto 0);
    signal win_process : std_logic;
    
    -- Declare Signals    
    signal alien0_col : unsigned(8 downto 0) := "011100110"; -- decimal value = 230
    signal alien1_col : unsigned(8 downto 0) := "011110110"; -- decimal value = 246
    signal alien2_col : unsigned(8 downto 0) := "100000110"; -- decimal value = 262
    signal alien3_col : unsigned(8 downto 0) := "100010110"; -- decimal value = 278
    signal alien4_col : unsigned(8 downto 0) := "100100110"; -- decimal value = 294
       
    signal alienTopRow_row : unsigned(8 downto 0) := "001011010"; -- decimal value = 90
    signal alienMiddleRow_row : unsigned(8 downto 0) := "001100110"; -- decimal value = 102
    signal alienBottomRow_row : unsigned(8 downto 0) := "001110010"; -- decimal value = 114
    
    signal alien0_en : std_logic := '1'; -- these need to come from the bullet control path
    signal alien1_en : std_logic := '1';
    signal alien2_en : std_logic := '1';
    signal alien3_en : std_logic := '1';
    signal alien4_en : std_logic := '1';
    signal alien5_en : std_logic := '1';
    signal alien6_en : std_logic := '1';
    signal alien7_en : std_logic := '1';
    signal alien8_en : std_logic := '1';
    signal alien9_en : std_logic := '1';
    signal alien10_en : std_logic := '1';
    signal alien11_en : std_logic := '1';
    signal alien12_en : std_logic := '1';
    signal alien13_en : std_logic := '1';
    signal alien14_en : std_logic := '1';
    
    signal score_keep : std_logic_vector(14 downto 0) := alien14_en & alien13_en & alien12_en & alien11_en & alien10_en & 
                                                          alien9_en & alien8_en & alien7_en & alien6_en & alien5_en & 
                                                          alien4_en & alien3_en & alien2_en & alien1_en & alien0_en;
                                                          
    signal score_keep_for_function : std_logic_vector(14 downto 0);                                                      
                                                          
    signal n_bits : integer;
    signal win : std_logic := '0';
    
    signal row : unsigned(9 downto 0);
    signal column : unsigned(9 downto 0);
    
    signal player_location : unsigned(9 downto 0) := "0101000000"; -- decimal value 320 (middle of the screen) THIS IS A COLUMN
    
    signal bullet_col : unsigned(9 downto 0) := "0101000000";
    signal bullet_row : unsigned(8 downto 0) := "101100001"; -- 101100001 353  decimal value row = 369 101110001
    signal bullet_en : std_logic := '1'; -- bullet default is on
    
    
    -- Declare Components
    COMPONENT video is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
              row: out unsigned(9 downto 0);
              column: out unsigned(9 downto 0);
              
           player_location : in unsigned (9 downto 0);
           bullet_col : in unsigned (9 downto 0);   
           bullet_row : in unsigned (8 downto 0); -- needs to be between 70 - 370 (2^9 = 512)
           bullet_en : in std_logic;
           
           alienTopRow_row : in unsigned(8 downto 0); 
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
    end COMPONENT;
   
   
    -- Function used count the number of ones in signal
    function count_ones(s : std_logic_vector) return integer is
        variable temp : integer := 0;
    begin
        for i in s'range loop
            if (s(i) = '1') then 
                temp := temp + 1; 
            end if;
        end loop;
      
        return temp;
    end function count_ones;
    
    
begin


    -- Instantiate Components
    Inst_video : video port map(
        clk => clk,
        reset_n => reset_n,
        tmds => tmds,
        tmdsb => tmdsb,
        row => row,
        column => column,
          
       player_location => player_location,
       bullet_row => bullet_row,
       bullet_col => bullet_col,
       bullet_en => bullet_en,
       
       alienTopRow_row => alienTopRow_row,
       alien0_col => alien0_col,
       alien0_en => alien0_en,
       alien1_col => alien1_col,
       alien1_en => alien1_en,
       alien2_col => alien2_col,
       alien2_en => alien2_en,
       alien3_col => alien3_col,
       alien3_en => alien3_en,
       alien4_col => alien4_col,
       alien4_en => alien4_en,
        
       alienMiddleRow_row => alienMiddleRow_row,
       alien5_en => alien5_en,
       alien6_en => alien6_en,
       alien7_en => alien7_en,
       alien8_en => alien8_en,
       alien9_en => alien9_en,
        
       alienBottomRow_row => alienBottomRow_row,
       alien10_en => alien10_en,
       alien11_en => alien11_en,
       alien12_en => alien12_en,
       alien13_en => alien13_en,
       alien14_en => alien14_en,
       n_bits => n_bits,
       win => win
       );


    -- process to determine the score
    process(clk)
    begin
      if rising_edge(clk) then
            n_bits <= count_ones(score_keep_for_function);
      end if;
    end process;

    -- process to increment player_move_counter
    -- clk = 100 MHz
    -- This one is done a bit differently. Made a 32 bit counter (arbitrary choice) and decided to make it rollover at 2,343,750
    -- This is effectively the same thing as the alien clock and bullet clock, just a different way to do it. About 42.67 Hz clock
    process(clk)
    begin 
        if (rising_edge(clk)) then
            if (reset_n = '0') then
                player_move_counter <= "00000000000000000000000000000000"; -- 32 bit value for 0
            elsif (player_move_counter = x"0023C346") then              -- hex value for 2,343,750 (0x0023C346)
                player_move_counter <= "00000000000000000000000000000000";
            else 
                player_move_counter <= player_move_counter + 1;
            end if;
        end if;
    end process;   
    
    -----------------------------------------------------------------------------------------------------------
    --                                    CLOCK PROCESS
    --              Making a slower clock enable to base the Alien's speed off of
    -- process to increment alien_clk_en
    -- clk = 100 MHz
    -- Create the clock enable:
    --      100 MHz / 2^x = ~25 Hz (player clock updates 2x as fast at ~ 43 Hz (based on what "felt" right))
    --      2^x = 4000000
    --      x = log_2(4000000) = 21.93 ----> Means I need to create a 22 bit counter variable. Counting up to the entire value
    --                                       will allow me to get roughly a 25 Hz clock. 
    --                                       with a 22 bit counter variable we will have a 41.94303 ms period => 23.84 Hz clock
    -----------------------------------------------------------------------------------------------------------
    process(clk)
    begin
        if(rising_edge(clk)) then
            alien_counter <= alien_counter + 1; 
            if(alien_counter = 0) then
                alien_clk_en <= '1';
            else
                alien_clk_en <= '0';
            end if;
        end if;
    end process;    
    
   -----------------------------------------------------------------------------------------------------------
    --                                    CLOCK PROCESS
    --              Making a slower clock enable to base the Bullet's speed off of
    -- process to increment bullet_clk_en
    -- clk = 100 MHz
    -- Create the clock enable:
    --      100 MHz / 2^x = 100 Hz 
    --      2^x = 1000000
    --      x = log_2(1000000) = 19.93 ----> Means I need to create a 20 bit counter variable. Counting up to the entire value
    --                                       will allow me to get roughly a 100 Hz clock. 
    --                                       with a 20 bit counter variable we will have a 1.348 ms period => 95.367 Hz clock
    -----------------------------------------------------------------------------------------------------------
    process(clk)
    begin
        if(rising_edge(clk)) then
            bullet_counter <= bullet_counter + 1; 
            if(bullet_counter = 0) then
                bullet_clk_en <= '1';
            else
                bullet_clk_en <= '0';
            end if;
        end if;
    end process;  
    
    
    -----------------------------------------------------------------------------------------------------------
    --                                    CLOCK PROCESS
    --              Making a to allow "YOU WIN!" to be displayed on screen long enough
    -- process to increment win_clk_en
    -- clk = 100 MHz
    -- Create the clock enable:
    --      100 MHz / 2^x = 0.5 Hz 
    --      2^x = 200000000
    --      x = log_2(200000000) = 27.57 ----> Means I need to create a 28 bit counter variable. Counting up to the entire value
    --                                       will allow me to get roughly a 0.5 Hz clock. 
    --                                       with a 28 bit counter variable we will have a 2.6843 s period => 0.3725 Hz clock
    -----------------------------------------------------------------------------------------------------------
    process(clk)
    begin
        if(rising_edge(clk)) then
            win_counter <= win_counter + 1; 
            if(win_counter = 0) then
                win_clk_en <= '1';
            else
                win_clk_en <= '0';
            end if;
        end if;
    end process;  
      
    win_process <= '1' when (win_clk_en = '1') else '0';  
         
    -- processes
    -- do the player_location button prcess
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset_n = '0') then
               player_location <= "0101000000"; -- default value decimal = 320
            elsif (arduino_comm(0) = '1') then -- counter is 300,000,000 
               if (player_location > 435) then 
                    player_location <= "0110110011"; -- keep player in the same spot they're at boundary 
               elsif (player_location < 205) then
                    player_location <= "0011001101";
               elsif (player_move_counter = x"0023C346") then 
                    player_location <= player_location - 1;
               else
                    player_location <= player_location;     
               end if;
            elsif (arduino_comm(1) = '1') then 
               if (player_location > 435) then 
                    player_location <= "0110110011"; -- keep player in the same spot they're at boundary 
               elsif (player_location < 205) then
                    player_location <= "0011001101";
               elsif (player_move_counter = x"0023C346") then
                    player_location <= player_location + 1;
               else
                    player_location <= player_location;       
               end if;   
            end if;        
         end if;
    end process;
    
    
    ---------------------------------------
    -- Slow Process for Aliens to move
    ---------------------------------------
    process(clk)
    begin 
        if (rising_edge(clk)) then
            if (reset_n = '0') then
                 alienTopRow_row <= "001011010"; -- decimal value = 90   
                 alienMiddleRow_row <= "001100110"; -- decimal value = 102
                 alienBottomRow_row <= "001110010"; -- decimal value = 114
                 alien0_col <= "011100110"; -- decimal value = 230
                 alien1_col <= "011110110"; -- decimal value = 246
                 alien2_col <= "100000110"; -- decimal value = 262
                 alien3_col <= "100010110"; -- decimal value = 278
                 alien4_col <= "100100110"; -- decimal value = 294 
            elsif (alien_clk_en = '1') then 
                 if (cw(0) = '1') then
                    alien0_col <= alien0_col - 1;
                    alien1_col <= alien1_col - 1;
                    alien2_col <= alien2_col - 1;
                    alien3_col <= alien3_col - 1;
                    alien4_col <= alien4_col - 1;
                elsif (cw(1) = '1') then 
                    alien0_col <= alien0_col + 1;
                    alien1_col <= alien1_col + 1;
                    alien2_col <= alien2_col + 1;
                    alien3_col <= alien3_col + 1;
                    alien4_col <= alien4_col + 1;    
                elsif (cw(2) = '1') then 
                    alienTopRow_row <= alienTopRow_row + 5; -- + 5 was tested and determined to look good
                    alienMiddleRow_row <= alienMiddleRow_row + 5;
                    alienBottomRow_row <= alienBottomRow_row + 5;  
                elsif (cw(3) = '1') then
                    alienTopRow_row <= "001011010"; -- decimal value = 90   
                    alienMiddleRow_row <= "001100110"; -- decimal value = 102
                    alienBottomRow_row <= "001110010"; -- decimal value = 114
                    alien0_col <= "011100110"; -- decimal value = 230
                    alien1_col <= "011110110"; -- decimal value = 246
                    alien2_col <= "100000110"; -- decimal value = 262
                    alien3_col <= "100010110"; -- decimal value = 278
                    alien4_col <= "100100110"; -- decimal value = 294 
                end if;
            end if;
        end if;
    end process; 
    
    
    -- CSA's for the Alien Control Unit
    sw(0) <= '1' when ( alien_clk_en = '1' ) else '0'; 
    sw(1) <= '1' when ( (alien4_col+5) = 440 ) else '0';
    sw(2) <= '1' when ( (alien0_col-5) = 200 ) else '0';
    sw(3) <= '1' when ( ((alienBottomRow_row + 4) >= 340) ) else '0';
    
    -- Used to keep track of the score for the function
    score_keep_for_function <= not alien14_en & not alien13_en & not alien12_en & not alien11_en & not alien10_en & 
                               not alien9_en & not alien8_en & not alien7_en & not alien6_en & not alien5_en & 
                               not alien4_en & not alien3_en & not alien2_en & not alien1_en & not alien0_en;
    
    ---------------------------------------
    -- Slow Process for Bullets to move
    ---------------------------------------
    process(clk)
    begin 
        if (rising_edge(clk)) then
            if (reset_n = '0') then
                -- DO NOTHING 
            elsif (bullet_clk_en = '1') then 
    
                if (cw_bullet(0) = '1') then 
                    alien0_en <= '1';
                else 
                    alien0_en <= '0';
                end if;
                
                if (cw_bullet(1) = '1') then 
                    alien1_en <= '1';
                else 
                    alien1_en <= '0';
                end if;
                
                if (cw_bullet(2) = '1') then 
                    alien2_en <= '1';
                else 
                    alien2_en <= '0';
                end if;
                
                if (cw_bullet(3) = '1') then 
                    alien3_en <= '1';
                else 
                    alien3_en <= '0';
                end if;
                
                if (cw_bullet(4) = '1') then 
                    alien4_en <= '1';
                else 
                    alien4_en <= '0';
                end if;
                
                if (cw_bullet(5) = '1') then 
                    alien5_en <= '1';
                else 
                    alien5_en <= '0';
                end if;
                
                if (cw_bullet(6) = '1') then 
                    alien6_en <= '1';
                else 
                    alien6_en <= '0';
                end if;
                
                if (cw_bullet(7) = '1') then 
                    alien7_en <= '1';
                else 
                    alien7_en <= '0';
                end if;
                
                if (cw_bullet(8) = '1') then 
                    alien8_en <= '1';
                else 
                    alien8_en <= '0';
                end if;
                
                if (cw_bullet(9) = '1') then 
                    alien9_en <= '1';
                else 
                    alien9_en <= '0';
                end if;
                
                if (cw_bullet(10) = '1') then 
                    alien10_en <= '1';
                else 
                    alien10_en <= '0';
                end if;
                
                if (cw_bullet(11) = '1') then 
                    alien11_en <= '1';
                else 
                    alien11_en <= '0';
                end if;
                
                if (cw_bullet(12) = '1') then 
                    alien12_en <= '1';
                else 
                    alien12_en <= '0';
                end if;
                
                if (cw_bullet(13) = '1') then 
                    alien13_en <= '1';
                else 
                    alien13_en <= '0';
                end if;
                
                if (cw_bullet(14) = '1') then 
                    alien14_en <= '1';
                else 
                    alien14_en <= '0';
                end if;
                  
                if (cw_bullet(15) = '1') then 
                    bullet_en <= '1';
                end if;
                
                if (cw_bullet(15) = '0') then
                    bullet_en <= '0';
                end if;
                   
                if (cw_bullet(16) = '1') then
                    bullet_row <= bullet_row - 1;
                end if;
                    
                if (cw_bullet(17) = '1') then
                    bullet_col <= player_location;    
                end if;
                
                if (cw_bullet(18) = '1') then
                    bullet_row <= "101100001"; -- Default value of 369    
                end if;
                
                if (cw_bullet(19) = '1') then
                    win <= '1';
                end if;
                
                if (cw_bullet(20) = '1') then
                    alien0_en <= '1';
                    alien1_en <= '1';
                    alien2_en <= '1';
                    alien3_en <= '1';
                    alien4_en <= '1';
                    alien5_en <= '1';
                    alien6_en <= '1';
                    alien7_en <= '1';
                    alien8_en <= '1';
                    alien9_en <= '1';
                    alien10_en <= '1';
                    alien11_en <= '1';
                    alien12_en <= '1';
                    alien13_en <= '1';
                    alien14_en <= '1';
                    win <= '0';
                end if;
                
            end if;
        end if;
    end process; 
    
    -- CSA's for the Bullet Control Unit
    
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
-------------------------------------------------------------------------------------------------------------------------------------------
    sw_bullet(0) <= '1' when ( arduino_comm(3) = '1' ) else '0';
    sw_bullet(1) <= '1' when ( bullet_clk_en = '1' ) else '0';
    sw_bullet(2) <= '1' when ( (bullet_row-5 = alienBottomRow_row+4) ) else '0';
    sw_bullet(3) <= '1' when ( (bullet_row-5 = alienMiddleRow_row+4) ) else '0'; 
    sw_bullet(4) <= '1' when ( (bullet_row-5 = alienTopRow_row+4) ) else '0';
    sw_bullet(5) <= '1' when ( (bullet_col <= alien0_col+5) AND (bullet_col >= alien0_col-5) ) else '0'; 
    sw_bullet(6) <= '1' when ( (bullet_col <= alien1_col+5) AND (bullet_col >= alien1_col-5) ) else '0'; 
    sw_bullet(7) <= '1' when ( (bullet_col <= alien2_col+5) AND (bullet_col >= alien2_col-5) ) else '0'; 
    sw_bullet(8) <= '1' when ( (bullet_col <= alien3_col+5) AND (bullet_col >= alien3_col-5) ) else '0'; 
    sw_bullet(9) <= '1' when ( (bullet_col <= alien4_col+5) AND (bullet_col >= alien4_col-5) ) else '0';
    sw_bullet(10) <= '1' when ( (bullet_row-5 = 70) ) else '0'; 

    sw_bullet(11) <= alien0_en; 
    sw_bullet(12) <= alien1_en;
    sw_bullet(13) <= alien2_en; 
    sw_bullet(14) <= alien3_en;
    sw_bullet(15) <= alien4_en; 
    sw_bullet(16) <= alien5_en;
    sw_bullet(17) <= alien6_en; 
    sw_bullet(18) <= alien7_en;
    sw_bullet(19) <= alien8_en; 
    sw_bullet(20) <= alien9_en;
    sw_bullet(21) <= alien10_en; 
    sw_bullet(22) <= alien11_en;
    sw_bullet(23) <= alien12_en; 
    sw_bullet(24) <= alien13_en;
    sw_bullet(25) <= alien14_en; 
    sw_bullet(26) <= '1' when (win_clk_en = '1') else '0';

end Behavioral;
