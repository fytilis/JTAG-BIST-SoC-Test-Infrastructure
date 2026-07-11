library ieee;
use ieee.std_logic_1164.all;
entity TRCUTwithMISR is
    port (
        CLK  : in  std_logic;
        SE   : in  std_logic;
        sign : out std_logic -- The only signature output 
    );
end entity;
architecture struct of TRCUTwithMISR is
    signal lfsr_to_cut : std_logic; 
    signal cut_to_misr : std_logic; 
    signal misr_q      : std_logic_vector(15 downto 0);
begin
	-- 1. Connecting LFSR8 (Pattern Generator)
    -- Attention: The name formal port must be 'Output' 
    -- to match the code you sent.
    PG_inst: entity work. LFSR8
        port map (
            CLK    => CLK,
            Output => lfsr_to_cut -- SI Connection 
        );-- 2. Connecting TRCUT (Circuit Under Test)
    CUT_inst: entity work. TRCUT
        port map (
            CLK => CLK,
            SE  => SE,
            SI  => lfsr_to_cut,   
            SO => cut_to_misr -- SO Connection 
        );

    -- 3. Connecting the MISR16 (Signature Analyzer) 
    SA_inst: entity work. MISR16
        port map (
            CLK        => CLK,
            Input_Data => cut_to_misr,
            q          => misr_q
        );
    -- Output sign: Selecting the MISR bit 15 
    sign <= misr_q(15);
end architecture;
