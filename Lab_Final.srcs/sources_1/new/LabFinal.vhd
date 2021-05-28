---------------------------------------------------------------------------------
-- Name:	Tom Faulconer
-- Date:	Spring 2020
-- Course: 	CSCE 436
-- File: 	LabFinal.vhd
-- HW:		Final Lab
-- Purp:	Top level of the space invader alien game
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

entity LabFinal is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
		   arduino_comm : in STD_LOGIC_VECTOR(3 downto 0); -- set these equal to JB PMOD connector in XDC file
		   tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0)
		   );
end LabFinal;

architecture behavior of LabFinal is

    -- Declare Signals
	signal sw: std_logic_vector(3 downto 0);
	signal cw: std_logic_vector (3 downto 0);
	
	signal sw_bullet : std_logic_vector(26 downto 0);
	signal cw_bullet : std_logic_vector (20 downto 0);

    -- Declare Components
	COMPONENT LabFinal_cu is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (3 downto 0);
           cw : out STD_LOGIC_VECTOR (3 downto 0));
    end COMPONENT;
    
    COMPONENT LabFinal_dp is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           arduino_comm : in STD_LOGIC_VECTOR(3 downto 0);
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
           sw_bullet : out STD_LOGIC_VECTOR (26 downto 0); 
           cw_bullet : in STD_LOGIC_VECTOR (20 downto 0); 
           sw : out STD_LOGIC_VECTOR (3 downto 0);
           cw : in STD_LOGIC_VECTOR (3 downto 0)
           );
    end COMPONENT;
    
    COMPONENT LabFinal_cu_bullet is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           sw_bullet : in STD_LOGIC_VECTOR (26 downto 0);
           cw_bullet : out STD_LOGIC_VECTOR (20 downto 0));
    end COMPONENT;
    
begin
 
    -- Instantiate Components
	datapath: LabFinal_dp port map(
           clk => clk,
           reset_n => reset_n,
           arduino_comm => arduino_comm,
           tmds => tmds,
           tmdsb => tmdsb,
           sw_bullet => sw_bullet,
           cw_bullet => cw_bullet,
           sw => sw,
           cw => cw
           );
		
			  
	alien_control: LabFinal_cu port map( 
		clk => clk,
		reset_n => reset_n,
		sw => sw,
		cw => cw
		);
		
	bullet_control : LabFinal_cu_bullet port map(
	    clk => clk,
	    reset_n => reset_n,
	    sw_bullet => sw_bullet,
	    cw_bullet => cw_bullet
	    );	

end behavior;

