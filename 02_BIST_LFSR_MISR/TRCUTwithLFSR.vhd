library ieee;
use ieee.std_logic_1164.all;

entity TRCUTwithLFSR is
    port (
        SE  : in  std_logic; -- Scan Enable
        CLK : in  std_logic; -- Clock 
        SO  : out std_logic  -- Scan Out
    );
end entity;

architecture struct of TRCUTwithLFSR is
    signal lfsr_to_si : std_logic; -- LFSR -> TRCUT Connection Signal
begin
    -- 1. LFSR instance (8th degree) 
    LFSR_inst: entity work. LFSR8_Internal
        port map (
            CLK    => CLK,
            Output => lfsr_to_si
        );

    -- 2. Instance of TRCUT (from Exercise 1)
    TRCUT_inst: entity work. TRCUT
        port map (
            CLK => CLK, -- Common clock (synchronous circuit)
            SI => lfsr_to_si, -- Scan input comes from LFSR
            SE  => SE,
            SO  => SO
        );
end architecture;
