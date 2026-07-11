library IEEE;
use IEEE. STD_LOGIC_1164.ALL;

entity tb_tap_controller is
end tb_tap_controller;

architecture behavior of tb_tap_controller is
    component tap_controller
        Port (
            TCK        : in  STD_LOGIC;
            TMS        : in  STD_LOGIC;
            TRST       : in  STD_LOGIC;
            state_bin  : out STD_LOGIC_VECTOR(3 downto 0);
            state_name : out STRING(1 to 16)
        );
    end component;

    signal TCK_sig : STD_LOGIC := '0';
    signal TMS_sig : STD_LOGIC := '1'; -- We start with 1 for the Reset
    signal TRST_sig : STD_LOGIC := '0';
    signal state_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal state_name_sig : STRING(1 to 16);

    constant TCK_period : time := 10 ns;

begin
    uut: tap_controller Port Map (TCK_sig, TMS_sig, TRST_sig, state_sig, state_name_sig);

    -- Clock Generation
    TCK_process : process
    begin
        TCK_sig <= '0'; wait for TCK_period/2;
        TCK_sig <= '1'; wait for TCK_period/2;
    end process;

    stim_proc: process
    begin		
        -- 1. Initialization & Reset Loop
        TRST_sig <= '1'; wait for 15 ns; TRST_sig <= '0';
        wait until falling_edge(TCK_sig);
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- Stay in Test-Logic-Reset
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- To Run-Test/Idle
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- Stay in Run-Test/Idle

        -- 2. Full Data Register Path (DR Path) with Loops
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Select-DR-Scan
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- To Capture-DR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- To Shift-DR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- Stay in Shift-DR (Loop)
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Exit1-DR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- To Pause-DR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- Stay in Pause-DR (Loop)
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Exit2-DR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- Back to Shift-DR
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Exit1-DR
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Update-DR
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Select-DR-Scan (Loopback)
        
        -- 3. Full Instruction Register (IR Path) with Loops
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Select-IR-Scan
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- To Capture-IR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- To Shift-IR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- Stay in Shift-IR (Loop)
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Exit1-IR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- To Pause-IR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- Stay in Pause-IR (Loop)
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Exit2-IR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- Back to Shift-IR
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Exit1-IR
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Update-IR
        TMS_sig <= '0'; wait until falling_edge(TCK_sig); -- Back to Run-Test/Idle

        -- 4. Emergency Reset Control (5 consecutive '1')
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Select-DR
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Select-IR
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- To Test-Logic-Reset (Path 1)
        TMS_sig <= '1'; wait until falling_edge(TCK_sig); -- Stay Reset (Path 2)
        
        report "Full FSM Path Coverage Finished!" severity note;
        assert false report "End" severity failure;
    end process;
end behavior;
