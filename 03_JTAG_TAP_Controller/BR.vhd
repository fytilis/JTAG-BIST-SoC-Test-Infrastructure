library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity BR is
    Port (
        TDI       : in  STD_LOGIC;
        CaptureDR : in  STD_LOGIC;
        ClockDR   : in  STD_LOGIC;
        TDO_BR    : out STD_LOGIC
    );
end BR;

architecture Behavioral of BR is
    signal D_input : STD_LOGIC;
    signal Q_state : STD_LOGIC := '0';
begin
    -- AND Gateway 
    D_input <= TDI and CaptureDR;

    -- Flip-Flop 
    process(ClockDR)
    begin
        if rising_edge(ClockDR) then
            Q_state <= D_input;
        end if;
    end process;
