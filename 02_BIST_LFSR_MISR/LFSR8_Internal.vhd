library ieee;
use ieee.std_logic_1164.all;

entity LFSR8_Internal is
    port (
        CLK    : in  std_logic;
        Output : out std_logic
    );
end entity;

architecture rtl of LFSR8_Internal is
    -- Non-zero seed initialization (all '1') 
    signal q : std_logic_vector(7 downto 0) := (others => '1');
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Bit 0 always accepts feedback from bit 7
            q(0) <= q(7);
            -- Bits without XOR (single shift)
            q(1) <= q(0);
            q(5) <= q(4);
            q(6) <= q(5);
            q(7) <= q(6);
            
            -- Bits with XOR in between (Taps based on polynomial)
            -- q(i)_next = q(i-1) XOR feedback(q7)
            q(2) <= q(1) xor q(7); -- Tap on x^2
            q(3) <= q(2) xor q(7); -- Tap on x^3
            q(4) <= q(3) xor q(7); -- Tap on x^4
        end if;
    end process;
    -- The output that will go to TRCUT's SI
    Output <= q(7);
end architecture;
