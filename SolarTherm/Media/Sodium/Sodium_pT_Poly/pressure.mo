within SolarTherm.Media.Sodium.Sodium_pT_Poly;

function extends pressure "Return pressure"
	algorithm
		p := state.p;
		annotation (Inline=true);
	end pressure;