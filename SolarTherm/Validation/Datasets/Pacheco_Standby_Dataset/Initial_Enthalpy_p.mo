within SolarTherm.Validation.Datasets.Pacheco_Standby_Dataset;

function Initial_Enthalpy_p "Input height array and number of particle CVs, output enthalpy array based on constant Quartzite_Sand properties"
  input SI.Length[:] z_f;
  input Integer N_p;
  output SI.SpecificEnthalpy[size(z_f, 1), N_p] h_p;
protected
  Integer N_f = size(z_f, 1);
  Real T;
  Integer j;
  SI.Length[43] z_data = {0.3839179018, 0.4425522034, 0.5057852737, 0.6828378707, 0.8391960084, 0.8874830803, 0.9415186131, 1.0410819566, 1.1041009464, 1.2365930599, 1.274009594, 1.3531084165, 1.4197905635, 1.4979696323, 1.5692505479, 1.6083400823, 1.6497290011, 1.6899682277, 1.7325068387, 1.7888417559, 1.8394282122, 1.9256551263, 2.0594026509, 2.1640378549, 2.4430166111, 2.7001644305, 3.1417420385, 3.3872971284, 3.6570915619, 3.9289937645, 4.3874335246, 4.6308808454, 4.8977244024, 5.3359295799, 5.4984227129, 5.6807518119, 5.7012442728, 5.7173399634, 5.7437828837, 5.7541301134, 5.7771239572, 5.8057208985, 5.8196625682};
  SI.Temperature[43] T_data = {603.9905541818, 606.8433030724, 609.696051963, 612.5488008536, 615.4015497443, 618.2542986349, 621.1070475255, 623.9597964161, 625.829245283, 625.15, 626.8125453067, 629.6652941974, 632.518043088, 635.3707919786, 638.2235408692, 641.0762897598, 643.9290386505, 646.7817875411, 649.6345364317, 652.4872853223, 655.3400342129, 658.1927831036, 660.7861911859, 661.6028301887, 662.0828952271, 662.8609176518, 663.7686104807, 664.6763033095, 665.3246553301, 665.8433369466, 666.3620185631, 666.8807001795, 666.2842163206, 666.8807001795, 667.9424528302, 667.7225415806, 664.9356441177, 662.0828952271, 659.2301463365, 656.3773974459, 653.5246485553, 650.6718996646, 647.819150774};
algorithm
  for i in 1:N_f loop
    j := 0;
    while j <= 42 loop
      if z_f[i] < z_data[1] then
        for k in 1:N_p loop
          T := T_data[1] + (z_f[i] - z_data[1]) / (z_data[2] - z_data[1]) * (T_data[2] - T_data[1]);
          h_p[i, k] := Filler.h_Tf(T, 0);
        end for;
        break;
      elseif z_f[i] >= z_data[j] and z_f[i] <= z_data[j + 1] then
        for k in 1:N_p loop
          T := T_data[j] + (T_data[j + 1] - T_data[j]) * (z_f[i] - z_data[j]) / (z_data[j + 1] - z_data[j]);
          h_p[i, k] := Filler.h_Tf(T, 0);
        end for;
        break;
      elseif z_f[i] > z_data[42] then
        for k in 1:N_p loop
          T := T_data[41] + (z_f[i] - z_data[41]) / (z_data[42] - z_data[41]) * (T_data[42] - T_data[41]);
          h_p[i, k] := Filler.h_Tf(T, 0);
        end for;
        break;
      else
        j := j + 1;
      end if;
    end while;
  end for;
end Initial_Enthalpy_p;