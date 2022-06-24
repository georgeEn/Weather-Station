-- Team Musketeers for Hardware Engineering Lab
-- VHDL project Work: VHDL code for traffic light controller
-- Submitted to Engineer Ali Hayek
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  

-- The proposed project is a Traffic light controller at an intersection between a RemoteStreet and Highway 
-- The Remote street has on its side ways sensors that sense if vehicles are coming 
-- The Traffic light in the remotestreer turns to YELLOW before GREEN to allow the vehicles cross the highway 
-- If Otherwise, the highway traffic light is always GREEN and always RED on the RemoteStreet light
-- The time period of light change is 3 seconds for the YELLOW light and 10 seconds for the RED light. 

entity Traffic_light_controller is
 port ( clk  : in STD_LOGIC; -- clock in standard logic
		sensor  : in STD_LOGIC; -- Sensor in standard logic
      		rstn: in STD_LOGIC; -- reset active low in standard logic
       	 	Highway_light  : out STD_LOGIC_VECTOR(2 downto 0); -- Highway light outputs
    	 	RemoteStreet_light:    out STD_LOGIC_VECTOR(2 downto 0)-- RemoteStreet light outputs 
     -- The three basic light colours: RED_YELLOW_GREEN 
   );
end Traffic_light_controller;

architecture Traffic_light of Traffic_light_controller is

		signal delay_count:std_logic_vector(3 downto 0):= x"0";
		signal delay_10s, delay_3s_RS,delay_3s_H, RED_LIGHT_ENABLE, YELLOW_LIGHT1_ENABLE,YELLOW_LIGHT2_ENABLE: std_logic:='0';
		signal counter_1s: std_logic_vector(27 downto 0):= x"0000000";
		signal clk_1s_enable: std_logic; -- 1s clock enable 

type FSM_States is (HGRE_RSRED, HYEL_RSRED, HRED_RSGRE, HRED_RSYEL);
	-- HGRE_RSRED : It states Highway Green and RemoteStreet red
	-- HYEL_RSRED : It states Highway Yellow and RemoteStreet red
	-- HRED_RSGRE : It states Highway Red and RemoteStreet green
	-- HRED_RSYEL : It states Highway Red and RemoteStreet yellow
signal current_state, next_state: FSM_States;
begin
	-- next state using FSM sequential logic 
process(clk,rstn) 
	begin
	if(rstn='0') then
	current_state <= HGRE_RSRED;
	elsif(rising_edge(clk)) then 
 	current_state <= next_state; 
	end if; 
end process;

	-- FSM combinatoral logic begins here
process(current_state,sensor,delay_3s_RS,delay_3s_H,delay_10s)
begin
case current_state is 
	when HGRE_RSRED => -- When Green light on Highway and Red light on RemoteStreet
	RED_LIGHT_ENABLE <= '0';-- This disables the RED light delay counting
 	YELLOW_LIGHT1_ENABLE <= '0';-- This disables YELLOW light Highway delay counting
	YELLOW_LIGHT2_ENABLE <= '0';-- This disables YELLOW light RemoteStreet delay counting
 	Highway_light <= "001"; -- Green light on Highway
 	RemoteStreet_light <= "100"; -- Red light on RemoteStreet 

 if(sensor = '1') then -- if the sensors on the RemoteStreet detect Vehicles
	next_state <= HYEL_RSRED;
  	-- The Highway automatically turns to Yellow light 
 	else 
  	next_state <= HGRE_RSRED; 
  -- Otherwise, The Highway light remains green and always Red on the RemoteStreet
 end if;

	when HYEL_RSRED => -- When Yellow light on Highway and Red light on RemoteStreet
 	Highway_Light <= "010";-- Yellow light on Highway
 	RemoteStreet_light <= "100";-- Red light on RemoteStreet 
 	RED_LIGHT_ENABLE <= '0';-- This disables RED light delay counting
	YELLOW_LIGHT1_ENABLE <= '1';-- This enables YELLOW light Highway delay counting
 	YELLOW_LIGHT2_ENABLE <= '0';-- This disables YELLOW light RemoteStreet delay counting

 if(delay_3s_H='1') then 
	-- if Yellow light delay counts to 3s, 
	-- turn Highway to RED, 
 	-- RemoteStreet to Green light 
  	next_state <= HRED_RSGRE; 
 else 
  	next_state <= HYEL_RSRED; 
  	-- The Highway light remains Yellow and Red on RemoteStreet 
  	-- if Yellow light not yet in 3s 
 end if;

	when HRED_RSGRE => -- When Red light on Highway and Green light on RemoteStreet
 	Highway_light <= "100";-- RED light on Highway 
 	RemoteStreet_light <= "001";-- GREEN light on RemoteStreet 
 	RED_LIGHT_ENABLE <= '1';-- enable RED light delay counting
 	YELLOW_LIGHT1_ENABLE <= '0';-- disable YELLOW light Highway delay counting
 	YELLOW_LIGHT2_ENABLE <= '0';-- disable YELLOW light RemoteStreet delay counting

 if(delay_10s='1') then
 	-- if the RED light on the Highway is 10s, RemoteStreet turns to Yellow
 	 next_state <= HRED_RSYEL;
 else 
  	next_state <= HRED_RSGRE; 
 	 -- Remains Green on the RemoteStreet if delay counts for RED light on Highway is not yet 10s 
 end if;

when HRED_RSYEL => -- When Red light on Highway and Yellow light on RemoteStreet
 	Highway_light <= "100";-- RED light on Highway 
 	RemoteStreet_light  <= "010";-- Yellow light on RemoteStreet
 	RED_LIGHT_ENABLE <= '0'; -- disable RED light delay counting
 	YELLOW_LIGHT1_ENABLE <= '0';-- disable YELLOW light Highway delay counting
 	YELLOW_LIGHT2_ENABLE <= '1';-- enable YELLOW light RemoteStreet delay counting

 if(delay_3s_RS='1') then 
	-- if delay for Yellow light is 3s,
 	-- turn highway to GREEN light
 	-- RemoteStreet to RED Light
 	next_state <= HGRE_RSRED;
 	else 
 next_state <= HRED_RSYEL;
	 -- Remains Yellow on the RemoteStreet if delay counts for RED light on Highway is not yet 3s 
 end if;
	when others => next_state <= HGRE_RSRED; -- Green on highway, red on RemoteStreet
end case;
end process;
	-- Delay counts for Yellow and RED light  
process(clk)
begin
if(rising_edge(clk)) then 
	if(clk_1s_enable='1') then
 	if(RED_LIGHT_ENABLE='1' or YELLOW_LIGHT1_ENABLE='1' or YELLOW_LIGHT2_ENABLE='1') then
  	delay_count <= delay_count + x"1";
  	if((delay_count = x"9") and RED_LIGHT_ENABLE ='1') then 
   	delay_10s <= '1';
   	delay_3s_H <= '0';
   	delay_3s_RS <= '0';
   	delay_count <= x"0";
  elsif((delay_count = x"2") and YELLOW_LIGHT1_ENABLE= '1') then
  	delay_3s_H <= '1';
   	delay_3s_RS <= '0';
   	delay_count <= x"0";
  elsif((delay_count = x"2") and YELLOW_LIGHT2_ENABLE= '1') then
   	delay_10s <= '0';
   	delay_3s_H <= '0';
   	delay_3s_RS <= '1';
   	delay_count <= x"0";
  else
   	delay_10s <= '0';
   	delay_3s_H <= '0';
   	delay_3s_RS <= '0';
  end if;
 end if;
 end if;
end if;
end process;
-- create delay 1s 
process(clk)
begin
if(rising_edge(clk)) then 
 	counter_1s <= counter_1s + x"0000001";
 	if(counter_1s >= x"0000003") then 
  	counter_1s <= x"0000000";
 end if;
end if;
end process;
clk_1s_enable <= '1' when counter_1s = x"0003" else '0'; 
end traffic_light;