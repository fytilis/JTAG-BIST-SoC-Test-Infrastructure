library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TRCUT_tb is
end entity;

architecture behavior of TRCUT_tb is
    -- Interface signals
    signal CLK_tb : std_logic := '0';
    signal SE_tb  : std_logic := '0';
    signal SI_tb  : std_logic := '0';
    signal SO_tb  : std_logic;

    -- Verification and visualization signals
    signal expected_i : std_logic := '0';
    signal expected_j : std_logic := '0';
    signal match      : std_logic := '1';
    signal abcd_vector : std_logic_vector(3 downto 0) := "0000";--Here the vector name change was made
	 
	 signal Q_aj : std_logic;
    signal Q_bi : std_logic;
    signal Q_c  : std_logic;
    signal Q_d  : std_logic;

    constant CLK_PERIOD : time := 100 ns; -- Frequency 10MHz

begin
    -- Unit Under Test
    UUT: entity work. TRCUT
        port map (
            CLK => CLK_tb,
            SE  => SE_tb,
            SI  => SI_tb,
            SO  => SO_tb
        );

    -- Clock Generation
    CLK_tb <= not CLK_tb after CLK_PERIOD/2;
	 Q_aj <= <<signal UUT.q_a : std_logic>>;
	 Q_bi <= <<signal UUT.q_b : std_logic>>;
	 Q_c  <= <<signal UUT.q_c : std_logic>>;
	 Q_d  <= <<signal UUT.q_d : std_logic>>;

    stim_proc: process
        variable vec : std_logic_vector(3 downto 0);
		  --Here we added the next_vec in order to be able to load the next vector we want to Shift-In into it
		  variable next_vec: std_logic_vector(3 downto 0);
        variable exp_i, exp_j : std_logic;
    begin
        -- INITIAL CLEANUP (Flush): 4 cycles to remove the 'U' (Undefined)
        SE_tb <= '1';
        vec := "0000";
        for k in 3 downto 0 loop
					SI_tb <= vec(k);
				wait until rising_edge(CLK_tb);
        end loop;

        -- MAIN CHECK: 16 Truth Table Vectors (0000 to 1111)
        for val in 0 to 15 loop
				vec := std_logic_vector(to_unsigned(val, 4));
            abcd_vector <= vec;
            SE_tb <= '0';
				wait until rising_edge(CLK_tb);
            -- Theoretical calculation based on CUT equations
            -- a=vec(3), b=vec(2), c=vec(1), d=vec(0)
            exp_i := (vec(3) xor vec(2)) and (vec(1) xor vec(0)); -- i = (a xor b) and (c xor d)
            exp_j := (vec(3) xor vec(1)) or (vec(2) xor vec(0));  -- j = (a xor c) or (b xor d)
            expected_i <= exp_i;
            expected_j <= exp_j;
				
				-- PARALLEL SHIFTING PHASE: Shift-Out (val) and Shift-In (val + 1)
            SE_tb <= '1';
				-- Here next_vec gets val + 1
				next_vec := std_logic_vector(to_unsigned((val + 1) mod 16, 4));
            for k in 0 to 3 loop
				-- Shift-In: We insert the next vector
					SI_tb <= next_vec(k);
                -- Shift-Out & Verification: We check the output of the current vector
                wait for 1 ns; -- Waiting for stabilization of SO output
                if (k = 2) then -- The 3rd bit that outputs is Raj (output j)
                    if (SO_tb = exp_j) then match <= '1'; else match <= '0'; end if;
                elsif (k = 3) then -- The 4th bit that comes out is Rbi (output i)
                    if (SO_tb = exp_i) then match <= '1'; else match <= '0'; end if;
                else
                    match <= '1'; -- Remaining bits are blank (0) due to capture
                end if;
                
                wait until rising_edge(CLK_tb);
            end loop;
        end loop;

        -- TERMINATION
        assert false report "Exhaustive Test Completed Successfully!" severity failure;
        wait;
    end process;
end architecture;
