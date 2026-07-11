library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity JTAG_tb is
end JTAG_tb;

architecture Behavioral of JTAG_tb is

    -- Interface signals with the Top Module
    signal a_in, b_in, c_in, d_in : STD_LOGIC := '0';
    signal i_out, j_out           : STD_LOGIC;
    signal TDI, TCK, TMS, TRST    : STD_LOGIC := '0';
    signal TDO                    : STD_LOGIC;
	 signal state_ascii_tb : STRING(1 to 16);
	 signal mode_val : STD_LOGIC;
    signal ir_val   : STD_LOGIC_VECTOR(1 downto 0);
    signal upd_i_val: STD_LOGIC;
    constant TCK_PERIOD : time := 100 ns;

begin

    -- 1. Connecting the Unit Under Test (UUT)
    UUT: entity work. JTAG_Chip_Top
        port map (
            a_pin => a_in, b_pin => b_in, c_pin => c_in, d_pin => d_in,
            i_pin => i_out, j_pin => j_out,
            TDI => TDI, TCK => TCK, TMS => TMS, TRST => TRST, TDO => TDO,
				state_name_top => state_ascii_tb,
				debug_mode  => mode_val,
            debug_ir    => ir_val,
            debug_upd_i => upd_i_val
        );

    -- 2. TCK Clock Genaration
    TCK_process : process
    begin
        TCK <= '0'; wait for TCK_PERIOD/2;
        TCK <= '1'; wait for TCK_PERIOD/2;
    end process;

    -- 3. Main Test Procedure (Stimulus)
   stim_proc: process
    begin		
        -- INITIALIZE PINS (Normal Mode)
        a_in <= '1'; b_in <= '0'; c_in <= '1'; d_in <= '0';
        TMS <= '1'; TDI <= '0'; TRST <= '1';
        wait for TCK_PERIOD * 2;
        TRST <= '0'; -- Disable Reset 

        -- ==========================================================
        -- STEP 1: SAMPLE/PRELOAD (COMMAND "01")
        -- ==========================================================
        -- Switch to Shift-IR
        TMS <= '0'; wait for TCK_PERIOD; -- Idle 
        TMS <= '1'; wait for TCK_PERIOD; -- Select-DR-Scan 
        TMS <= '1'; wait for TCK_PERIOD; -- Select-IR-Scan 
        TMS <= '0'; wait for TCK_PERIOD; -- Capture-IR 
        TMS <= '0'; wait for TCK_PERIOD; -- Shift-IR 
        
        -- Load command "01" (LSB: 1, MSB: 0)
        TDI <= '1'; wait for TCK_PERIOD; -- Bit 0 
        TDI <= '0'; TMS <= '1'; wait for TCK_PERIOD; -- Bit 1 & Exit1-IR 
        TMS <= '1'; wait for TCK_PERIOD; -- Update-IR 
        TMS <= '0'; wait for TCK_PERIOD; -- Back to Idle 

        -- Sample and Preload
        TMS <= '1'; wait for TCK_PERIOD; -- Select-DR-Scan 
        TMS <= '0'; wait for TCK_PERIOD; -- Capture-DR (This is where the SAMPLE is made) 
        TMS <= '0'; wait for TCK_PERIOD; -- Shift-DR (This is where the PRELOAD happens) 
        
        -- We send vector "101100" (for the 6 BSCs) 
        TDI <= '1'; wait for TCK_PERIOD; -- Bit 1
        TDI <= '0'; wait for TCK_PERIOD; -- Bit 2
        TDI <= '1'; wait for TCK_PERIOD; -- Bit 3
        TDI <= '1'; wait for TCK_PERIOD; -- Bit 4
        TDI <= '0'; wait for TCK_PERIOD; -- Bit 5
        TDI <= '0'; TMS <= '1'; wait for TCK_PERIOD; -- Bit 6 & Exit1-DR 
        
        TMS <= '1'; wait for TCK_PERIOD; -- Update-DR 
        TMS <= '0'; wait for TCK_PERIOD; -- Idle 

        -- ==========================================================
        -- STEP 2: INTEST (COMMAND "10")
        -- ==========================================================
        -- Load command "10" on IR
        TMS <= '1'; wait for TCK_PERIOD; -- Select-DR-Scan 
        TMS <= '1'; wait for TCK_PERIOD; -- Select-IR-Scan 
        TMS <= '0'; wait for TCK_PERIOD; -- Capture-IR
        TMS <= '0'; wait for TCK_PERIOD; -- Shift-IR
        TDI <= '0'; wait for TCK_PERIOD; -- Bit 0 
        TDI <= '1'; TMS <= '1'; wait for TCK_PERIOD; -- Bit 1 & Exit1-IR 
        TMS <= '1'; wait for TCK_PERIOD; -- Update-IR 

        -- Apply values to CUT (a=1, b=1, c=0, d=0) 
        TMS <= '0'; wait for TCK_PERIOD; -- Idle 
        TMS <= '1'; wait for TCK_PERIOD; -- Select-DR-Scan 
        TMS <= '0'; wait for TCK_PERIOD; -- Capture-DR 
        TMS <= '0'; wait for TCK_PERIOD; -- Shift-DR 
        TDI <= '1'; wait for TCK_PERIOD; -- a='1' 
        TDI <= '1'; wait for TCK_PERIOD; -- b='1' 
        TDI <= '0'; wait for TCK_PERIOD; -- c='0' 
        TDI <= '0'; wait for TCK_PERIOD; -- d='0' 
        TDI <= '0'; wait for TCK_PERIOD; -- Dummy i
        TDI <= '0'; TMS <= '1'; wait for TCK_PERIOD; -- Dummy j & Exit1-DR 
        TMS <= '1'; wait for TCK_PERIOD; -- Update-DR 

        -- ==========================================================
        -- STEP 3: BYPASS (COMMAND "11")
        -- ==========================================================
        -- Load command "11" into IR
        TMS <= '1'; wait for TCK_PERIOD; -- Select-DR-Scan 
        TMS <= '1'; wait for TCK_PERIOD; -- Select-IR-Scan 
        TMS <= '0'; wait for TCK_PERIOD; -- Capture-IR 
        TMS <= '0'; wait for TCK_PERIOD; -- Shift-IR 
        TDI <= '1'; wait for TCK_PERIOD; -- Bit 0 
        TDI <= '1'; TMS <= '1'; wait for TCK_PERIOD; -- Bit 1 & Exit1-IR 
        TMS <= '1'; wait for TCK_PERIOD; -- Update-IR 

        -- Bypass Path Verification (TDI -> TDO)
        TMS <= '0'; wait for TCK_PERIOD; -- Idle 
        TMS <= '1'; wait for TCK_PERIOD; -- Select-DR-Scan
        TMS <= '0'; wait for TCK_PERIOD; -- Capture-DR 
        TMS <= '0'; wait for TCK_PERIOD; -- Shift-DR 
        TDI <= '1'; wait for TCK_PERIOD; -- This '1' should be seen in the TDO after 1 cycle 
        TDI <= '0'; wait for TCK_PERIOD; -- 
        TMS <= '1'; wait for TCK_PERIOD; -- Exit1-DR 

        wait for 500 ns;
        assert false report "Simulation Finished" severity failure; 
    end process;

end Behavioral;
