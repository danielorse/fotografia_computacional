% Busqueda automatica de F y delta para acercar ambas saturaciones al 1%
    % Normalizamos la imagen al rango [0,1]
    m = min(bw(:));
    M = max(bw(:));
    bw_norm = (bw - m) / (M - m);
    total_pix = numel(bw_norm);

    % Definimos los rangos de búsqueda para los parámetros F y delta (esto se ha hecho para el apartado 3.1 pero puede no aplicar al resto)
    F_vals = 1.2768:0.0002:1.2782;
    delta_vals = 0.0539:0.00005:0.0542;

    % Inicializamos la matriz para almacenar los mejores candidatos
    mejores = zeros(5, 5);
    n_mejores = 0;

    % Hacemos un barrido exhaustivo probando todas las combinaciones de F y delta
    for F = F_vals
        for delta = delta_vals
            % Calculamos la imagen modificada con los parámetros actuales
            bw_mod = F * bw_norm - delta;

            % Calculamos el porcentaje de píxeles saturados (menores a 0 o mayores a 1)
            p_neg = 100 * sum(bw_mod(:) < 0) / total_pix;
            p_pos = 100 * sum(bw_mod(:) > 1) / total_pix;
            % Cuantificamos el error total como desviación desde el 1% óptimo en ambas saturaciones
            error_total = abs(p_neg - 1) + abs(p_pos - 1);

            candidato = [error_total, F, delta, p_neg, p_pos];

            % Mantenemos los 5 mejores candidatos encontrados durante la búsqueda
            if n_mejores < 5
                n_mejores = n_mejores + 1;
                mejores(n_mejores, :) = candidato;
            else
                % Reemplazamos el peor candidato si el actual es mejor
                [peor_error, idx_peor] = max(mejores(:, 1));
                if error_total < peor_error
                    mejores(idx_peor, :) = candidato;
                end
            end
        end
    end

    % Ordenamos los mejores candidatos por error (de menor a mayor)
    mejores = sortrows(mejores(1:n_mejores, :), 1);

    % Mostramos los 5 mejores ajustes encontrados
    fprintf('\nMejores ajustes de brillo-contraste para BW:\n');
    for k = 1:size(mejores, 1)
        fprintf(['%d) F = %.4f, delta = %.5f, ' ...
                 'sat<0 = %.4f %%, sat>1 = %.4f %%, error = %.6f\n'], ...
                 k, mejores(k, 2), mejores(k, 3), ...
                 mejores(k, 4), mejores(k, 5), mejores(k, 1));
    end

    % Extraemos los parámetros óptimos (el mejor de los 5 candidatos)
    F_opt = mejores(1, 2);
    delta_opt = mejores(1, 3);

    fprintf('\nMejor ajuste encontrado: F = %.4f, delta = %.5f\n', F_opt, delta_opt);

    % Aplicamos la mejor combinación encontrada a la imagen original
    bw_corregida = corregir(bw, F_opt, delta_opt);