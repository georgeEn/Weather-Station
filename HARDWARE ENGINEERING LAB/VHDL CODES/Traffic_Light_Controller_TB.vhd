-- fpga4student.com FPGA projects, VHDL projects, Verilog projects
-- VHDL project: VHDL code for traffic light controller
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- Testbench VHDL code for traffic light controller 
ENTITY tb_traffic_light_controller IS
END tb_traffic_light_controller;

ARCHITECTURE behavior OF tb_traffic_light_controller IS 
    -- Component Declaration for the traffic light controller 
    COMPONENT traffic_light_controller
    PORT(
         sensor : IN  std_logic;
         clk : IN  std_logic;
         rstn : IN  std_logic;
         light_highway : OUT  std_logic_vector(2 downto 0);
         light_farm : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
   signal sensor : std_logic := '0';
   signal clk : std_logic := '0';
   signal rst_n : std_logic := '0';
  --Outputs
   signal light_highway : std_logic_vector(2 downto 0);
   signal light_farm : std_logic_vector(2 downto 0);
   constant clk_period : time := 10 ns;
BEGIN
 -- Instantiate the traffic light controller 
   trafficlightcontroller : traffic_light_controller PORT MAP (
          sensor => sensor,
          clk => clk,
          rstn => rstn,
          light_highway => light_highway,
          light_farm => light_farm
        );
   -- Clock process definitions
   clk_process :process
   begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
   end process;
   stim_proc: process
   begin    
  rstn <= '0';
  sensor <= '0';
      wait for clk_period*10;
  rstn <= '1';
  wait for clk_period*20;
  sensor <= '1';
  wait for clk_period*100;
  sensor <= '0';
      wait;
   end process;

END;
