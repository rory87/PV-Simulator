

%TimeMatlab = TMYData.DateNumber;
%Time = pvl_maketimestruct(TimeMatlab, ones(size(TimeMatlab))*TMYData.SiteTimeZone);

%TMYData = pvl_readtmy3('723650TY.csv');
%TimeMatlab = TMYData.DateNumber;
Time = pvl_maketimestruct(TimeMatlab, ones(size(TimeMatlab))*-7);
dayofyear = pvl_date2doy(Time.year, Time.month, Time.day);
% DNI = TMYData.DNI; % Read in for comparison with results
% DHI = TMYData.DHI; % Read in for comparison with results
% GHI = TMYData.GHI;

figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),GHI(tfilter),'-*')

legend('GHI')
xlabel('Hour of Day')
ylabel('Irradiance (W/m^2)')
title('Albuquerque TMY3 - Aug 2','FontSize',14)

Location = pvl_makelocationstruct(35,-106.5);
% 
%PresPa = TMYData.Pressure*100; %Convert pressure from mbar to Pa
[SunAz, SunEl, AppSunEl, SolarTime] = pvl_ephemeris(Time,Location,PresPa,TMYData.DryBulb);

figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),90-SunEl(tfilter),'-s')
hold all
plot(Time.hour(tfilter),SunAz(tfilter),'-o')
legend('Zenith angle','Azimuth Angle')
xlabel('Hour of Day')
ylabel('Angle (deg)')
title('Albuquerque Sun Position - Aug 2','FontSize',14)
DNI_model = pvl_disc(GHI,90-SunEl, dayofyear, PresPa);

figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),DNI_model(tfilter),'-s')
hold all
%plot(Time.hour(tfilter),DNI(tfilter),'-o')
legend('DNI (DISC Model)')
xlabel('Hour of Day')
ylabel('Irradiance (W/m^2)')
title('Albuquerque Direct Normal Irradiance Comparison - Aug 2','FontSize',14)

DHI_model = GHI - cosd(90-SunEl).*DNI_model;
figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),DHI_model(tfilter),'-s')
hold all
%(Time.hour(tfilter),DHI(tfilter),'-o')
legend('DHI (modeled from GHI)')
xlabel('Hour of Day')
ylabel('Irradiance (W/m^2)')
title('Albuquerque Diffuse Horizontal Irradiance Comparison - Aug 2','FontSize',14)
