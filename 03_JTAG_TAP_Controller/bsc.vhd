library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity bsc is
    Port (
        DataIn      : in  STD_LOGIC; -- From Pin or Internal Logic
        ShiftIn     : in  STD_LOGIC; -- From previous BSC or TDI
        ShiftDR     : in  STD_LOGIC; -- Select Source (0: DataIn, 1: ShiftIn)
        ClockDR     : in  STD_LOGIC; -- Clock for Capture FF
        UpdateDR    : in  STD_LOGIC; -- Clock for Update FF
        Mode        : in  STD_LOGIC; -- Mode Selection (0: Normal, 1: Test)
        DataOut     : out STD_LOGIC; -- To Internal Logic or Pin
        ShiftOut : out STD_LOGIC -- To Next BSC or TDO
    );
end bsc;

architecture Behavioral of bsc is
    signal cap_ff : STD_LOGIC := '0';
    signal upd_ff : STD_LOGIC := '0';
    signal mux_input : STD_LOGIC;
begin
    -- Input multiplexer
    mux_input <= ShiftIn when ShiftDR = '1' else DataIn;

    -- Capture Flip-Flop (CAP)
    process(ClockDR) begin
        if rising_edge(ClockDR) then
            cap_ff <= mux_input;
        end if;
    end process;

    -- Update Flip-Flop (UPD)
    process(UpdateDR) begin
        if rising_edge(UpdateDR) then
            upd_ff <= cap_ff;
        end if;
    end process;

    -- Output Multiplexer (Mode Control)
    DataOut <= upd_ff when Mode = '1' else DataIn;
    
    -- ShiftOut output is always the output of CAP FF
    ShiftOut <= cap_ff;
end Behavioral;
