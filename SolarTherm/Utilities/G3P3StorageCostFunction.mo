within SolarTherm.Utilities;

/*The cost function is specific for G3P3 project external storage. Can be found in the email conversation 21 Nov 2020*/
/*Participants in conversation: 
    > Clifford Ho, Jeremy Sment (Sandia)
    > John Pye, Philipe Gunawan Gan, Ye Wang (ANU)
    > Luis Gonzales (Polytechnique Madrid)

Boundary of the formula:
    > Storage Aspect Ratio (H/D) = 1.17
    > External storage system (not integrated with the tower)
    > Refractory (insulation) thickness is always 0.6 m
*/

function G3P3StorageCostFunction
import SI = Modelica.SIunits;
import tan = Modelica.Math.tan;
import Modelica.SIunits.Conversions;

input SI.Length H_bin "Bin Height";
input SI.Length D_bin "Bin Diameter";
input SI.Length D_outlet "Oulet diameter of the storage";
input Real t_stg "Capacity of storage [hours]";
input SI.Mass m_tot "Total mass transported by the convetor system over storage hours";
input Real c[:];

output Real C_storage_system;

protected
  Real pi = 3.1415926536;
  Real tan_30 = sqrt(3) / 3;
  SI.Density rho_particle = 2100 "Bulk density of particle [kg/m^3]";
  
  SI.Area A_internal_bin = 2 * pi * D_bin ^ 2 / 4 + 2 * pi * D_bin / 2 * (H_bin - D_bin / 2);
  
  Real Th_dome = 1.5187478830852255e-001 + 2.0904371077436060e-004 * A_internal_bin - 3.9941189858652609e-008 * A_internal_bin ^ 2 + 3.4572388452249412e-012 * A_internal_bin ^ 3;
  
  SI.Volume V_refractory = 4 * pi / 3 * ((D_bin / 2 + 0.6) ^ 3 - (D_bin / 2) ^ 3) / 2 + pi * (H_bin - D_bin / 2) * ((D_bin / 2 + 0.6) ^ 2 - (D_bin / 2) ^ 2);
  
  SI.Volume V_dome = 4 * pi / 3 * ((D_bin / 2 + 0.6 + Th_dome) ^ 3 - (D_bin / 2 + 0.6) ^ 3) / 2 + pi * (H_bin - D_bin / 2) * ((D_bin / 2 + 0.6 + Th_dome) ^ 2 - (D_bin / 2 + 0.6) ^ 2);
  
  SI.Volume V_floor = pi / 3 * tan_30 * (2 * (D_bin / 2) ^ 3 - 3 * (D_outlet / 2) * (D_bin / 2) ^ 2 + (D_outlet / 2) ^ 3);
  
  Real c_bin = 1.8176278045646707e+003 * A_internal_bin ^ 0 - 1.1473217312437778e+000 * A_internal_bin ^ 1 + 5.0908598577662086e-004 * A_internal_bin ^ 2 - 9.5646352382126223e-008 * A_internal_bin ^ 3 + 6.3298984602648625e-012 * A_internal_bin ^ 4;
  
  /*Constant specific cost*/
  Real c_HRC = c[1] "Specific cost of high resistance concrete [USD/m^3]";
  Real c_portland = c[2] "Specific cost of portland concrete [USD/m^3]";
  Real c_RF = c[3] "Specific cost of refractory [USD/m^3]";
  Real c_filler_floor = c[4] "Specific cost of floor filler material [USD/m^3]";
  Real c_particle = c[5] "Cost to hold particle mass [USD/kg]";
  Real c_HX_vol_pair = c[6] "HX Volume for pair of 16.5 P1157C-1016 Units";
  Real c_excav = c[7] "Specififc excavation cost[USD/m^3]";
  Real cap_conveyor = c[8] "Capacity of transorting particle of a single conveyor [ton/h]";
  Real c_conveyor = c[9] "Specific cost of conveyor [USD/unit]";
  
  /*Calculated intermediate cost*/
  Real C_HRC_33 = V_dome * 0.67 * c_HRC;
  Real C_HRC_67 = C_HRC_33 - V_dome * 0.67 * c_portland;
  Real C_RF = V_refractory * c_RF;
  Real C_bin = c_bin * A_internal_bin;
  Real C_floor = V_floor * 0.9 * c_filler_floor + V_floor * 0.1 * rho_particle * c_particle;
  Real C_bin_refractory_dome_floor = 2 * (C_bin + C_RF + C_HRC_67 + C_floor);
  Real C_conveyor_excavator = 6 * c_HX_vol_pair * c_excav + m_tot * c_conveyor / (1000 * t_stg * cap_conveyor);
                

algorithm
C_storage_system := C_bin_refractory_dome_floor + C_conveyor_excavator;

end G3P3StorageCostFunction;