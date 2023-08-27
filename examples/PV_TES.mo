model PV_TES
  import SolarTherm.{Models,Media};
  import Modelica.SIunits.Conversions.from_degC;
  import SI = Modelica.SIunits;
  import nSI = Modelica.SIunits.Conversions.NonSIunits;
  import CN = Modelica.Constants;
  import CV = Modelica.SIunits.Conversions;
  import FI = SolarTherm.Models.Analysis.Finances;
  import SolarTherm.Types.Solar_angles;
  import SolarTherm.Types.Currency;
  import Modelica.Math;
    
  parameter nSI.Angle_deg lon = -116.783 "Longitude (+ve East) TMY2 Dagget 1967 Location ID 23161";
  parameter nSI.Angle_deg lat = 34.86667 "Lati1tude (+ve North) TMY2 Dagget 1967 Location ID 23161";
  parameter nSI.Time_hour t_zone = -8 "Local time zone (UTC=0) TMY2 Dagget 1967 Location ID 23161";
  parameter Integer year = 1967 "Meteorological year TMY2 Dagget 1967 Location ID 23161";
  parameter nSI.Angle_deg azi_s = 180 "Surface azimuth angle";
  parameter nSI.Angle_deg ele_s = 30 "Surface elevation angle";
  parameter SI.Angle ele_min = 0.0872665 "Stow deploy angle = 5 degree";
  parameter String wea_file = Modelica.Utilities.Files.loadResource("modelica://SolarTherm/Data/Weather/dagget_ca.motab") "[SYS] Weather file";  
      
  parameter SI.Power PV_Target = 10e6 "PV array nameplate in W";
  parameter Integer N_parallel_final_PV(fixed = false) "Number of PV - Inverter unit";
  parameter Integer N_series_final_PV(fixed = false) "Number of array in series";
    
  //parameter SI.Power P_heater = PV_Target - P_hybrid_system_final "Rating of the electrical heater [W]";
  //parameter SI.Efficiency eta_heater = 0.99 "Heater electric to thermal efficiency https://doi.org/10.3390/en14123437";

  parameter Real pri_PV = 1100 "GenCost";  
  parameter FI.Money C_PV = PV_Target / 1e3 * pri_PV "PV cost in $";


  SolarTherm.Models.Sources.DataTable.DataTable data(lon = lon, lat = lat, t_zone = t_zone, year = year, file = wea_file) annotation(
    Placement(visible = true, transformation(origin = {-81, 40}, extent = {{-7, -8}, {7, 8}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression Tamb_input(y = data.Tdry) annotation(
    Placement(visible = true, transformation(origin = {-81, -42}, extent = {{-13, -10}, {13, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression Wspd_input(y = data.Wspd) annotation(
    Placement(visible = true, transformation(origin = {-81, -22}, extent = {{-13, -10}, {13, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression Albedo_input(y = data.Albedo) annotation(
    Placement(visible = true, transformation(origin = {-81, -6}, extent = {{-13, -10}, {13, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression DHI_input(y = data.DHI) annotation(
    Placement(visible = true, transformation(origin = {-81, 10}, extent = {{-13, -10}, {13, 10}}, rotation = 0))); 
  Modelica.Blocks.Sources.RealExpression DNI_input(y = data.DNI) annotation(
    Placement(visible = true, transformation(origin = {-81, 60}, extent = {{-13, -10}, {13, 10}}, rotation = 0)));        

  //********************* Weather inputs
   
  //Modelica.Blocks.Sources.RealExpression Wind_dir(y = data.Wdir) annotation(
  //  Placement(visible = true, transformation(origin = {-129, 51}, extent = {{-11, -13}, {11, 13}}, rotation = 0)));
  //Modelica.Blocks.Sources.RealExpression Pres_input(y = data.Pres) annotation(
   // Placement(transformation(extent = {{76, 18}, {56, 38}})));
  //SolarTherm.Utilities.WspdScaler wspdScaler(H_tower = H_tower) annotation(
    //Placement(visible = true, transformation(origin = {-51, 45}, extent = {{-7, -7}, {7, 7}}, rotation = 0)));

  SolarTherm.Models.Sources.SolarModel.Sun sun(lon = lon, lat = lat, t_zone = t_zone, year = year, redeclare function solarPosition = Models.Sources.SolarFunctions.PSA_Algorithm) annotation(
    Placement(visible = true, transformation(origin = {-6, -20},extent = {{-24, 70}, {-4, 90}}, rotation = 0)));        
    
  SolarTherm.Models.PV.PVarray PVArray( 
                      PV_Target = PV_Target, 
                      azi_s = azi_s, 
                      ele_min = ele_min, 
                      ele_s = ele_s, 
                      lat = lat)
                      annotation(Placement(visible = true, transformation(origin = {-21, -9}, extent = {{-23, -23}, {23, 23}}, rotation = 0)));
                      
  SI.Energy E_pv(start = 0, fixed = true);
  SolarTherm.Models.Storage.Tank.Two_Tanks two_Tanks annotation(
    Placement(visible = true, transformation(origin = {42, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  SolarTherm.Models.Storage.Tank.Tank tank annotation(
    Placement(visible = true, transformation(origin = {42, -56}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  SolarTherm.Models.UtilitiesComponent.SimpleElectricalHeater simpleElectricalHeater annotation(
    Placement(visible = true, transformation(origin = {30, -16}, extent = {{-22, -22}, {22, 22}}, rotation = 0)));
  SolarTherm.Models.UtilitiesComponent.SimpleExchanger simpleExchanger annotation(
    Placement(visible = true, transformation(origin = {74, -18}, extent = {{-12, -12}, {12, 12}}, rotation = 0)));
initial equation
  N_parallel_final_PV = PVArray.N_parallel_final;
  N_series_final_PV = PVArray.N_series;


equation
  der(E_pv) = PVArray.P_net;
  connect(DHI_input.y, PVArray.DHI) annotation(
    Line(points = {{-66.7, 10}, {-43.7, 10}}, color = {0, 0, 127}));
  connect(Albedo_input.y, PVArray.albedo) annotation(
    Line(points = {{-66.7, -6}, {-43.7, -6}, {-43.7, 0}}, color = {0, 0, 127}));
  connect(Wspd_input.y, PVArray.Wspd) annotation(
    Line(points = {{-66.7, -22}, {-43.7, -22}, {-43.7, -18}}, color = {0, 0, 127}));
  connect(Tamb_input.y, PVArray.Tdry) annotation(
    Line(points = {{-66.7, -42}, {-43.7, -42}, {-43.7, -28}}, color = {0, 0, 127}));
  connect(sun.solar, PVArray.sun) annotation(
    Line(points = {{-20, 50}, {-20, 14}}, color = {0, 127, 255}));
  connect(DNI_input.y, sun.dni) annotation(
    Line(points = {{-67, 60}, {-31, 60}}, color = {0, 0, 127}));
  connect(PVArray.W_net, simpleElectricalHeater.W_electric) annotation(
    Line(points = {{4.3, -9}, {15.8, -9}, {15.8, -10}, {13, -10}}, color = {0, 0, 127}));
  connect(tank.fluid_a, simpleElectricalHeater.particle_port_out) annotation(
    Line(points = {{32, -51}, {10, -51}, {10, -22}, {15, -22}}, color = {0, 127, 255}));
  connect(simpleElectricalHeater.particle_port_in, two_Tanks.fluid_b) annotation(
    Line(points = {{45, -9}, {52, -9}, {52, 13}}, color = {0, 127, 255}));
  connect(tank.fluid_b, simpleExchanger.HTF_in) annotation(
    Line(points = {{52, -62}, {74, -62}, {74, -26}}, color = {0, 127, 255}));
  connect(simpleExchanger.Q_out, two_Tanks.fluid_a) annotation(
    Line(points = {{74, -8}, {74, 44}, {26, 44}, {26, 26}, {32, 26}}, color = {0, 0, 127}));
  connect(Tamb_input.y, tank.T_amb) annotation(
    Line(points = {{-66, -42}, {38, -42}, {38, -46}}, color = {0, 0, 127}));
  connect(Tamb_input.y, two_Tanks.T_amb) annotation(
    Line(points = {{-66, -42}, {-50, -42}, {-50, 36}, {38, 36}, {38, 30}}, color = {0, 0, 127}));
protected
annotation(
    uses(SolarTherm(version = "0.2")),
    Icon(coordinateSystem(extent = {{-140, -120}, {160, 140}})),    
    experiment(StopTime = 3.1536e+07, StartTime = 0, Tolerance = 1e-06, Interval = 3600),
    __Dymola_experimentSetupOutput,
    Documentation(revisions = "<html>
	<ul>
	<li> Ye Wang (Aug 2023) :<br>Released PV-TES. </li>
	</ul>
	</html>"),
    __OpenModelica_simulationFlags(lv = "LOG_STATS", outputFormat = "mat", s = "dassl"));
end PV_TES;
