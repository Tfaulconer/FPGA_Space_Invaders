library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab_final_cu_tb is

end lab_final_cu_tb;

architecture Behavioral of lab_final_cu_tb is

    -- Declare componetns
--    COMPONENT LabFinal_cu is
--    Port ( clk : in STD_LOGIC;
--           reset_n : in STD_LOGIC;
--           sw : in STD_LOGIC_VECTOR (3 downto 0);
--           cw : out STD_LOGIC_VECTOR (18 downto 0));
--    end COMPONENT;
    
    
--    COMPONENT LabFinal_dp is
--        Port ( clk : in STD_LOGIC;
--               reset_n : in STD_LOGIC;
--               arduino_comm : in STD_LOGIC_VECTOR(3 downto 0);
--               tmds : out  STD_LOGIC_VECTOR (3 downto 0);
--               tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
--               sw : out STD_LOGIC_VECTOR (3 downto 0);
--               cw : in STD_LOGIC_VECTOR (18 downto 0)
--               );
--    end COMPONENT;
    
    COMPONENT LabFinal_cu_bullet is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           sw_bullet : in STD_LOGIC_VECTOR (25 downto 0);
           cw_bullet : out STD_LOGIC_VECTOR (18 downto 0));
    end COMPONENT;

    -------------------------------------------------------
    -- Signals
    -------------------------------------------------------
    
    -- Inputs
    signal clk : std_logic := '0';
    signal reset_n : std_logic := '0';
--    signal sw : std_logic_vector(3 downto 0) := (others => '0');
--    signal arduino_comm : std_logic_vector(3 downto 0) := (others => '0');
    signal sw_bullet : std_logic_vector(25 downto 0) := (others => '0');

    
    -- Outputs
--    signal cw: std_logic_vector (18 downto 0) := (others => '0');
    signal cw_bullet : STD_LOGIC_VECTOR (18 downto 0) := (others => '0');

    -- Clock period definitions
   constant clk_period : time := 10 ns;  -- Sets clock to ~ 100MHz
--   signal alien_counter : unsigned(21 downto 0) := (others => '0');
--   signal alien_clk_en : std_logic;
   signal bullet_counter : unsigned(19 downto 0) := (others => '0');
   signal bullet_clk_en : std_logic;
   
--   type state_type is (Reset, MoveRight, WaitForEnableR, HitRBoundary, DecreaseRowR, MoveLeft, WaitForEnableL, HitLBoundary, DecreaseRowL);
--   signal state: state_type;

    type state_type is (Reset, WaitForFireCommand, Fire, MoveBulletUp, HitTopBoundary,
                        Alien0BottomCollision, Alien1BottomCollision, Alien2BottomCollision, Alien3BottomCollision, Alien4BottomCollision, 
                        Alien0MiddleCollision, Alien1MiddleCollision, Alien2MiddleCollision, Alien3MiddleCollision, Alien4MiddleCollision, 
                        Alien0TopCollision, Alien1TopCollision, Alien2TopCollision, Alien3TopCollision, Alien4TopCollision);
    signal state: state_type;
    

begin


-- Instantiate Components
--    uut: LabFinal_cu port map (
--        clk => clk,
--        reset_n => reset_n,
--        sw => sw, -- input
--        cw => cw -- output
--        );
        
--   uut2: LabFinal_dp port map (
--        clk => clk,
--        reset_n => reset_n,
--        arduino_comm => arduino_comm,
--        tmds => OPEN,
--        tmdsb => OPEN,
--        sw => sw, -- output
--        cw => cw -- input
--        );    

    uut: LabFinal_cu_bullet port map (
        clk => clk,
        reset_n => reset_n,
        sw_bullet => sw_bullet, -- input
        cw_bullet => cw_bullet -- output
        ); 

   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;    
    
       -- Stimulus process
   stim_proc: process 
   begin		
		reset_n <= '1';
		-- When doing the control unit (sw => input // cw => output)
--	    alien_clk_en <= sw(0);
----	    -- sw(0) = alien_clk_en which is roughly 25 Hz 
--	    sw(0) <= '1', '0' after 10 ns, '1' after 39.999995 ms, '0' after 40.000005 ms, '1' after 79.999995 ms, '0' after 80.000005 ms,
--	             '1' after 119.999995 ms, '0' after 120.000005 ms, '1' after 159.999995 ms, '0' after 160.000005 ms;
	    
--	    -- sw(1) = alien4_col + 5
--	    sw(1) <= '0', '1' after 80ms; 
	    

        -- When doing datapath (cw => input // sw => output)
	    
--	    cw <= "1010111111111111111", "0010111111111111111" after 5.000005 ms, "0100111111111111111" after 10.000005 ms;



        -- when doing control unit bullet
        bullet_clk_en <= sw_bullet(1);
        
        sw_bullet(0) <= '0', '1' after 5 ms;
        
        -- bullet_clk_en is roughly 50 Hz (47.68 Hz)
        sw_bullet(1) <= '1', '0' after 10 ns, '1' after 19.999995 ms, '0' after 20.000005 ms, '1' after 39.999995 ms, '0' after 40.000005 ms,
	                     '1' after 59.999995 ms, '0' after 60.000005 ms, '1' after 79.999995 ms, '0' after 80.000005 ms,
	                     '1' after 99.999995 ms, '0' after 100.000005 ms, '1' after 119.999995 ms, '0' after 120.000005 ms,
	                     '1' after 139.999995 ms, '0' after 140.000005 ms;
       
        sw_bullet(2) <= '0', '1' after 6 ms; -- bottom row collision
        sw_bullet(5) <= '0', '1' after 6 ms; -- alien 0 collision  
           
       
        sw_bullet(11) <= '1';
        sw_bullet(12) <= '1';
        sw_bullet(13) <= '1';
        sw_bullet(14) <= '1';
        sw_bullet(15) <= '1';
        sw_bullet(16) <= '1';
        sw_bullet(17) <= '1';
        sw_bullet(18) <= '1';
        sw_bullet(19) <= '1';
        sw_bullet(20) <= '1';
        sw_bullet(21) <= '1', '0' after 80 ms; -- alien 10 enable
        sw_bullet(22) <= '1';
        sw_bullet(23) <= '1';
        sw_bullet(24) <= '1';
        sw_bullet(25) <= '1';
       
        
		
		wait;
   end process;

end Behavioral;
