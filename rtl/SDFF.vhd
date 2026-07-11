library ieee;
use ieee.std_logic_1164.all;
entity SDFF is
    port (
        CLK : in std_logic;
        DI  : in std_logic; -- Data Input from CUT
        SI  : in std_logic; -- Scan input from the previous FF
        SE  : in std_logic; -- Scan Enable (1 for shift, 0 for capture)
        SO : out std_logic -- Exit (Q)
    );
end entity;

architecture rtl of SDFF is
    signal mux_out : std_logic;
begin
    -- Entry option based on SE 
    mux_out <= SI when SE = '1' else DI;

    -- Interface with MyDFF
    DFF_inst: entity work. MyDFF
        port map (
            CLK => CLK,
            D   => mux_out,
            Q   => SO
        );
end architecture;
