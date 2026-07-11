library ieee;
use ieee.std_logic_1164.all;

entity MyDFF is
    port (
        CLK : in std_logic;
        D   : in std_logic;
        Q   : out std_logic
    );
end entity;

architecture rtl of MyDFF is
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            Q <= D;
        end if;
    end process;
end architecture;
