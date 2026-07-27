%% run_pixel_offset_PARTVII_newB3nn.m
% Exportación SHP de PUNTOS DIC georreferenciados
% Basado en resultados de newB2n / newB3

disp('<<< Running run_pixel_offset_PARTVII_newB3nn >>>')

%% =============================================================
%% 1. Comprobación de variables REALES del workspace
%% =============================================================

% % vars_needed = {'xw','yw','Uv','Vv','MAGv','RMSEv','epsg','yourtext'};
% % 
% % missing = vars_needed(~cellfun(@(v) exist(v,'var'), vars_needed));
% % if ~isempty(missing)
% %     error('Faltan variables en el workspace: %s', strjoin(missing,', '));
% % end


vars_needed = {'xw','yw','Uv','Vv','MAGv','RMSEv','epsg','yourtext'};

missing = vars_needed( ...
    ~cellfun(@(v) evalin('base',['exist(''',v,''',''var'')']), vars_needed));

if ~isempty(missing)
    error('Faltan variables en el workspace base: %s', strjoin(missing,', '));
end


%% =============================================================
%% 2. Construcción del SHP de puntos
%% =============================================================

n = numel(xw);
S = struct([]);

for i = 1:n
    S(i).Geometry = 'Point';
    S(i).X = xw(i);
    S(i).Y = yw(i);

    % --- atributos DIC ---
    S(i).Ux   = Uv(i);
    S(i).Uy   = Vv(i);
    S(i).MAG  = MAGv(i);
    S(i).DIR  = atan2d(Vv(i),Uv(i));
    S(i).RMSE = RMSEv(i);
end

%% =============================================================
%% 3. Escritura SHP + PRJ
%% =============================================================

OUT = fullfile(pwd,'Output','SHP');
if ~exist(OUT,'dir'), mkdir(OUT); end

shpname = fullfile(OUT,[yourtext '_points_valid']);
shapewrite(S,shpname);

crs = projcrs(epsg);
fid = fopen([shpname '.prj'],'w');
fprintf(fid,'%s', wktstring(crs));
fclose(fid);

disp(['>>> SHAPE DIC de PUNTOS generado: ' shpname])
disp('<<< FIN – run_pixel_offset_PARTVII_newB3nn >>>')