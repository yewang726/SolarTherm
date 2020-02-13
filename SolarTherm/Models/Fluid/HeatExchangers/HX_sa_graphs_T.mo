within SolarTherm.Models.Fluid.HeatExchangers;

model HX_sa_graphs_T
  import SI = Modelica.SIunits;
  import CN = Modelica.Constants;
  import MA = Modelica.Math;
  import SolarTherm.{Models,Media};
  import Modelica.Math.Vectors;
  import UF = SolarTherm.Models.Fluid.HeatExchangers.Utilities;
  import FI = SolarTherm.Models.Analysis.Finances;
  replaceable package Medium1 = Media.Sodium.Sodium_pT "Medium props for Sodium";
  replaceable package Medium2 = Media.ChlorideSalt.ChlorideSalt_pT "Medium props for Molten Salt";
  
  //Design Parameters
  parameter SI.Temperature T_Na2_des[5] = {520+273.15, 525+273.15, 530+273.15, 535+273.15, 540+273.15} "Desing Sodium Hot Fluid Temperature";
  parameter SI.HeatFlowRate Q_d_des=550e6 "Design Heat Flow Rate";
  parameter SI.Temperature T_Na1_des = 740 + 273.15 "Desing Sodium Hot Fluid Temperature";
  parameter SI.Temperature T_MS1_des = 500 + 273.15 "Desing Molten Salt Cold Fluid Temperature";
  parameter SI.Temperature T_MS2_des = 720 + 273.15 "Desing Molten Salt Hot Fluid Temperature";
  parameter SI.Pressure p_Na1_des = 101325 "Design Sodium Inlet Pressure";
  parameter SI.Pressure p_MS1_des = 101325 "Design Molten Salt Inlet Pressure";
  
  //Auxiliary parameters
  parameter Integer dimT = size(T_Na2_des, 1);
  parameter Integer dim_tot = dimT;
  parameter FI.EnergyPrice_kWh c_e = 0.13 / 0.9175 "Power cost";
  parameter Real r = 0.05 "Real interest rate";
  parameter Real H_y(unit = "h") = 4500 "Operating hours";
  parameter Integer n(unit = "h") = 30 "Operating years";
  
  //Optimal Parameter Values
  parameter FI.MoneyPerYear TAC[dim_tot](each fixed = false) "Total Annualized Cost";
  parameter SI.Area A_HX[dim_tot](each fixed = false) "Exchange Area";
  parameter SI.CoefficientOfHeatTransfer U_design[dim_tot](each fixed = false) "Heat tranfer coefficient";
  parameter Integer N_t[dim_tot](each fixed = false) "Number of tubes";
  parameter SI.Pressure Dp_tube_design[dim_tot](each fixed = false) "Tube-side pressure drop";
  parameter SI.Pressure Dp_shell_design[dim_tot](each fixed = false) "Shell-side pressure drop";
  parameter SI.CoefficientOfHeatTransfer h_s_design[dim_tot](each fixed = false) "Shell-side Heat tranfer coefficient";
  parameter SI.CoefficientOfHeatTransfer h_t_design[dim_tot](each fixed = false) "Tube-side Heat tranfer coefficient";
  parameter SI.Length D_s[dim_tot](each fixed = false) "Shell Diameter";
  parameter SI.Velocity v_Na_design[dim_tot](each fixed = false) "Sodium velocity in tubes";
  parameter SI.Velocity v_max_MS_design[dim_tot](each fixed = false) "Molten Salt velocity in shell";
  parameter SI.Volume V_HX[dim_tot](each fixed = false) "Heat-Exchanger Total Volume";
  parameter SI.Mass m_HX[dim_tot](each fixed = false) "Heat-Exchanger Total Mass";
  parameter SI.Mass m_material_HX[dim_tot](each fixed = false) "Optimal HX Material Mass";
  parameter FI.Money_USD C_BEC_HX[dim_tot](each fixed = false) "Bare cost @2018";
  parameter FI.MoneyPerYear C_pump_design[dim_tot](each fixed = false) "Annual pumping cost";
  parameter SI.Length d_o[dim_tot](each fixed = false) "Optimal Outer Tube Diameter";
  parameter SI.Length L[dim_tot](each fixed = false) "Optimal Tube Length";
  parameter Integer N_p[dim_tot](each fixed = false) "Optimal Tube passes number";
  parameter Integer layout[dim_tot](each fixed = false) "Optimal Tube Layout";
  parameter SI.MassFlowRate m_flow_Na_design[dim_tot](each fixed = false) "Sodium mass flow rate";
  parameter SI.MassFlowRate m_flow_MS_design[dim_tot](each fixed = false) "Molten-Salt mass flow rate";
  parameter Real F_design[dim_tot](each fixed = false) "Temperature correction factor";
  parameter SI.ThermalConductance UA_design[dim_tot](each fixed = false) "UA";
  parameter Real ex_eff_design[dim_tot](each fixed = false) "HX Exergetic Efficiency";
  parameter Real en_eff_design[dim_tot](each fixed = false) "HX Energetic Efficiency";
  parameter Integer N_baffles[dim_tot](each fixed = false) "Number of Baffles";
  parameter Real ratio[dim_tot](each fixed = false) "HX L/D Ratio";
  parameter FI.AreaPrice sc_A[dim_tot](each fixed = false) "HX Specific Cost - Area";
  parameter FI.MassPrice sc_m[dim_tot](each fixed = false) "HX Specific Cost - Mass";
  parameter Real sc_cap[dim_tot](each fixed = false) "HX Specific Cost - Capacity";  
  parameter Real saving[dim_tot](each fixed = false) "Investment Cost Saving";
  parameter FI.MassPrice sc_m_ref = 1.65 * 84 "HX Specific Cost - Mass";
  
initial algorithm
  for ii in 1:dimT loop
    (TAC[ii], A_HX[ii], U_design[ii], N_t[ii], Dp_tube_design[ii], Dp_shell_design[ii], h_s_design[ii], h_t_design[ii], D_s[ii], N_baffles[ii], v_Na_design[ii], v_max_MS_design[ii], V_HX[ii], m_HX[ii], m_material_HX[ii], C_BEC_HX[ii], C_pump_design[ii], d_o[ii], L[ii], N_p[ii], layout[ii], m_flow_Na_design[ii], m_flow_MS_design[ii], F_design[ii], UA_design[ii], ex_eff_design[ii], en_eff_design[ii]) := UF.Find_Opt_Design_HX_T_input(Q_d_des = Q_d_des, T_Na1_des = T_Na1_des, T_Na2_des = T_Na2_des[ii], T_MS1_des = T_MS1_des, T_MS2_des = T_MS2_des, p_Na1_des = p_Na1_des, p_MS1_des = p_MS1_des, c_e = c_e, r = r, H_y = H_y, n = n);
    ratio[ii] := L[ii] / D_s[ii];
    sc_A[ii] := C_BEC_HX[ii] / A_HX[ii];
    sc_m[ii] := C_BEC_HX[ii] / m_material_HX[ii];
    sc_cap[ii] := C_BEC_HX[ii] / Q_d_des;
    saving[ii] := (C_BEC_HX[1]-C_BEC_HX[ii])/C_BEC_HX[1]*100;
  end for;
end HX_sa_graphs_T;