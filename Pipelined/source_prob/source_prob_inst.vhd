	component source_prob is
		port (
			probe : in std_logic_vector(31 downto 0) := (others => 'X')  -- probe
		);
	end component source_prob;

	u0 : component source_prob
		port map (
			probe => CONNECTED_TO_probe  -- probes.probe
		);

