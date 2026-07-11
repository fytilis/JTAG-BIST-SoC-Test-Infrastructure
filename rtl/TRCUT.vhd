library ieee;
use ieee.std_logic_1164.all;

entity TRCUT is
    port (
        CLK : in std_logic;
        SI  : in std_logic;--Select Input
        SE  : in std_logic;--Select Enable
        SO  : out std_logic--Select Output
    );
end entity;


architecture rtl of TRCUT is
    signal q_a, q_b, q_c, q_d : std_logic:= '0';
    signal cut_i, cut_j : std_logic:= '0';
begin
    -- 1. The combined section 
    Combinational_Logic: entity work. CUT
        port map (
            a => q_a, b => q_b, c => q_c, d => q_d,
            i => cut_i, j => cut_j
        );

    -- 2. The Scan Chain: SI -> Raj -> Rbi -> Rc -> Rd -> SO 
    Raj_inst: entity work. SDFF
        port map (CLK => CLK, SE => SE, SI => SI,   DI => cut_j, SO => q_a); -- Input from SI 

    Rbi_inst: entity work. SDFF
        port map (CLK => CLK, SE => SE, SI => q_a,  DI => cut_i, SO => q_b); -- Entrance from q_a 

    Rc_inst: entity work. SDFF
        port map (CLK => CLK, SE => SE, SI => q_b,  DI => '0',   SO => q_c); -- Entrance from q_b 

    Rd_inst: entity work. SDFF
        port map (CLK => CLK, SE => SE, SI => q_c,  DI => '0',   SO => q_d); -- Login from q_c 

    -- The final SO output is now connected to the last FF of the chain (Rd) 
    SO <= q_d; 
end architecture;
