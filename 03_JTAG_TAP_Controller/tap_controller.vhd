library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity tap_controller is
    Port (
        TCK        : in  STD_LOGIC;
        TMS        : in  STD_LOGIC;
        TRST       : in  STD_LOGIC;
        state_bin  : out STD_LOGIC_VECTOR(3 downto 0); -- Binary output (state) 
        state_name : out STRING(1 to 16) -- ASCII output for debugging 
    );
end tap_controller;

architecture Behavioral of tap_controller is
    -- Definition of 16 states 
    type state_type is (
        Test_Logic_Reset, Run_Test_Idle, 
        Select_DR_Scan, Capture_DR, Shift_DR, Exit1_DR, Pause_DR, Exit2_DR, Update_DR,
        Select_IR_Scan, Capture_IR, Shift_IR, Exit1_IR, Pause_IR, Exit2_IR, Update_IR
    );
    signal current_s, next_s : state_type;
begin
    -- Modern transition of situations 
    process(TCK, TRST)
    begin
        if TRST = '1' then
            current_s <= Test_Logic_Reset; -- Asynchronous Reset 
        elsif rising_edge(TCK) then
            current_s <= next_s;
        end if;
    end process;

    -- TMS-based next-state logic 
    process(current_s, TMS)
    begin
        case current_s is
            when Test_Logic_Reset => if TMS = '0' then next_s <= Run_Test_Idle; else next_s <= Test_Logic_Reset; end if;
            when Run_Test_Idle    => if TMS = '1' then next_s <= Select_DR_Scan; else next_s <= Run_Test_Idle; end if;
            
            -- Data Register Path (DR)
            when Select_DR_Scan   => if TMS = '0' then next_s <= Capture_DR; else next_s <= Select_IR_Scan; end if;
            when Capture_DR       => if TMS = '0' then next_s <= Shift_DR; else next_s <= Exit1_DR; end if;
            when Shift_DR         => if TMS = '0' then next_s <= Shift_DR; else next_s <= Exit1_DR; end if;
            when Exit1_DR         => if TMS = '0' then next_s <= Pause_DR; else next_s <= Update_DR; end if;
            when Pause_DR         => if TMS = '0' then next_s <= Pause_DR; else next_s <= Exit2_DR; end if;
            when Exit2_DR         => if TMS = '0' then next_s <= Shift_DR; else next_s <= Update_DR; end if;
            when Update_DR        => if TMS = '0' then next_s <= Run_Test_Idle; else next_s <= Select_DR_Scan; end if;

            -- Instruction Register (IR) Path
            when Select_IR_Scan   => if TMS = '0' then next_s <= Capture_IR; else next_s <= Test_Logic_Reset; end if;
            when Capture_IR       => if TMS = '0' then next_s <= Shift_IR; else next_s <= Exit1_IR; end if;
            when Shift_IR         => if TMS = '0' then next_s <= Shift_IR; else next_s <= Exit1_IR; end if;
            when Exit1_IR         => if TMS = '0' then next_s <= Pause_IR; else next_s <= Update_IR; end if;
            when Pause_IR         => if TMS = '0' then next_s <= Pause_IR; else next_s <= Exit2_IR; end if;
            when Exit2_IR         => if TMS = '0' then next_s <= Shift_IR; else next_s <= Update_IR; end if;
            when Update_IR        => if TMS = '0' then next_s <= Run_Test_Idle; else next_s <= Select_DR_Scan; end if;

            when others           => next_s <= Test_Logic_Reset;
        end case;
    end process;

    -- Convert state to Binary and ASCII (String) 
    process(current_s)
    begin
        case current_s is
            when Test_Logic_Reset => state_bin <= "0000"; state_name <= "Test-Logic-Reset";
            when Run_Test_Idle    => state_bin <= "0001"; state_name <= "Run-Test/Idle   ";
            when Select_DR_Scan   => state_bin <= "0010"; state_name <= "Select-DR-Scan  ";
            when Capture_DR       => state_bin <= "0011"; state_name <= "Capture-DR      ";
            when Shift_DR         => state_bin <= "0100"; state_name <= "Shift-DR        ";
            when Exit1_DR         => state_bin <= "0101"; state_name <= "Exit1-DR        ";
            when Pause_DR         => state_bin <= "0110"; state_name <= "Pause-DR        ";
            when Exit2_DR         => state_bin <= "0111"; state_name <= "Exit2-DR        ";
            when Update_DR        => state_bin <= "1000"; state_name <= "Update-DR       ";
            when Select_IR_Scan   => state_bin <= "1001"; state_name <= "Select-IR-Scan  ";
            when Capture_IR       => state_bin <= "1010"; state_name <= "Capture-IR      ";
            when Shift_IR         => state_bin <= "1011"; state_name <= "Shift-IR        ";
            when Exit1_IR         => state_bin <= "1100"; state_name <= "Exit1-IR        ";
            when Pause_IR         => state_bin <= "1101"; state_name <= "Pause-IR        ";
            when Exit2_IR         => state_bin <= "1110"; state_name <= "Exit2-IR        ";
            when Update_IR        => state_bin <= "1111"; state_name <= "Update-IR       ";
        end case;
    end process;
end Behavioral;
