function [Flux, DNI, DHI]=calculateIrradiance()

%load('TimeMatlab.mat');
%load('C:\Users\ylb10119\Documents\Sharefile\Personal Folders\MATLAB New PC\NASA MERRA Data\Complete 2015 Data\Flux\totalFlux.mat');

t=0; %GMT
%Time = pvl_maketimestruct(TimeMatlab, ones(size(TimeMatlab))*t);
dayofyear = pvl_date2doy(Time.year, Time.month, Time.day);

DNI=zeros(90,8786);
DHI=zeros(90,8786);

for i=1:size(Flux,1)
    Location = pvl_makelocationstruct(Flux(i,1),Flux(i,2));
    GHI=(Flux(i,3:end))';
    [SunAz, SunEl, AppSunEl, SolarTime] = pvl_ephemeris(Time,Location);
    DNI(i,3:end) = (pvl_disc(GHI,90-SunEl, dayofyear))'; DNI(i,1:2)=Flux(i,1:2);
    DHI(i,3:end) = (GHI - cosd(90-SunEl).*(DNI(i,3:end))')'; DHI(i,1:2)=Flux(i,1:2);
end

