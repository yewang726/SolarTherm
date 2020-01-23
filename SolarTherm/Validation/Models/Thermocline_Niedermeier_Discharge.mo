within SolarTherm.Validation.Models;

model Thermocline_Niedermeier_Discharge
  import SI = Modelica.SIunits;
  import CN = Modelica.Constants;
  import CV = Modelica.SIunits.Conversions;
  import Tables = Modelica.Blocks.Tables;

  package Sodium = SolarTherm.Media.Materials.Sodium;
  package MS = SolarTherm.Media.Materials.SolarSalt_Constant;
  package CaO = SolarTherm.Media.Materials.CaO;
  package Quartzite = SolarTherm.Media.Materials.Quartzite_Sand;

  parameter Integer N_f = 200;
  parameter Integer N_p = 5;
  parameter SI.Length H_tank = 6.1;
  parameter SI.Diameter D_tank = 3.0;
  parameter SI.Length z_f[N_f] = SolarTherm.Models.Storage.Thermocline.Z_position(H_tank,N_f);
  parameter SI.Temperature T_f_start[N_f] = SolarTherm.Validation.Datasets.Niedermeier_Discharge_Dataset.Initial_Temperature_f(z_f);
  parameter SI.Temperature h_f_start[N_f] = SolarTherm.Validation.Datasets.Niedermeier_Discharge_Dataset.Initial_Enthalpy_f(z_f);
  parameter SI.Temperature T_p_start[N_f,N_p] = SolarTherm.Validation.Datasets.Niedermeier_Discharge_Dataset.Initial_Temperature_p(z_f,N_p);
  parameter SI.Temperature h_p_start[N_f,N_p] = SolarTherm.Validation.Datasets.Niedermeier_Discharge_Dataset.Initial_Enthalpy_p(z_f,N_p);

  //Thermocline Tank A (Bottom PCM)
  SolarTherm.Models.Storage.Thermocline.Thermocline_Section Tank_A (redeclare package Fluid = MS, redeclare package Filler = Quartzite, N_f = N_f, N_p = N_p,T_f_start=T_f_start,T_p_start=T_p_start,h_f_start=h_f_start,h_p_start=h_p_start,T_max=396.0+273.15,T_min=290.0+273.15,d_p=15.0e-3,H_tank=H_tank,D_tank=D_tank,Correlation=1) "The bottom tank";
  
  //All tank sections have HTF type in common!
  MS Fluid "Fluid package";
  MS.State fluid_top(h_start=h_f_min) "Top fluid property object";
  MS.State fluid_bot(h_start=h_f_min) "Bottom fluid property object";
  
  //Property bounds
  //Fluid
  parameter SI.SpecificEnthalpy h_f_min=Fluid.h_Tf(T_min) "Starting enthalpy of the HTF";
  parameter SI.SpecificEnthalpy h_f_max=Fluid.h_Tf(T_max) "Starting enthalpy of the HTF";
  parameter SI.Density rho_f_min=Fluid.rho_Tf(T_min);
  parameter SI.Density rho_f_max=Fluid.rho_Tf(T_max);
  parameter SI.Density rho_f_avg=(rho_f_min+rho_f_max)/2;
  //Design parameters
  parameter SI.Energy E_max = 144e9 "Maximum theoretical storage capacity of combined tanks";
  parameter SI.Time t_charge = 4 * 3600 "charging time";
  parameter SI.Time t_discharge = 4 * 3600 "discharging time";

  parameter SI.Temperature T_min = CV.from_degC(290.0) "Design cold Temperature of everything in the tank (K)";
  parameter SI.Temperature T_max = CV.from_degC(396.0) "Design hot Temperature of everything in the tank (K)";
 
  //Inlet and Outlet
  SI.SpecificEnthalpy h_top "J/kg";
  SI.SpecificEnthalpy h_bot "J/kg";
  SI.MassFlowRate m_flow "kg/s";
  
  //Boundary Conditions
  SI.Temperature T_top (start=T_min) "Temperature at the top";
  SI.Temperature T_bot (start=T_min) "Temperature at the bottom";

equation
  //Connections
  m_flow = Tank_A.m_flow;
  h_bot = Tank_A.h_bot;
  h_top = Tank_A.h_top;

  m_flow = 7.0;
  T_bot = 290.0+273.15;
  
  //Fluid inlet and outlet properties
  fluid_top.h = h_top;
  fluid_bot.h = h_bot;
  fluid_top.T = T_top;
  fluid_bot.T = T_bot;
  
annotation(experiment(StopTime = 9000, StartTime = 0, Tolerance = 1e-6, Interval = 180.0));

end Thermocline_Niedermeier_Discharge;