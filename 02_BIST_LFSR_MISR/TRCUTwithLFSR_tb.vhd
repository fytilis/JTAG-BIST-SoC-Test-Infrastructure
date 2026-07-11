library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all; -- For prints in Transcript

entity TRCUTwithLFSR_tb is
end entity;

architecture behavior of TRCUTwithLFSR_tb is
    signal clk      : std_logic := '0';
    signal se       : std_logic := '0';
    signal so       : std_logic;
    signal sim_done : boolean := false; -- Signal to end the simulation

    constant clk_period : time := 20 ns;
begin
    -- Instance of the circuit
    uut: entity work. TRCUTwithLFSR
        port map (
            CLK => clk,
            SE  => se,
            SO  => so
        );

    -- Clock production that stops when sim_done = true
    clk_process : process
    begin
        while not sim_done loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Main control process for 32 workloads
    stim_proc: process
        variable i, j : integer;
    begin		
        -- Initialization
        se <= '0';
        wait for clk_period * 2;

        report "--- STARTING 32 PSEUDORANDOM TEST VECTORS ---";

        for i in 1 to 32 loop
            -- Shift Phase: SE = '1' for 4 cycles (chain length: Rd, Rc, Rbi, Raj)
            se <= '1';
            for j in 1 to 4 loop
                wait until rising_edge(clk);
                -- Here you can observe the SO (Scan Out)
            end loop;

            -- Capture Phase: SE = '0' for 1 cycle
            se <= '0';
            wait until rising_edge(clk);
            
            report "Vector " & integer'image(i) & " applied and captured.";
        end loop;

        report "--- 32 VECTORS COMPLETED ---";
        sim_done <= true; -- The clock stops
        wait;
    end process;
end architecture;
