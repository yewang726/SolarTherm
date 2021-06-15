within examples;

model ReceiverTestRig_IterateMassFlow
  /*st_simulate --stop 1 --np 0 --tolerance 1e-06 ReceiverTestRig_IterateMassFlow.mo H_drop_design=38.02181715308447 T_out_design=1318.714569288698 T_amb_design=267.000345168053 T_in_design=1180.6007808410518 Q_in=550127686.9209708
                                                        

                                    39.30487929238938,1426.5166909751956,311.00266227552925,1326.4733930070881,909132450.0548977,0,419586515.7713164,
                                                                */
  extends SolarTherm.Icons.ToDo;
  import SolarTherm.{Models,Media};
  import Modelica.SIunits.Conversions.from_degC;
  import SI = Modelica.SIunits;
  import nSI = Modelica.SIunits.Conversions.NonSIunits;
  import CN = Modelica.Constants;
  import CV = Modelica.SIunits.Conversions;
  import FI = SolarTherm.Models.Analysis.Finances;
  import Util = SolarTherm.Media.SolidParticles.CarboHSP_utilities;
  import Modelica.Math;
  import Modelica.Blocks;
  replaceable package Medium = SolarTherm.Media.SolidParticles.CarboHSP_ph "Medium props for Carbo HSP 40/70";
  // Design Condition
  parameter SI.Length H_drop_design = 20.690760;
  parameter Real T_out_design = 1454.288084;
  parameter Real T_amb_design = 288.820712;
  parameter Real T_in_design = 1302.833673;
  parameter SI.HeatFlowRate Q_in = 1.315170e+08;
  parameter SI.HeatFlowRate Q_threshold = 1.204220e+08;
  parameter Real Wspd_des = 5;
  parameter Real Wdir_des = 90;
  parameter Real mdot_guess = Q_in / Q_threshold * 100 * 10;
  parameter SI.Efficiency eta_rec_assumption = 0.88;
  Modelica.Fluid.Sources.FixedBoundary source(redeclare package Medium = Medium, T = T_in_design, nPorts = 1, p = 1e5, use_T = true, use_p = false) annotation(
    Placement(visible = true, transformation(origin = {60, -14}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  Modelica.Fluid.Sources.FixedBoundary sink(redeclare package Medium = Medium, T = 300.0, d = 3300, nPorts = 1, p = 1e5, use_T = true) annotation(
    Placement(visible = true, transformation(extent = {{34, 22}, {14, 42}}, rotation = 0)));
  Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow Heat(Q_flow = Q_in, T_ref = 298.15) annotation(
    Placement(visible = true, transformation(origin = {-78, 44}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.BooleanExpression Operation(y = true) annotation(
    Placement(visible = true, transformation(origin = {-78, -4}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression Tamb(y = T_amb_design) annotation(
    Placement(visible = true, transformation(origin = {32, 88}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  SolarTherm.Models.Fluid.Pumps.LiftSimple liftSimple(use_input = true) annotation(
    Placement(visible = true, transformation(origin = {22, -16}, extent = {{-16, -16}, {16, 16}}, rotation = 0)));
  SolarTherm.Models.CSP.CRS.Receivers.ParticleReceiver1D_IterateMassFlow particleReceiver1D(N = 15, fixed_geometry = true, test_mode = false, with_uniform_curtain_props = false, with_wall_conduction = true, H_drop_design = H_drop_design, with_detail_h_ambient = false, with_wind_effect = false, T_ref = T_in_design, T_out_design = T_out_design) annotation(
    Placement(visible = true, transformation(origin = {-25, 37}, extent = {{-17, -17}, {17, 17}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression Wspd(y = Wspd_des) annotation(
    Placement(visible = true, transformation(origin = {-78, 92}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.RealExpression Wdir(y = Wdir_des) annotation(
    Placement(visible = true, transformation(origin = {-78, 76}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
initial equation
  particleReceiver1D.mdotguess = mdot_guess;
equation
  connect(source.ports[1], liftSimple.fluid_a) annotation(
    Line(points = {{50, -14}, {27, -14}}, color = {0, 127, 255}));
  connect(Heat.port, particleReceiver1D.heat) annotation(
    Line(points = {{-68, 44}, {-42, 44}, {-42, 42}, {-42, 42}}, color = {191, 0, 0}));
  connect(particleReceiver1D.fluid_b, sink.ports[1]) annotation(
    Line(points = {{-20, 46}, {14, 46}, {14, 32}, {14, 32}}, color = {0, 127, 255}));
  connect(liftSimple.fluid_b, particleReceiver1D.fluid_a) annotation(
    Line(points = {{16, -14}, {-22, -14}, {-22, 22}, {-22, 22}}, color = {0, 127, 255}));
  connect(Operation.y, particleReceiver1D.on) annotation(
    Line(points = {{-66, -4}, {-28, -4}, {-28, 22}, {-28, 22}}, color = {255, 0, 255}));
  connect(Tamb.y, particleReceiver1D.Tamb) annotation(
    Line(points = {{21, 88}, {-20, 88}, {-20, 50}}, color = {0, 0, 127}));
  connect(Wspd.y, particleReceiver1D.Wspd) annotation(
    Line(points = {{-66, 92}, {-24, 92}, {-24, 50}, {-24, 50}}, color = {0, 0, 127}));
  connect(Wdir.y, particleReceiver1D.Wdir) annotation(
    Line(points = {{-66, 76}, {-28, 76}, {-28, 50}, {-30, 50}}, color = {0, 0, 127}));
protected
  annotation(
    uses(Modelica(version = "3.2.2"), SolarTherm(version = "0.2")),
    experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 1),
    __OpenModelica_simulationFlags(lv = "LOG_STATS", outputFormat = "mat", s = "dassl"),
    Diagram);
end ReceiverTestRig_IterateMassFlow;