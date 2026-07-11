library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity CUT is
    Port ( 
        a : in  STD_LOGIC;
        b : in  STD_LOGIC;	
        c : in  STD_LOGIC;
        d : in  STD_LOGIC;
        i : out STD_LOGIC;
        j : out STD_LOGIC
    );
end CUT;
architecture Dataflow of CUT is
    -- Internal signals for the outputs of XOR gates
    signal e, f, g, h : STD_LOGIC;
begin
    -- 1st Level: Four XOR Gates
    e <= a xor b; -- The gate leading to the e signal
    f <= c xor d; -- The gate leading to the f-signal
    g <= b xor c; -- The gate leading to the g signal
    h <= a xor d; -- The gate leading to the h signal
    -- 2nd Level: Output Gates
    i <= e and f; -- AND gate giving output i
    j <= g or  h; -- OR gate giving j output
end Dataflow;
