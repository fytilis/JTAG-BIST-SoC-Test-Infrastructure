library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity IR is
    Port (
        Data        : in  STD_LOGIC;
        TDI         : in  STD_LOGIC;
        ShiftIR     : in  STD_LOGIC;
        ClockIR     : in  STD_LOGIC; -- CaptureIR
        UpdateIR    : in  STD_LOGIC;
        ParallelOut : out STD_LOGIC;
        TDO         : out STD_LOGIC
    );
end IR;

architecture Behavioral of IR is
    signal SRFFQ     : STD_LOGIC := '0';
    signal LFFQ      : STD_LOGIC := '0';
    signal DfromMux  : STD_LOGIC;
begin
    -- Implementation of the Multiplex (Mux) 
    DfromMux <= TDI when ShiftIR = '1' else Data;

    -- Implementation of Shift Register Flip-Flop (SRFF) 
    process(ClockIR)
    begin
        if rising_edge(ClockIR) then
            SRFFQ <= DfromMux;
        end if;
    end process;

    -- Implementation of Latch Flip-Flop (LFF)
    process(UpdateIR)
    begin
        if rising_edge(UpdateIR) then
            LFFQ <= SRFFQ;
        end if;
    end process;

    TDO <= SRFFQ;
    ParallelOut <= LFFQ;
end Behavioral;
