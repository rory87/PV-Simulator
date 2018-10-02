function [DNI, DHI]=calculateIrradiance2(GHI, Time, Location)

%load('TimeMatlab.mat');
%load('C:\Users\ylb10119\Documents\Sharefile\Personal Folders\MATLAB New PC\NASA MERRA Data\Complete 2015 Data\Flux\totalFlux.mat');

t=0; %GMT
%Time = pvl_maketimestruct(TimeMatlab, ones(size(TimeMatlab))*t);
dayofyear = pvl_date2doy(Time.year, Time.month, Time.day);
[SunAz, SunEl, AppSunEl, SolarTime] = pvl_ephemeris(Time,Location);
DNI = (pvl_disc(GHI,90-SunEl, dayofyear));
DHI= GHI - cosd(90-SunEl).*DNI;


end


