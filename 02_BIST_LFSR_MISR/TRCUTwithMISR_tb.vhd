library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity TRCUTwithMISR_tb is
end entity;

architecture behavior of TRCUTwithMISR_tb is
    -- Control signals (as in 2.2)
    signal clk      : std_logic := '0';
    signal se       : std_logic := '0';
    signal sign     : std_logic;
    signal sim_done : boolean := false;

    -- Signal to store the Golden Signature (visible in waveform)
    signal golden_signature : std_logic_vector(15 downto 0) := (others => '0');

    constant clk_period : time := 20 ns;
    constant SCAN_CHAIN_LENGTH : integer := 4; -- Chain Length (Rd, Rc, Rbi, Raj) 

begin
    -- 1. Instance of the TRCUTwithMISR circuit
    uut: entity work. TRCUTwithMISR
        port map (
            CLK  => clk,
            SE   => se,
            sign => sign
        );

    -- 2. Clock Generation (ends with sim_done)
    clk_process : process
    begin
        while not sim_done loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- 3. Main Control Process (Stimulus)
    stim_proc: process
    begin		
        -- Initialization 
        se <= '0';
        wait for clk_period * 2;

        report "--- PHASE A: APPLYING 32 TEST VECTORS ---";
        
        for i in 1 to 32 loop
            -- Phase Shift: SE = '1' for 4 cycles
            se <= '1';
            for j in 1 to SCAN_CHAIN_LENGTH loop
                wait until rising_edge(clk);
            end loop;

            -- Capture Phase: SE = '0' for 1 cycle 
            se <= '0';
            wait until rising_edge(clk);
            
            -- Transcript progress report
            if (i mod 8 = 0) then
                report "Processed " & integer'image(i) & " vectors...";
            end if;
        end loop;

        report "--- PHASE B: EXTRACTING 16-BIT SIGNATURE ---";
        
        -- Signature Extraction: SE = '1' for 16 cycles 
        se <= '1'; 
        for i in 0 to 15 loop
            wait until rising_edge(clk);
            -- Saving the bit to the corresponding location of the signal 
            golden_signature(i) <= sign; 
        end loop;

        report "--- SUCCESS: GOLDEN SIGNATURE COLLECTED ---";
        
        -- Shutdown to stop the simulation right here 
        sim_done <= true; 
        wait;
    end process;

end architecture;
