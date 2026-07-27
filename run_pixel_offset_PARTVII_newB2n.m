%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % run_pixel_offset_PARTVII_newB2n.m

%
% MATLAB y ArcMap representan EXACTAMENTE el mismo campo DIC
% Versión estable con diagnóstico completo de consola
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; close all;

%% =========================================================================
% CONFIGURACIÓN DE RUTAS
%% =========================================================================
ROOT  = 'D:\Jijona\jijona\modificación_02_1_26\DIC';
INPUT = fullfile(ROOT,'Input');
OUT   = fullfile(ROOT,'Output');

addpath('D:\Jijona\jijona\DIC_funciones originales');
addpath(ROOT);

if ~exist(OUT,'dir'), mkdir(OUT); end

%% =========================================================================
% PARÁMETROS GENERALES
%% =========================================================================
pix   = 0.25;     % m/px
thr   = 0.95; %thr   = 1.2;
wi    = 160;%wi    = 160;
os    = 3;
skip  = wi/2;

yourtext = '19_t0_2016_clip2_025_ld_hillshade_tif_tif_t1_2023_clip2_025_ld_hillshade_tif';
% yourtext = 'aeas_cliped_jijona_PNOA_2014_b3_clip_2021_b3_clip';


tstart = tic;   % tiempo total


%% =========================================================================
% SELECCIÓN DE IMÁGENES
%% =========================================================================
cd(INPUT)
imgs = dir('*.tif');
[~,ix] = sort({imgs.name});
imgs = imgs(ix);

fprintf('Imágenes disponibles:\n');
for i=1:numel(imgs)
    fprintf('%d: %s\n',i,imgs(i).name);
end

i1 = input('Selecciona imagen primaria: ');
i2 = input('Selecciona imagen secundaria: ');

% % I0 = imread(imgs(i1).name);ficheros tif simples (mod_21_6_2026)
% % I1 = imread(imgs(i2).name);

[I0,R] = readgeoraster(imgs(i1).name);
[I1,~] = readgeoraster(imgs(i2).name);

[I0,R] = readgeoraster(imgs(i1).name);
[I1,~] = readgeoraster(imgs(i2).name);

% Convertir a escala de grises si es multibanda
if ndims(I0)==3
    I0 = I0(:,:,1);
end

if ndims(I1)==3
    I1 = I1(:,:,1);
end

% ✅ NORMALIZACIÓN PARA VISUALIZACIÓN
I0_vis = mat2gray(I0);
I1_vis = mat2gray(I1);


%% =========================================================================
% GEOREFERENCIACIÓN
%% =========================================================================
[R,~] = local_build_R_from_worldfile(imgs(i1).name,[size(I0,1) size(I0,2)]);
assert(~isempty(R),'No se pudo construir la referencia espacial');

epsg = 25830;

%% =========================================================================
% DIC
%% =========================================================================
fprintf('<<< Running DIC >>>\n');

tpix = tic;
RR = pixoff(I0,I1,skip,skip,wi,os,'t1-t0');
fprintf('Tiempo pixoff(T0,T1): %.1f s\n', toc(tpix));

%% =========================================================================
% DIAGNÓSTICO EN CONSOLA (BRUTO)
%% =========================================================================
Ux_px = mean(RR(:,4));
Uy_px = mean(RR(:,3));

fprintf('pixoff(T0,T1) -> mean px: Ux=%+6.3f  Uy=%+6.3f\n',Ux_px,Uy_px);

RRinv = pixoff(I1,I0,skip,skip,wi,os,'t0-t1');
fprintf('pixoff(T1,T0) -> mean px: Ux=%+6.3f  Uy=%+6.3f\n', ...
        mean(RRinv(:,4)), mean(RRinv(:,3)));

fprintf('DIC (media, px):       Ux=%+6.3f  Uy=%+6.3f\n',Ux_px,Uy_px);
fprintf('DIC (media, unidades): Ux=%+6.3f  Uy=%+6.3f  (m)\n', ...
        Ux_px*pix, Uy_px*pix);

%% =========================================================================
% CONVERSIÓN A UNIDADES REALES
%% =========================================================================
DX   = RR(:,4) * pix;
DY   = RR(:,3) * pix;
MAG  = hypot(DX, DY);
RMSE = RR(:,5);

%% =========================================================================
% FILTRADO ÚNICO (REFERENCIA MATLAB)
%% =========================================================================
idx_valid = RMSE < thr;

Xv    = RR(idx_valid,2);
Yv    = RR(idx_valid,1);
Uv    = DX(idx_valid);
Vv    = DY(idx_valid);
MAGv  = MAG(idx_valid);
RMSEv = RMSE(idx_valid);

%% =========================================================================
% RESUMEN POST-FILTRADO
%% =========================================================================
fprintf('--- RESUMEN DIC POST-FILTRADO ---\n');
fprintf('Ventanas totales:   %d\n', numel(RR(:,1)));
fprintf('Ventanas válidas:   %d  (%.1f %%)\n', ...
        sum(idx_valid), 100*sum(idx_valid)/numel(idx_valid));
fprintf('MAG media válida:   %.3f m\n', mean(MAGv));
fprintf('MAG máxima válida:  %.3f m\n', max(MAGv));
fprintf('RMSE medio válido:  %.3f\n', mean(RMSEv));

%% =========================================================================
% FIGURA 1
%% =========================================================================
figure(1)

% % subplot(2,2,1), imshow(I0,[]), title('Primary image')
% % subplot(2,2,2), imshow(I1,[]), title('Secondary image')
subplot(2,2,1), imshow(I0_vis), title('Primary image')
subplot(2,2,2), imshow(I1_vis), title('Secondary image')

subplot(2,2,3)
scatter(Xv,Yv,20,MAGv,'filled')
set(gca,'YDir','reverse'), axis equal tight
colorbar, caxis([0 5])
title('2D Offset magnitude (m)')

subplot(2,2,4)
quiver(Xv,Yv,Uv,Vv,0)
set(gca,'YDir','reverse'), axis equal tight
title('Displacement vectors (m)')

%% =========================================================================
% FIGURA 2
%% =========================================================================
figure(2)
imshow(I0,[])
hold on
quiver(Xv,Yv,Uv,Vv,0,'b')
set(gca,'YDir','reverse')
title('Primary Image with Displacement Vectors')
hold off

%% =========================================================================
% FIGURA 3
%% =========================================================================
figure(3)
imshow(I0,[])
hold on
scatter(Xv,Yv,20,MAGv,'filled')
set(gca,'YDir','reverse'), axis equal tight
colormap(turbo), colorbar, caxis([0 5])
title('Primary Image with 2D Offset Magnitude (m)')
hold off

%% =========================================================================
% EXPORTACIÓN SIG – VECTORES
%% =========================================================================
[xw,yw] = intrinsicToWorld(R,Xv,Yv);

S = struct([]);
for i=1:numel(xw)
    S(i).Geometry = 'Line';
    S(i).X = [xw(i), xw(i)+Uv(i)];
    S(i).Y = [yw(i), yw(i)+Vv(i)];
    S(i).U = Uv(i);
    S(i).V = Vv(i);
    S(i).MAG = MAGv(i);
    S(i).DIR = atan2d(Vv(i),Uv(i));
    S(i).RMSE = RMSEv(i);
end

shpname = fullfile(OUT,[yourtext '_vectors_valid']);
shapewrite(S,shpname);

crs = projcrs(epsg);
fid = fopen([shpname '.prj'],'w');
fprintf(fid,'%s', wktstring(crs));
fclose(fid);

%% =========================================================================
% EXPORTACIÓN RASTER MAG (malla DIC)
%% =========================================================================
A = size(I0,1);
B = size(I0,2);

MAGgrid = nan(A,B);
ind = sub2ind([A B],Yv,Xv);
MAGgrid(ind) = MAGv;

geotiffwrite(fullfile(OUT,[yourtext '_panel3_offset_mag.tif']), ...
    MAGgrid, R, 'CoordRefSysCode', epsg);

fprintf('Tiempo total ejecución: %.1f s\n', toc(tstart));
fprintf('<<< FIN – newB2n ejecutado correctamente >>>\n');