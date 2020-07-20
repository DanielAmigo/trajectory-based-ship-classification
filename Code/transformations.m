%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Esta clase proporciona funciones auxiliares al filtrado realizado

classdef transformations
    methods(Static)

        %%
        function result = degrees_to_radian(degrees)
          result = degrees * pi / 180.0;
        end

        %%
        function [px, py, pz] = posWGS84toCar(lat, lon, h, lat_orig, lon_orig, h_orig)
          %%% Constantes de la latitud conforme.
          EARTH_ECCENTRICITY = 0.081819191;
          EARTH_MAX_R = 6378137.0; % Earth Radius [m].
          
          cos_lat = cos(transformations.degrees_to_radian(lat));
          sin_lat = sin(transformations.degrees_to_radian(lat));
          tan_lat = sin_lat / cos_lat;

          cos_lon = cos(transformations.degrees_to_radian(lon));
          sin_lon = sin(transformations.degrees_to_radian(lon));

          cos_lat_orig = cos(transformations.degrees_to_radian(lat_orig));
          sin_lat_orig = sin(transformations.degrees_to_radian(lat_orig));
          tan_lat_orig = sin_lat_orig / cos_lat_orig;

          cos_lon_orig = cos(transformations.degrees_to_radian(lon_orig));
          sin_lon_orig = sin(transformations.degrees_to_radian(lon_orig));

          aux1 = EARTH_ECCENTRICITY * EARTH_ECCENTRICITY;
          aux2 = (1.0 - aux1);

          % calculos para posicion ECEF del punto en superficie de aeronave y radar
          aux3 = sqrt(1 + aux2 * tan_lat * tan_lat);
          pos_destECEF = zeros(3, 1);
          pos_destECEF(1, 1) = EARTH_MAX_R * cos_lon / aux3;
          pos_destECEF(2, 1) = EARTH_MAX_R * sin_lon / aux3;
          pos_destECEF(3, 1) = EARTH_MAX_R * aux2 * sin_lat / sqrt(1 - aux1 * sin_lat * sin_lat);

          aux4 = sqrt(1 + aux2 * tan_lat_orig * tan_lat_orig);
          pos_origECEF = zeros(3, 1);
          pos_origECEF(1, 1) = EARTH_MAX_R * cos_lon_orig / aux4;
          pos_origECEF(2, 1) = EARTH_MAX_R * sin_lon_orig / aux4;
          pos_origECEF(3, 1) = EARTH_MAX_R * aux2 * sin_lat_orig / sqrt(1 - aux1 * sin_lat_orig * sin_lat_orig);

          %calculo de posiciones de aeronave y radar en coordenadas ECEF
          pos_destECEF(1, 1) = pos_destECEF(1, 1) + h * cos_lon * cos_lat;
          pos_destECEF(2, 1) = pos_destECEF(2, 1) + h * sin_lon * cos_lat;
          pos_destECEF(3, 1) = pos_destECEF(3, 1) + h * sin_lat;

          pos_origECEF(1, 1) = pos_origECEF(1, 1) + h_orig * cos_lon_orig * cos_lat_orig;
          pos_origECEF(2, 1) = pos_origECEF(2, 1) + h_orig * sin_lon_orig * cos_lat_orig;
          pos_origECEF(3, 1) = pos_origECEF(3, 1) + h_orig * sin_lat_orig;

          %vector diferencia de posicion, distance(medida del radar) y vector unitario
          unit = pos_destECEF - pos_origECEF;

          %vectores precisos para el calculo del azimut, y del SwitchingMode de coordenadas
          xs = zeros(3, 1);
          xs(1, 1) = -sin_lon_orig;
          xs(2, 1) = cos_lon_orig;
          xs(3, 1) = 0.0;
          ys = zeros(3, 1);
          ys(1, 1) = -sin_lat_orig * cos_lon_orig;
          ys(2, 1) = -sin_lat_orig * sin_lon_orig;
          ys(3, 1) = cos_lat_orig;
          zs = zeros(3, 1);
          zs(1, 1) = cos_lat_orig * cos_lon_orig;
          zs(2, 1) = cos_lat_orig * sin_lon_orig;
          zs(3, 1) = sin_lat_orig;

          pxAux = (transpose(unit) * xs);
          px = pxAux(1, 1);
          pyAux = (transpose(unit) * ys);
          py = pyAux(1, 1);
          pzAux = (transpose(unit) * zs);
          pz = pzAux(1, 1);
        end

        %%
        function [vx, vy, vz, valid] = velWGS84toCar(speed, course, angle_of_climb)
            valid = true;
            vx = speed * sin(transformations.degrees_to_radian(course)) * cos(transformations.degrees_to_radian(angle_of_climb));
            vy = speed * cos(transformations.degrees_to_radian(course)) * cos(transformations.degrees_to_radian(angle_of_climb));
            vz = speed * sin(transformations.degrees_to_radian(angle_of_climb));     
        end
    end
end