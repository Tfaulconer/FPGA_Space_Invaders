----------------------------------------------------------------------------------
-- Name:	Tom Faulconer
-- Date:	Spring 2020
-- Course: 	CSCE 436
-- File: 	video.vhd
-- HW:		Final Lab
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
library UNISIM;
use UNISIM.VComponents.all;


entity video is
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
end video;

architecture structure of video is

	signal red, green, blue: STD_LOGIC_VECTOR(7 downto 0);
	signal pixel_clk, serialize_clk, serialize_clk_n, blank, h_sync, v_sync: STD_LOGIC;
	signal clock_s, red_s, green_s, blue_s: STD_LOGIC;
	
	--signal h_synch, v_synch: STD_LOGIC;

	component vga is
	Port(	clk: in STD_LOGIC;
            reset_n : in STD_LOGIC;
            h_sync : out STD_LOGIC;
            v_sync : out STD_LOGIC;
            blank : out STD_LOGIC;
            r : out STD_LOGIC_VECTOR(7 downto 0);
            g : out STD_LOGIC_VECTOR(7 downto 0);
            b : out STD_LOGIC_VECTOR(7 downto 0);
           -- arduino_comm : in STD_LOGIC_VECTOR(3 downto 0); -- move left, move right, C button, Z button
            player_location : in unsigned (9 downto 0);
            row : out unsigned (9 downto 0);
            column : out unsigned (9 downto 0);
            bullet_col : in unsigned(9 downto 0);
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
	end component;
    --------------------------------------------------------------------------
    -- Clock Wizard Component Instantiation Using Xilinx Vivado 
    --------------------------------------------------------------------------
    component clk_wiz_0 is
    Port (
        clk_in1 : in STD_LOGIC;
        clk_out1 : out STD_LOGIC;
        clk_out2 : out STD_LOGIC;
        clk_out3 : out STD_LOGIC;
        resetn : in STD_LOGIC);
     end component;   

begin

	--------------------------------------------------------------------------
	-- Digital Clocking Wizard using Xilinx Vivado creates 25Mhz pixel clock and 
	-- 125MHz HDMI serial output clocks from 100MHz system clock. The Digital 
    -- Clocking Wizard is in the Vivado IP Catalog.
	--------------------------------------------------------------------------
	mmcm_adv_inst_display_clocks: clk_wiz_0
		Port Map (
			clk_in1 => clk,
			clk_out1 => pixel_clk, -- 25Mhz pixel clock
			clk_out2 => serialize_clk, -- 125Mhz HDMI serial output clock
			clk_out3 => serialize_clk_n, -- 125Mhz HDMI serial output clock 180 degrees out of phase
			resetn => reset_n);  -- active low reset for Nexys Video

	------------------------------------------------------------------------------
	-- H and V synch are used to interface to the DVID module
	------------------------------------------------------------------------------
	Inst_vga: vga
		PORT MAP(	clk => pixel_clk,
						reset_n => reset_n,
						h_sync => h_sync,
						v_sync => v_sync,
						blank => blank,
						r => red,
						g => green,
						b => blue,
						row => row,
						column => column,
						alien0_en	=> alien0_en,
						alien1_en	=> alien1_en,
						alien2_en	=> alien2_en,
						alien3_en	=> alien3_en,
						alien4_en	=> alien4_en,
						alien5_en	=> alien5_en,
						alien6_en	=> alien6_en,
						alien7_en	=> alien7_en,
						alien8_en	=> alien8_en,
						alien9_en	=> alien9_en,
						alien10_en	=> alien10_en,
						alien11_en	=> alien11_en,
						alien12_en	=> alien12_en,
						alien13_en	=> alien13_en,
						alien14_en	=> alien14_en,
						alien0_col => alien0_col,
						alien1_col => alien1_col,
						alien2_col => alien2_col,
						alien3_col => alien3_col,
						alien4_col => alien4_col,
						alienTopRow_row => alienTopRow_row,
						alienMiddleRow_row => alienMiddleRow_row,
						alienBottomRow_row => alienBottomRow_row,
						bullet_row => bullet_row,
						bullet_col => bullet_col,
						bullet_en => bullet_en,
						player_location => player_location,
						n_bits => n_bits,
						win => win
						); 

	------------------------------------------------------------------------------
	-- This module was provided to us free of charge.  It converts a VGA signal
	-- into DVID/HDMI signal.
	------------------------------------------------------------------------------	 
    inst_dvid: entity work.dvid 
		port map(	clk       => serialize_clk,
						clk_n     => serialize_clk_n, 
						clk_pixel => pixel_clk,
						red_p     => red,
						green_p   => green,
						blue_p    => blue,
						blank     => blank,
						hsync     => h_sync,
						vsync     => v_sync,
						red_s     => red_s,
						green_s   => green_s,
						blue_s    => blue_s,
						clock_s   => clock_s		);


	------------------------------------------------------------------------------
	-- This HDMI signals are high speed so buffer to insure signal integrity.
	------------------------------------------------------------------------------
	OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
	OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
	OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
	OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );

end structure;
