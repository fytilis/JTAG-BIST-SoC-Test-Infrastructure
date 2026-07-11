library ieee;
use ieee.std_logic_1164.all;

entity CUT is
    port (
        a, b, c, d : in std_logic;
        i, j       : out std_logic
    );
end entity;

architecture rtl of CUT is
    signal e, f, g, h : std_logic;
begin
    -- Logic based on the scheme of Exercise 1 
    e <= a xor b;
    f <= c xor d;
    g <= a xor c;
    h <= b xor d;
    
    i <= e and f; -- Intended for RBI
    j <= g or h;  -- Reserved for Raj
end architecture;
