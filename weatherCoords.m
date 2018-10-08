function [Coord_Flux,Coord_Wind,Coord_Temp,Coord_Pressure] = weatherCoords(latitude, longitude)

%Calculates weather variables at specified (latitude, longitude)
%coordinates by interpolating NASA Merra2 data. Merra2 data in grid format.
%This function finds grid square of input coordinates and linearly
%interpolates between the four grid points to calculate variables at the
%coordinates. Latitude muste be between +55 and +59. Longitude must be
%between -7 and -2. This is the (lat,lon) ranges of Scotland.


load('coords.mat');
load('totalFlux.mat'); load('totalWind.mat'); load('totalTemp.mat'); load('totalPressure.mat');

z(:,1)=(coords(:,1)-latitude);
z(:,2)=(coords(:,2)-longitude);

lat=z(:,1);
lon=z(:,2);

inter1=find(z(:,1)==max(lat(lat<0)));
inter2=find(z(:,1)==min((lat(lat>0))));
totLat=vertcat(inter1, inter2);

inter3=find(z(:,2)==max(lon(lon<0)));
inter4=find(z(:,2)==min((lon(lon>0))));
totLon=vertcat(inter3, inter4);

C=intersect(totLat, totLon);
extractFlux=vertcat(Flux(C(1),:), Flux(C(2),:), Flux(C(3),:), Flux(C(4),:));
extractWind=vertcat(Wind(C(1),:), Wind(C(2),:), Wind(C(3),:), Wind(C(4),:));
extractTemp=vertcat(Temp(C(1),:), Temp(C(2),:), Temp(C(3),:), Temp(C(4),:));
extractPressure=vertcat(Pressure(C(1),:), Pressure(C(2),:), Pressure(C(3),:), Pressure(C(4),:));

[Coord_Flux]= (coordInterpolate(extractFlux,latitude,longitude))';
[Coord_Wind]= (coordInterpolate(extractWind,latitude,longitude))';
[Coord_Temp]= (coordInterpolate(extractTemp,latitude,longitude))';
[Coord_Pressure]= (coordInterpolate(extractPressure,latitude,longitude))';

end

%%
function [P5]= coordInterpolate(extract, lat, long)

ltlon=extract(:,1:2);
ltlon(5,1)=lat;
ltlon(5,2)=long;
P1=extract(1,3:end);
P2=extract(2,3:end);
P3=extract(3,3:end);
P4=extract(4,3:end);
P = cat(3, P1, P2, P3, P4);
v1 = permute(P(1,1,:), [3 1 2]);
f = scatteredInterpolant(ltlon(1:4,:), v1);
P5 = zeros(size(P1));

for it = 1:size(P,1)
    for ii = 1:size(P,2)
        f.Values = permute(P(it,ii,:), [3 1 2]);
        P5(it,ii) = f(ltlon(5,:));
    end
end

end
%%