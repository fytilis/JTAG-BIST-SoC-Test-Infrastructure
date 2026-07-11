library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity tb_bsc is
end tb_bsc;

architecture behavior of tb_bsc is
    component bsc
        Port (
            DataIn, ShiftIn, ShiftDR, ClockDR, UpdateDR, Mode : in STD_LOGIC;
            DataOut, ShiftOut : out STD_LOGIC
        );
    end component;

    signal DataIn, ShiftIn, ShiftDR, ClockDR, UpdateDR, Mode : STD_LOGIC := '0';
    signal DataOut, ShiftOut : STD_LOGIC;

begin
    uut: bsc Port Map (DataIn, ShiftIn, ShiftDR, ClockDR, UpdateDR, Mode, DataOut, ShiftOut);

    stim_proc: process
    begin
        wait for 20 ns;

        -----------------------------------------------------------
        -- A) Save to CAP FF by Internal Logic (Capture) 
        -----------------------------------------------------------
        ShiftDR <= '0';
		  DataIn <= '1'; 
		  wait for 10 ns;
        ClockDR <= '1'; 
		  wait for 10 ns; ClockDR <= '0';
        -- VERIFY: cap_ff should be made '1' 
        wait for 5 ns;

        -----------------------------------------------------------
        -- B) Save to CAP FF by ShiftIn (Shift) 
        -----------------------------------------------------------
        ShiftDR <= '1'; ShiftIn <= '0'; wait for 10 ns;
        ClockDR <= '1'; wait for 10 ns; ClockDR <= '0';
        -- VERIFY: cap_ff should be made '0' 
        wait for 5 ns;

        -----------------------------------------------------------
        -- C) Transfer from CAP FF to UPD FF (Update) 
        -----------------------------------------------------------
        -- Preparation: Put '1' on the CAP FF
        ShiftDR <= '0'; DataIn <= '1'; wait for 10 ns;
        ClockDR <= '1'; wait for 10 ns; ClockDR <= '0'; 
        
        -- Run Update
        wait for 10 ns;
        UpdateDR <= '1'; wait for 10 ns; UpdateDR <= '0';
        -- VERIFY: upd_ff gets the value '1' 
        wait for 5 ns;

        -----------------------------------------------------------
        -- D) Normal Mode: DataIn Forwarding -> DataOut 
        -----------------------------------------------------------
        Mode <= '0'; DataIn <= '1'; wait for 20 ns;
        -- VERIFY: DataOut = DataIn immediately 
        DataIn <= '0'; wait for 20 ns;

        -----------------------------------------------------------
        -- E) Test Mode: Forward UPD FF -> DataOut (Isolation) 
        -----------------------------------------------------------
        Mode <= '1'; -- Enable Test Mode [cite: 85]
        DataIn <= '0'; -- Change DataIn for contrast control 
        wait for 20 ns;
        -- VERIFY: DataOut = '1' (from UPD) and NOT '0' (from DataIn) 

        report "BSC Verification Completed!" severity note;
        assert false report "End of Simulation" severity failure;
    end process;
end behavior;
