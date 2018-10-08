function [completeFlux, completeWind, completeTemp, completePressure] = weatherGSP(GSP_lat_long, GSPNames)

load('coords.mat');
load('totalFlux.mat'); load('totalWind.mat'); load('totalTemp.mat'); load('totalPressure.mat');
        

for i=1:size(GSP_lat_long,1)
z(:,1)=(coords(:,1)-GSP_lat_long(i,1));
z(:,2)=(coords(:,2)-(GSP_lat_long(i,2)));

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

[GSP_Flux(i,:)]= coordInterpolate(extractFlux,GSP_lat_long(i,1),GSP_lat_long(i,2));
[GSP_Wind(i,:)]= coordInterpolate(extractWind,GSP_lat_long(i,1),GSP_lat_long(i,2));
[GSP_Temp(i,:)]= coordInterpolate(extractTemp,GSP_lat_long(i,1),GSP_lat_long(i,2));
[GSP_Pressure(i,:)]= coordInterpolate(extractPressure,GSP_lat_long(i,1),GSP_lat_long(i,2));

end

[completeFlux]=sortGSP(GSP_Flux, GSPNames);
[completeWind]=sortGSP(GSP_Wind, GSPNames);
[completeTemp]=sortGSP(GSP_Temp, GSPNames);
[completePressure]=sortGSP(GSP_Pressure, GSPNames);

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

function [complete] = sortGSP (raw, GSPNames)
        
time=datetime(2015,4,1,0,0,0):hours(1):datetime(2016,3,31,23,0,0);

complete={};
complete(1,2:8785)=cellstr(time);
complete(2:(size(GSPNames)+1),1)=GSPNames;
complete(2:end,2:end)=num2cell(raw);

end

