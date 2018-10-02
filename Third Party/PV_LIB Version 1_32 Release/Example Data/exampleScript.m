clear all; %clear memory before running script
close all; %close all files and figures
ModuleParameters = pvl_sapmmoduledb(123,'SandiaModuleDatabase_20120925.xlsx')
load('SandiaInverterDatabaseSAM2014.1.14.mat')
% PV Powered PVP2500 inverter is #793 in the InverterNames cell array
Inverter = SNLInverterDB(793)
clear InverterNames SNLInverterDB
Array.Tilt = 23; % Array tilt angle (deg)
Array.Azimuth = 180; %Array azimuth (180 deg indicates array faces South)
Array.Ms = 9; %Number of modules in series
Array.Mp = 2; %Number of paralell strings
Array.a = -3.56;
Array.b = -0.075;
TMYData = pvl_readtmy3('723650TY.csv');
TimeMatlab = TMYData.DateNumber;
Time = pvl_maketimestruct(TimeMatlab, ones(size(TimeMatlab))*TMYData.SiteTimeZone);
DNI = TMYData.DNI;
DHI = TMYData.DHI;
GHI = TMYData.GHI;
figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),DNI(tfilter),'-*')
hold all
plot(Time.hour(tfilter),DHI(tfilter),'-o')
plot(Time.hour(tfilter),GHI(tfilter),'-x')
legend('DNI','DHI','GHI')
xlabel('Hour of Day')
ylabel('Irradiance (W/m^2)')
title('Albuquerque TMY3 - Aug 2','FontSize',14)
%Location = pvl_makelocationstruct(TMYData.SiteLatitude,TMYData.SiteLongitude,TMYData.SiteElevation) %Altitude is optional
Location = pvl_makelocationstruct(58,-4,TMYData.SiteElevation) %Altitude is optional
PresPa = TMYData.Pressure*100; %Convert pressure from mbar to Pa
[SunAz, SunEl, AppSunEl, SolarTime] = pvl_ephemeris(Time,Location,PresPa,TMYData.DryBulb);
figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),90-AppSunEl(tfilter),'-s')
hold all
plot(Time.hour(tfilter),SunAz(tfilter),'-o')
legend('Zenith angle','Azimuth Angle')
xlabel('Hour of Day')
ylabel('Angle (deg)')
title('Albuquerque Sun Position - Aug 2','FontSize',14);
AMa = pvl_absoluteairmass(pvl_relativeairmass(90-AppSunEl),PresPa);
AOI = pvl_getaoi(Array.Tilt, Array.Azimuth, 90-AppSunEl, SunAz);
figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),AOI(tfilter),'-s')
legend('AOI','Location','SE')
xlabel('Hour of Day')
ylabel('Angle (deg)')
title('Albuquerque Angle of Incidence - Aug 2','FontSize',14)
Eb = 0*AOI; %Initiallize variable
Eb(AOI<90) = DNI(AOI<90).*cosd(AOI(AOI<90)); %Only calculate when sun is in view of the plane of array
EdiffSky = pvl_isotropicsky(Array.Tilt,DHI);
Albedo = 0.2;
EdiffGround = pvl_grounddiffuse(Array.Tilt,GHI, Albedo);
E = Eb + EdiffSky + EdiffGround; % Total incident irradiance (W/m^2)
Ediff = EdiffSky + EdiffGround; % Total diffuse incident irradiance (W/m^2)
figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),Eb(tfilter),'-s')
hold all
plot(Time.hour(tfilter),EdiffSky(tfilter),'-o')
plot(Time.hour(tfilter),EdiffGround(tfilter),'-x')
legend('Eb','EdiffSky','EdiffGround')
xlabel('Hour of Day')
ylabel('Irradiance (W/m^2')
title('Albuquerque POA Irradiance Components - Aug 2','FontSize',14);
SF=0.98;
E0 = 1000; %Reference irradiance (1000 W/m^2)
celltemp = pvl_sapmcelltemp(E, E0, Array.a, Array.b, TMYData.Wspd, TMYData.DryBulb, ModuleParameters.delT);
F1 = max(0,polyval(ModuleParameters.a,AMa)); %Spectral loss function
F2 = max(0,polyval(ModuleParameters.b,AOI)); % Angle of incidence loss function
Ee = F1.*((Eb.*F2+ModuleParameters.fd.*Ediff)/E0)*SF; %Effective irradiance
Ee(isnan(Ee))=0; % Set any NaNs to zero
mSAPMResults = pvl_sapm(ModuleParameters, Ee, celltemp);
aSAPMResults.Vmp = Array.Ms  *mSAPMResults.Vmp;
aSAPMResults.Imp = Array.Mp  *mSAPMResults.Imp;
aSAPMResults.Pmp = aSAPMResults.Vmp .* aSAPMResults.Imp;
figure('OuterPosition',[100 100 600 800])
tfilter = and(Time.month == 8,Time.day == 2);
subplot(3,1,1)
plot(Time.hour(tfilter),aSAPMResults.Pmp(tfilter),'-sr')
legend('Pmp')
%xlabel('Hour of Day')
ylabel('DC Power (W)')
title('Albuquerque DC Array Output - Aug 2','FontSize',14)
subplot(3,1,2)
plot(Time.hour(tfilter),aSAPMResults.Imp(tfilter),'-ob')
legend('Imp')
%xlabel('Hour of Day')
ylabel('DC Current (A)')
%title('Albuquerque Vmp and Imp - Aug 2','FontSize',12)
subplot(3,1,3)
plot(Time.hour(tfilter),aSAPMResults.Vmp(tfilter),'-xg')
legend('Vmp')
xlabel('Hour of Day')
ylabel('DC Volatage (V)')
%title('Albuquerque Vmp and Imp - Aug 2','FontSize',12)
ACPower = pvl_snlinverter(Inverter, mSAPMResults.Vmp*Array.Ms, mSAPMResults.Pmp*Array.Ms*Array.Mp);
figure
tfilter = and(Time.month == 8,Time.day == 2);
plot(Time.hour(tfilter),aSAPMResults.Pmp(tfilter),'-sr')
hold all
plot(Time.hour(tfilter),ACPower(tfilter),'-ob')
legend('DC Pmp', 'AC Power')
%xlabel('Hour of Day')
ylabel('Power (W)')
title('Albuquerque DC and AC Power Output - Aug 2','FontSize',14)