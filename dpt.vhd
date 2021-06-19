library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity dpt is
generic(ClockFrequencyHz : integer);
port(
    i_clk       : in std_logic;
    i_nRst      : in std_logic;  -- Negative reset, emergency stop
	i_trigger	: in std_logic;	 -- trigger to start the test (pushbutton)
    o_sw1_g		: out std_logic; -- gate signal of switch 1
	o_sw1_s		: out std_logic; -- gate signal reference (gnd) of switch 1
	o_sw2_g		: out std_logic; -- gate signal of switch 2
	o_sw2_s		: out std_logic; -- gate signal reference (gnd) of switch 2
	);
end entity;
 
architecture rtl of dpt is
 
    -- Enumerated type declaration and state signal declaration
    type t_State is (idle, t_on1, deadtime1, t_off1, deadtime2,
                        t_on2, deadtime3, t_off2, deadtime4);
    signal s_state : t_State;
 
    -- Counter for counting clock periods, 1 minute max
    signal r_counter : integer range 0 to ClockFrequencyHz * 60;
	
	-- control variables
	signal s_sw2_EN : std_logic := '0';	-- ENable the output for switch 2 (complementary switch)
 
begin
 
    process(i_clk) is
    begin
        if rising_edge(i_clk) then
            if nRst = '0' then
                -- Reset values
                s_state   <= idle;
                r_counter <= 0;
                o_sw1_g <= '0';
                o_sw1_s <= '0';
                o_sw2_g <= '0';
                o_sw2_s <= '0';
 
            else
                -- Default values
                o_sw1_g <= '0';
                o_sw1_s <= '0';
                o_sw2_g <= '0';
                o_sw2_s <= '0';
 
                Counter <= Counter + 1;
 
                case State is
 
                    -- wait for manual trigger
                    when idle =>
                        -- o_sw1_g <= '0';
						-- o_sw2_g <= '0';
                        -- If 5 seconds have passed
                        if rising_edge(w_trigger) then
                            Counter <= 0;
                            State   <= t_on1;
                        end if;
 
                    -- turn SW1 on 
                    when t_on1 =>
                        o_sw1_g <= '1';
						-- o_sw2_g <= '0';
                        -- If 5 seconds have passed
                        if Counter = ClockFrequencyHz * 5 -1 then
                            Counter <= 0;
                            State   <= North;
                        end if;
 
                    -- both switches off
                    when deadtime1 =>
                        -- o_sw1_g <= '0';
						-- o_sw2_g <= '0';
                        -- If 1 minute has passed
                        if Counter = ClockFrequencyHz * 60 -1 then
                            Counter <= 0;
                            State   <= StopNorth;
                        end if;
 
                    -- turn SW2 on if enabled
                    when t_off1 =>
                        -- o_sw1_g <= '0';
						-- o_sw2_g <= '0';
						
						if s_sw2_EN= '1' then
							o_sw2_g <= '1';
						end if;
                        -- If 5 seconds have passed
                        if Counter = ClockFrequencyHz * 5 -1 then
                            Counter <= 0;
                            State   <= WestNext;
                        end if;
 
                    -- both switches off
                    when deadtime2 =>
                        -- o_sw1_g <= '0';
						-- o_sw2_g <= '0';
                        -- If 5 seconds have passed
                        if Counter = ClockFrequencyHz * 5 -1 then
                            Counter <= 0;
                            State   <= StartWest;
                        end if;
 
                    -- Red and yellow in west/east direction
                    when t_on2 =>
                        o_sw1_g <= '1';
						-- o_sw2_g <= '0';
                        -- If 5 seconds have passed
                        if Counter = ClockFrequencyHz * 5 -1 then
                            Counter <= 0;
                            State   <= West;
                        end if;
 
                    -- both switches off
                    when deadtime3 =>
                        -- o_sw1_g <= '0';
						--o_sw2_g <= '0';
                        -- If 1 minute has passed
                        if Counter = ClockFrequencyHz * 60 -1 then
                            Counter <= 0;
                            State   <= StopWest;
                        end if;
 
                    -- Yellow in west/east direction
                    when t_off2 =>
                        -- o_sw1_g <= '0';
						-- o_sw2_g <= '0';
						if s_sw2_EN= '1' then
							o_sw2_g <= '1';
						end if;
                        -- If 5 seconds have passed
                        if Counter = ClockFrequencyHz * 5 -1 then
                            Counter <= 0;
                            State   <= NorthNext;
                        end if;
						
					-- Unnecesssary but for consistency, both switches off
					when deadtime4 =>
                        -- o_sw1_g <= '0';
						-- o_sw2_g <= '0';
                        -- If 5 seconds have passed
                        if Counter = ClockFrequencyHz * 5 -1 then
                            Counter <= 0;
                            State   <= NorthNext;
                        end if;
 
                end case;
 
            end if;
        end if;
    end process;
 
end architecture;