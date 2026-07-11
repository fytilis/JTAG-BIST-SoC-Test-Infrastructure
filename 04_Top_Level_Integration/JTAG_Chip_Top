library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity JTAG_Chip_Top is
    Port ( 
        -- Normal Chip I/O Pins (Interface with the outside world)
        a_pin : in  STD_LOGIC;
        b_pin : in  STD_LOGIC;
        c_pin : in  STD_LOGIC;
        d_pin : in  STD_LOGIC;
        i_pin : out STD_LOGIC;
        j_pin : out STD_LOGIC;
        
        -- JTAG Pins (The Test Access Port)
        TDI   : in  STD_LOGIC;
        TCK   : in  STD_LOGIC;
        TMS   : in  STD_LOGIC;
        TRST  : in  STD_LOGIC;
        TDO   : out STD_LOGIC;
        state_name_top : out STRING(1 to 16);
        debug_mode     : out STD_LOGIC;
        debug_ir       : out STD_LOGIC_VECTOR(1 downto 0);
        debug_upd_i    : out STD_LOGIC 
    );
end JTAG_Chip_Top;

architecture Structural of JTAG_Chip_Top is
    -- SIGNALS
    -- 1. Signals from the TAP Controller
    signal tap_state : STD_LOGIC_VECTOR(3 downto 0);
    
    -- JTAG Control Signals (Produced by tap_state)
    signal ShiftDR, ClockDR, UpdateDR, CaptureDR : STD_LOGIC;
    signal ShiftIR, ClockIR, UpdateIR : STD_LOGIC;
    signal Select_MUX2 : STD_LOGIC; 

    -- 2. Signals to/from the Registers
    -- Initialize the IR to be non-red (Undefined)
    signal ir_parallel_out : STD_LOGIC_VECTOR(1 downto 0) := "01"; 
    signal ir_serial_out   : STD_LOGIC;   
    -- 1. CHANGE: New signal for the connection of the two IR cells
	 signal ir_s_link : STD_LOGIC; 	
    signal br_serial_out   : STD_LOGIC;                    
    signal bsr_serial_out  : STD_LOGIC;                    

    -- 3. Signals from Decoder
    -- Initialization of control signals
    signal Mode : STD_LOGIC := '0';
    signal Sel_MUX1 : STD_LOGIC := '0';

    -- 4. BSR (Boundary Scan Register) Chain Signals
    signal s1, s2, s3, s4, s5 : STD_LOGIC; 
    
    -- 5. Signals between BSR and CUT
    signal cut_a, cut_b, cut_c, cut_d : STD_LOGIC;
    signal cut_i, cut_j : STD_LOGIC;

    -- 6. Intermediate Multiplex Signals
    signal mux1_out : STD_LOGIC;
    signal mux2_out : STD_LOGIC;
    signal tdo_ff_out: STD_LOGIC;

begin
    -- 1. TAP Controller
    U_TAP: entity work.tap_controller port map (
        TCK => TCK, TMS => TMS, TRST => TRST, 
        state_bin => tap_state,
        state_name => state_name_top
    );

    -- Generate Control Signals based on TAP status
    process(tap_state, TCK)
    begin
        ShiftDR <= '0'; ClockDR <= '0'; UpdateDR <= '0'; CaptureDR <= '0';
        ShiftIR <= '0'; ClockIR <= '0'; UpdateIR <= '0'; Select_MUX2 <= '0';

        case tap_state is
            when "0011" => CaptureDR <= '1'; ClockDR <= TCK; 
            when "0100" => ShiftDR   <= '1'; ClockDR <= TCK; 
            when "1000" => UpdateDR  <= TCK; 
            when "1010" => ClockIR   <= TCK; Select_MUX2 <= '1';                   
            when "1011" => ShiftIR   <= '1'; ClockIR <= TCK; Select_MUX2 <= '1';   
            when "1111" => UpdateIR  <= TCK; Select_MUX2 <= '1';                  
            when others => null;
        end case;
    end process;
		-- 2. Instruction Register (IR) - Correct Chain Connection
		-- IR_1 (MSB) starts with '0' (default)
		U_IR_1: entity work. IR 
			 generic map (INIT_VAL => '0') 
			 port map (
				  Data => '0', TDI => TDI, ShiftIR => ShiftIR, 
				  ClockIR => ClockIR, UpdateIR => UpdateIR,
				  ParallelOut => ir_parallel_out(1), TDO => ir_s_link
			 );

		-- IR_0 (LSB) starts with '1'
		U_IR_0: entity work. IR 
			 generic map (INIT_VAL => '1') 
			 port map (
				  Data => '1', TDI => ir_s_link, ShiftIR => ShiftIR, 
				  ClockIR => ClockIR, UpdateIR => UpdateIR,
				  ParallelOut => ir_parallel_out(0), TDO => ir_serial_out
			 );
    -- 3. Bypass Register (BR)
    U_BR: entity work.BR port map (
        TDI => TDI, CaptureDR => CaptureDR, ClockDR => ClockDR, 
        TDO_BR => br_serial_out
    );

    -- 4. Boundary Scan Register (BSR)
    BSC_A: entity work.bsc port map (DataIn => a_pin, ShiftIn => TDI, ShiftDR => ShiftDR, ClockDR => ClockDR, UpdateDR => UpdateDR, Mode => Mode, DataOut => cut_a, ShiftOut => s1);
    BSC_B: entity work.bsc port map (DataIn => b_pin, ShiftIn => s1,  ShiftDR => ShiftDR, ClockDR => ClockDR, UpdateDR => UpdateDR, Mode => Mode, DataOut => cut_b, ShiftOut => s2);
    BSC_C: entity work.bsc port map (DataIn => c_pin, ShiftIn => s2,  ShiftDR => ShiftDR, ClockDR => ClockDR, UpdateDR => UpdateDR, Mode => Mode, DataOut => cut_c, ShiftOut => s3);
    BSC_D: entity work.bsc port map (DataIn => d_pin, ShiftIn => s3,  ShiftDR => ShiftDR, ClockDR => ClockDR, UpdateDR => UpdateDR, Mode => Mode, DataOut => cut_d, ShiftOut => s4);
    
    -- 5. CUT (Circuit Under Test)
    U_CUT: entity work. CUT port map (
        a => cut_a, b => cut_b, c => cut_c, d => cut_d, 
        i => cut_i, j => cut_j
    );

    -- 6. BSR Continuation and Debug Upd Connection
    BSC_I: entity work.bsc port map (
        DataIn => cut_i, ShiftIn => s4, ShiftDR => ShiftDR, ClockDR => ClockDR, 
        UpdateDR => UpdateDR, Mode => Mode, DataOut => i_pin, ShiftOut => s5,
        debug_upd => debug_upd_i
    );
    
    BSC_J: entity work.bsc port map (
        DataIn => cut_j, ShiftIn => s5, ShiftDR => ShiftDR, ClockDR => ClockDR, 
        UpdateDR => UpdateDR, Mode => Mode, DataOut => j_pin, ShiftOut => bsr_serial_out
    );

    -- 7. Decoder Logic
    process(ir_parallel_out)
    begin
        case ir_parallel_out is
            when "00" => Mode <= '1'; Sel_MUX1 <= '0'; -- EXTEST
            when "01" => Mode <= '0'; Sel_MUX1 <= '0'; -- SAMPLE/PRELOAD
            when "10" => Mode <= '1'; Sel_MUX1 <= '0'; -- INTEST
            when "11" => Mode <= '0'; Sel_MUX1 <= '1'; -- BYPASS
            when others => Mode <= '0'; Sel_MUX1 <= '1';
        end case;
    end process;

    -- 8. MUX-1 & MUX-2 Multiplexers
    mux1_out <= br_serial_out when Sel_MUX1 = '1' else bsr_serial_out;
    mux2_out <= ir_serial_out when Select_MUX2 = '1' else mux1_out;

    -- 9. Final Flip-Flop TDO
    process(TCK)
    begin
        if falling_edge(TCK) then
            tdo_ff_out <= mux2_out;
        end if;
    end process;

    TDO <= tdo_ff_out when (ShiftDR = '1' or ShiftIR = '1') else 'Z';
    debug_mode <= Mode; 
    debug_ir   <= ir_parallel_out;

end Structural;
