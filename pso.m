clear all;
close all;
clc;

%% Configuración de PSO
disp('==============================================');
disp('          PSO para funciones f(x,y)');
disp('==============================================');

%% Selección de función de testeo
disp('Funciones disponibles:');
disp('1) Sphere: f(x,y) = x^2 + y^2');
disp('2) Rosenbrock: f(x,y) = 100*(y-x^2)^2 + (1-x)^2');
disp('3) Rastrigin: f(x,y) = 20 + (x^2-10*cos(2*pi*x)) + (y^2-10*cos(2*pi*y))');
disp('4) Ackley: f(x,y) = -20*exp(-0.2*sqrt(0.5*(x^2+y^2))) - exp(0.5*(cos(2*pi*x)+cos(2*pi*y))) + e + 20');
disp('5) Himmelblau: f(x,y) = (x^2+y-11)^2 + (x+y^2-7)^2');
disp('6) Booth: f(x,y) = (x+2*y-7)^2 + (2*x+y-5)^2');

funcion_seleccionada = input('Seleccione función (1-6): ');

% Definir función objetivo según selección
switch funcion_seleccionada
    case 1
        funcion = @(x,y) x.^2 + y.^2;
        nombre_funcion = 'Sphere';
        % Espacio de búsqueda por defecto
        x_min_def = -5; x_max_def = 5;
        y_min_def = -5; y_max_def = 5;
        
    case 2
        funcion = @(x,y) 100*(y - x.^2).^2 + (1 - x).^2;
        nombre_funcion = 'Rosenbrock';
        % Espacio de búsqueda por defecto
        x_min_def = -2; x_max_def = 2;
        y_min_def = -1; y_max_def = 3;
        
    case 3
        funcion = @(x,y) 20 + (x.^2 - 10*cos(2*pi*x)) + (y.^2 - 10*cos(2*pi*y));
        nombre_funcion = 'Rastrigin';
        % Espacio de búsqueda por defecto
        x_min_def = -5.12; x_max_def = 5.12;
        y_min_def = -5.12; y_max_def = 5.12;
        
    case 4
        funcion = @(x,y) -20*exp(-0.2*sqrt(0.5*(x.^2+y.^2))) - ...
                    exp(0.5*(cos(2*pi*x)+cos(2*pi*y))) + exp(1) + 20;
        nombre_funcion = 'Ackley';
        % Espacio de búsqueda por defecto
        x_min_def = -5; x_max_def = 5;
        y_min_def = -5; y_max_def = 5;
        
    case 5
        funcion = @(x,y) (x.^2 + y - 11).^2 + (x + y.^2 - 7).^2;
        nombre_funcion = 'Himmelblau';
        % Espacio de búsqueda por defecto
        x_min_def = -5; x_max_def = 5;
        y_min_def = -5; y_max_def = 5;
        
    case 6
        funcion = @(x,y) (x + 2*y - 7).^2 + (2*x + y - 5).^2;
        nombre_funcion = 'Booth';
        % Espacio de búsqueda por defecto
        x_min_def = -10; x_max_def = 10;
        y_min_def = -10; y_max_def = 10;
        
    otherwise
        error('Selección no válida');
end

%% Parámetros del usuario
disp(' ');
disp('----------------------------------------------');
disp('Parámetros de entrada:');

% Número de partículas
n_particulas = input('Número de partículas (recomendado: 20-50): ');
if isempty(n_particulas)
    n_particulas = 30;
end

% Número de iteraciones
max_iter = input('Número de iteraciones (recomendado: 50-200): ');
if isempty(max_iter)
    max_iter = 100;
end

% Espacio de búsqueda
disp(' ');
disp('Espacio de búsqueda [x_min, x_max], [y_min, y_max]');
disp(['Valores por defecto para ' nombre_funcion ':']);
disp(['x: [' num2str(x_min_def) ', ' num2str(x_max_def) ']']);
disp(['y: [' num2str(y_min_def) ', ' num2str(y_max_def) ']']);
disp(' ');

respuesta = input('¿Usar valores por defecto? (s/n): ', 's');
if strcmpi(respuesta, 's') || isempty(respuesta)
    x_min = x_min_def; x_max = x_max_def;
    y_min = y_min_def; y_max = y_max_def;
else
    x_min = input('x_min: ');
    x_max = input('x_max: ');
    y_min = input('y_min: ');
    y_max = input('y_max: ');
end

%% Parámetros PSO
w = 0.729;       % Inercia
c1 = 1.49445;    % Factor cognitivo
c2 = 1.49445;    % Factor social

%% Inicialización
% Inicializar posiciones y velocidades
posiciones = zeros(n_particulas, 2);
velocidades = zeros(n_particulas, 2);
mejor_pos_particula = zeros(n_particulas, 2);
mejor_valor_particula = inf(n_particulas, 1);

% Mejor global
mejor_pos_global = zeros(1, 2);
mejor_valor_global = inf;

% Inicializar aleatoriamente
for i = 1:n_particulas
    posiciones(i, 1) = x_min + (x_max - x_min) * rand();
    posiciones(i, 2) = y_min + (y_max - y_min) * rand();
    
    velocidades(i, 1) = 0.1 * (x_max - x_min) * (2*rand() - 1);
    velocidades(i, 2) = 0.1 * (y_max - y_min) * (2*rand() - 1);
    
    % Evaluar función
    valor_actual = funcion(posiciones(i, 1), posiciones(i, 2));
    
    % Mejor personal
    mejor_pos_particula(i, :) = posiciones(i, :);
    mejor_valor_particula(i) = valor_actual;
    
    % Mejor global
    if valor_actual < mejor_valor_global
        mejor_valor_global = valor_actual;
        mejor_pos_global = posiciones(i, :);
    end
end

%% Historial para gráficas
historial_mejor_valor = zeros(max_iter, 1);
historial_mejor_pos = zeros(max_iter, 2);
historial_promedio_valor = zeros(max_iter, 1);

%% Algoritmo PSO principal
disp(' ');
disp('----------------------------------------------');
disp('Ejecutando algoritmo PSO...');

for iter = 1:max_iter
    % Actualizar cada partícula
    for i = 1:n_particulas
        % Actualizar velocidad
        r1 = rand();
        r2 = rand();
        
        % Componente cognitiva
        cognitivo = c1 * r1 * (mejor_pos_particula(i, :) - posiciones(i, :));
        
        % Componente social
        social = c2 * r2 * (mejor_pos_global - posiciones(i, :));
        
        % Nueva velocidad
        velocidades(i, :) = w * velocidades(i, :) + cognitivo + social;
        
        % Actualizar posición
        posiciones(i, :) = posiciones(i, :) + velocidades(i, :);
        
        % Mantener dentro de los límites
        posiciones(i, 1) = min(max(posiciones(i, 1), x_min), x_max);
        posiciones(i, 2) = min(max(posiciones(i, 2), y_min), y_max);
        
        % Evaluar función
        valor_actual = funcion(posiciones(i, 1), posiciones(i, 2));
        
        % Actualizar mejor personal
        if valor_actual < mejor_valor_particula(i)
            mejor_valor_particula(i) = valor_actual;
            mejor_pos_particula(i, :) = posiciones(i, :);
            
            % Actualizar mejor global
            if valor_actual < mejor_valor_global
                mejor_valor_global = valor_actual;
                mejor_pos_global = posiciones(i, :);
            end
        end
    end
    
    % Guardar historial
    historial_mejor_valor(iter) = mejor_valor_global;
    historial_mejor_pos(iter, :) = mejor_pos_global;
    
    % Calcular promedio de valores
    valores_iteracion = zeros(n_particulas, 1);
    for i = 1:n_particulas
        valores_iteracion(i) = funcion(posiciones(i, 1), posiciones(i, 2));
    end
    historial_promedio_valor(iter) = mean(valores_iteracion);
    
    % Mostrar progreso cada 10 iteraciones
    if mod(iter, 10) == 0 || iter == 1 || iter == max_iter
        fprintf('Iteración %3d: Mejor valor = %.6e en (%.4f, %.4f)\n', ...
                iter, mejor_valor_global, mejor_pos_global(1), mejor_pos_global(2));
    end
end

%% Resultados
disp('----------------------------------------------');
disp('RESULTADOS:');
disp('==============================================');
fprintf('Función: %s\n', nombre_funcion);
fprintf('Mejor solución encontrada:\n');
fprintf('x = %.6f\n', mejor_pos_global(1));
fprintf('y = %.6f\n', mejor_pos_global(2));
fprintf('f(x,y) = %.6e\n', mejor_valor_global);
fprintf('\nParámetros utilizados:\n');
fprintf('Número de partículas: %d\n', n_particulas);
fprintf('Iteraciones: %d\n', max_iter);
fprintf('Espacio de búsqueda: x ∈ [%.2f, %.2f], y ∈ [%.2f, %.2f]\n', ...
        x_min, x_max, y_min, y_max);

%% Gráficas
disp(' ');
disp('Generando gráficas...');

% Configurar tamaño de figuras
figure('Position', [100, 100, 1200, 800]);

% 1. Convergencia
subplot(2, 2, 1);
plot(1:max_iter, historial_mejor_valor, 'b-', 'LineWidth', 2);
hold on;
plot(1:max_iter, historial_promedio_valor, 'r--', 'LineWidth', 1.5);
grid on;
xlabel('Iteración');
ylabel('Valor de la función');
title(['Convergencia PSO - ' nombre_funcion]);
legend('Mejor valor', 'Valor promedio', 'Location', 'northeast');
set(gca, 'YScale', 'log');

% 2. Espacio de búsqueda y trayectorias
subplot(2, 2, 2);
% Crear malla para contornos
[x_grid, y_grid] = meshgrid(linspace(x_min, x_max, 100), ...
                           linspace(y_min, y_max, 100));
z_grid = funcion(x_grid, y_grid);

% Contornos
contourf(x_grid, y_grid, z_grid, 50);
hold on;
colorbar;

% Posiciones finales de partículas
scatter(posiciones(:,1), posiciones(:,2), 40, 'r', 'filled', 'MarkerEdgeColor', 'k');
scatter(mejor_pos_global(1), mejor_pos_global(2), 100, 'y', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);

% Trayectoria del mejor global
plot(historial_mejor_pos(:,1), historial_mejor_pos(:,2), 'w-', 'LineWidth', 1.5);

xlabel('x');
ylabel('y');
title('Espacio de búsqueda y partículas');
xlim([x_min, x_max]);
ylim([y_min, y_max]);
legend('Función', 'Partículas', 'Mejor solución', 'Trayectoria mejor');

% 3. Distribución 3D
subplot(2, 2, [3, 4]);
surf(x_grid, y_grid, z_grid, 'EdgeColor', 'none', 'FaceAlpha', 0.7);
hold on;

% Partículas en 3D
z_particulas = funcion(posiciones(:,1), posiciones(:,2));
scatter3(posiciones(:,1), posiciones(:,2), z_particulas, 60, 'r', 'filled');

% Mejor solución en 3D
scatter3(mejor_pos_global(1), mejor_pos_global(2), mejor_valor_global, ...
         100, 'y', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);

% Trayectoria del mejor en 3D
z_trayectoria = funcion(historial_mejor_pos(:,1), historial_mejor_pos(:,2));
plot3(historial_mejor_pos(:,1), historial_mejor_pos(:,2), z_trayectoria, ...
      'w-', 'LineWidth', 2);

xlabel('x');
ylabel('y');
zlabel('f(x,y)');
title(['Superficie 3D - ' nombre_funcion]);
grid on;
rotate3d on;

%% Guardar gráfica como PNG
nombre_archivo = sprintf('pso_resultados_%s_p%d_i%d.png', ...
                        lower(nombre_funcion), n_particulas, max_iter);
print(gcf, nombre_archivo, '-dpng', '-r300');
fprintf('\nGráfica guardada como: %s\n', nombre_archivo);

%% Guardar datos en archivo de texto
datos_archivo = sprintf('pso_datos_%s_p%d_i%d.txt', ...
                       lower(nombre_funcion), n_particulas, max_iter);
fid = fopen(datos_archivo, 'w');
fprintf(fid, 'Resultados PSO - %s\n', nombre_funcion);
fprintf(fid, '========================================\n');
fprintf(fid, 'Fecha: %s\n', datestr(now()));
fprintf(fid, '\nParámetros:\n');
fprintf(fid, '  Número de partículas: %d\n', n_particulas);
fprintf(fid, '  Iteraciones: %d\n', max_iter);
fprintf(fid, '  Espacio de búsqueda: x ∈ [%.2f, %.2f], y ∈ [%.2f, %.2f]\n', ...
        x_min, x_max, y_min, y_max);
fprintf(fid, '  Inercia (w): %.3f\n', w);
fprintf(fid, '  Factor cognitivo (c1): %.3f\n', c1);
fprintf(fid, '  Factor social (c2): %.3f\n', c2);
fprintf(fid, '\nResultados:\n');
fprintf(fid, '  Mejor x: %.6f\n', mejor_pos_global(1));
fprintf(fid, '  Mejor y: %.6f\n', mejor_pos_global(2));
fprintf(fid, '  Mejor f(x,y): %.6e\n', mejor_valor_global);
fprintf(fid, '\nHistorial de convergencia (últimas 10 iteraciones):\n');
fprintf(fid, 'Iteración\tMejor valor\t\tx\t\ty\n');
for i = max(1, max_iter-9):max_iter
    fprintf(fid, '%d\t\t%.6e\t%.6f\t%.6f\n', i, ...
            historial_mejor_valor(i), historial_mejor_pos(i,1), historial_mejor_pos(i,2));
end
fclose(fid);

fprintf('Datos guardados en: %s\n', datos_archivo);
disp('==============================================');
disp('Ejecución completada exitosamente.');
