%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_pixel_offset_PARTVII_newB3.m
%
% OBJETIVO:
% - Análisis estadístico robusto de resultados DIC (MAG, RMSE)
% - Histogramas simultáneos
% - Figuras MATLAB interpretativas
% - Exportación de figuras con world files (TFW) para ArcGIS
%
% REQUIERE:
%   Resultados previos de run_pixel_offset_PARTVII_newB2n.m en workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ================== COMPROBACIÓN BÁSICA =================================
vars_req = {'Xv','Yv','Uv','Vv','MAGv','RMSEv','I0','R','yourtext'};
for k=1:numel(vars_req)
    assert(exist(vars_req{k},'var')==1, ...
        ['Falta la variable ',vars_req{k},'. Ejecuta antes newB2n.']);
end

OUT = 'D:\Jijona\jijona\modificación_02_1_26\DIC\Output';

%% ================== FUNCIÓN LOCAL PARA TFW =============================
write_tfw = @(fname,R) ...
    ( ...
    fclose( ...
    fopen(fname,'w') ...
    ) );

% redefinimos de forma correcta
function write_tfw_file(fname, R)
    A = R.CellExtentInWorldX;
    D = 0;
    B = 0;
    E = -R.CellExtentInWorldY;
    C = R.XWorldLimits(1) + A/2;
    F = R.YWorldLimits(2) - abs(E)/2;

    fid = fopen(fname,'w');
    fprintf(fid,'%.8f\n',A);
    fprintf(fid,'%.8f\n',D);
    fprintf(fid,'%.8f\n',B);
    fprintf(fid,'%.8f\n',E);
    fprintf(fid,'%.8f\n',C);
    fprintf(fid,'%.8f\n',F);
    fclose(fid);
end

%% =======================================================================
% 1. HISTOGRAMAS
%% =======================================================================

%% --- Histograma MAG (lineal)
figure(4)
histogram(MAGv,60)
xlabel('MAG (m)')
ylabel('Frecuencia')
title('Histograma de magnitud DIC (MAG)')
grid on

%% --- Histograma MAG (log)
figure(5)
histogram(log10(MAGv),60)
xlabel('log10(MAG)')
ylabel('Frecuencia')
title('Histograma logarítmico de MAG')
grid on

%% --- Histograma RMSE
figure(6)
histogram(RMSEv,60)
xlabel('RMSE')
ylabel('Frecuencia')
title('Histograma de calidad de correlación (RMSE)')
grid on

%% --- MAG vs RMSE
figure(7)
scatter(RMSEv, MAGv, 8, MAGv, 'filled')
xlabel('RMSE')
ylabel('MAG (m)')
title('Relación MAG – RMSE')
colorbar
grid on

%% =======================================================================
% 2. FIGURAS INTERPRETATIVAS
%% =======================================================================

%% --- Figura 4: SOLO vectores
figure(8)
quiver(Xv,Yv,Uv,Vv,0,'k')
set(gca,'YDir','reverse')
axis equal tight
title('Displacement vectors (only)')
grid on

exportgraphics(gcf, ...
    fullfile(OUT,[yourtext '_Fig4_vectors_only.png']), ...
    'Resolution',300)
write_tfw_file( ...
    fullfile(OUT,[yourtext '_Fig4_vectors_only.tfw']), R);

%% --- Figura 5: SOLO magnitud (MAG)
figure(9)
scatter(Xv,Yv,20,MAGv,'filled')
set(gca,'YDir','reverse')
axis equal tight
colormap(turbo)
caxis([0 5])
colorbar
title('2D Offset magnitude (m)')
grid on

exportgraphics(gcf, ...
    fullfile(OUT,[yourtext '_Fig5_offset_mag.png']), ...
    'Resolution',300)
write_tfw_file( ...
    fullfile(OUT,[yourtext '_Fig5_offset_mag.tfw']), R);

%% --- Figura 6: MAG dominante (percentil 95)
p95 = prctile(MAGv,95);

figure(10)
scatter(Xv(MAGv<=p95),Yv(MAGv<=p95),20,MAGv(MAGv<=p95),'filled')
set(gca,'YDir','reverse')
axis equal tight
colormap(turbo)
caxis([0 p95])
colorbar
title(['Offset magnitude <= P95 (',num2str(p95,'%.2f'),' m)'])
grid on

exportgraphics(gcf, ...
    fullfile(OUT,[yourtext '_Fig6_offset_mag_P95.png']), ...
    'Resolution',300)
write_tfw_file( ...
    fullfile(OUT,[yourtext '_Fig6_offset_mag_P95.tfw']), R);

%% =======================================================================
% 3. ESTADÍSTICOS ROBUSTOS (CONSOLA)
%% =======================================================================

fprintf('--- ESTADÍSTICOS ROBUSTOS DIC ---\n');
fprintf('MAG media:       %.3f m\n', mean(MAGv));
fprintf('MAG mediana:     %.3f m\n', median(MAGv));
fprintf('MAG P90:         %.3f m\n', prctile(MAGv,90));
fprintf('MAG P95:         %.3f m\n', prctile(MAGv,95));
fprintf('MAG P98:         %.3f m\n', prctile(MAGv,98));
fprintf('MAG máxima:      %.3f m\n', max(MAGv));
fprintf('RMSE medio:      %.3f\n', mean(RMSEv));
fprintf('RMSE P95:        %.3f\n', prctile(RMSEv,95));

fprintf('<<< FIN – newB3 ejecutado correctamente >>>\n');