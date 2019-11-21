within SolarTherm.Models.Fluid.HeatExchangers;
function TempCorrFactor
  import SI = Modelica.SIunits;
  import CN = Modelica.Constants;
  import MA = Modelica.Math;
  import SolarTherm.{Models,Media};

  input SI.Temperature T_Na1(start=740+273.15) "Sodium Hot Fluid Temperature";
  input SI.Temperature T_Na2(start=700+273.15) "Sodium Cold Fluid Temperature";
  input SI.Temperature T_MS1(start=500+273.15) "Molten Salts Cold Fluid Temperature";
  input SI.Temperature T_MS2(start=720+273.15) "Molten Salts Hot Fluid Temperature";
  
  output Real F(unit= "") "Temperature correction factor";
  
protected
  Real S(unit = "") "Non-dimensional factor for F calculation";
  Real R(unit = "") "Non-dimensional factor for F calculation";
  Real AA(unit = "") "Non-dimensional factor for F calculation";
  Real BB(unit = "") "Non-dimensional factor for F calculation";
  
algorithm
  S := (T_Na2 - T_Na1) / (T_MS1 - T_Na1);
  R := (T_MS1 - T_MS2) / (T_Na2 - T_Na1);
  AA := 2 / S - R - 1;
  BB := 2 / S * ((1 - S) * (1 - S * R)) ^ 0.5; 
  F := (R ^ 2 + 1) ^ 0.5 / (2 * (R + 1)) * log((1 - S) / (1 - S * R)) / log((AA + BB + (R ^ 2 + 1) ^ 0.5) / (AA + BB - (R ^ 2 + 1) ^ 0.5));

end TempCorrFactor;
