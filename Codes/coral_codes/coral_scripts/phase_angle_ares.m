%%%%%%%%%%%%
% The following calculates the phase shift angle for
% PKiKP reflections. It is called by ray_syn_fun.m
% and therefore is rather inflexible.
%%%%%%%%%%%%

delta_ares = delta*180/pi;
[ares_t,ares_p] = get_ttt('PKiKP',depth,delta_ares,'ak135');
clear ares_t
ares_p = ares_p*180/pi/1217;
a = [11.0429 10.2890];                          % Vp across ICB according to ak135
b = [3.5045 0];                                 % Vs across ICB according to ak135
rho = [12.7039 12.1388];                        % rho across ICB according to ak135

[ares_C,ierr] = reflect_coeff_ares(a,b,rho,ares_p);
reflection_coeff = abs(ares_C.PupPdown);
clear a b ares_p ierr reflection_coeff rho delta_ares
phase_angle_radians = angle(ares_C.PupPdown);
phase_angle_degrees = (angle(ares_C.PupPdown)*180)/pi;
