library ieee;
use ieee.std_logic_1164.all;
entity MISR16 is
    port (
        CLK        : in  std_logic;
        Input_Data : in  std_logic; -- The SO signal from TRCUT
        q          : out std_logic_vector(15 downto 0)
    );
end entity;
architecture RTL of MISR16 is
    -- Non-zero seed initialization 
    signal MISR_reg : std_logic_vector(15 downto 0) := "1011010001101001"; 
begin
    process(CLK)
        variable feedback : std_logic;
    begin
        if rising_edge(CLK) then
            feedback := MISR_reg(15);
            -- Galois MISR implementation based on the polynomial of LFSR16_1B401
            -- Add XOR tap for SO input to bit 0 
            MISR_reg(0)  <= feedback xor Input_Data; 
            MISR_reg(1)  <= MISR_reg(0);
            MISR_reg(2)  <= MISR_reg(1);
            MISR_reg(3)  <= MISR_reg(2);
            MISR_reg(4)  <= MISR_reg(3);
            MISR_reg(5)  <= MISR_reg(4);
            MISR_reg(6)  <= MISR_reg(5);
            MISR_reg(7)  <= MISR_reg(6);
            MISR_reg(8)  <= MISR_reg(7);
            MISR_reg(9)  <= MISR_reg(8);
            MISR_reg(10) <= MISR_reg(9)  xor feedback;
            MISR_reg(11) <= MISR_reg(10);
            MISR_reg(12) <= MISR_reg(11) xor feedback;
            MISR_reg(13) <= MISR_reg(12) xor feedback;
            MISR_reg(14) <= MISR_reg(13);
            MISR_reg(15) <= MISR_reg(14) xor feedback;
        end if;
    end process;
    q <= MISR_reg;
end architecture;
