function im_corr = corregir(im, F, delta)
    % Normalizamos la imagen al rango [0,1]
    m = min(im(:));
    M = max(im(:));
    im_norm = (im - m) / (M - m);
    % Aplicamos la corrección de brillo y contraste
    im_mod = F * im_norm - delta;
    % Calculamos el  porcentaje de píxeles saturados antes de recortar
    p_neg = 100 * sum(im_mod(:) < 0) / numel(im_mod);
    p_pos = 100 * sum(im_mod(:) > 1) / numel(im_mod);
    fprintf('Pixeles saturados por debajo de 0: %.2f %%\n', p_neg);
    fprintf('Pixeles saturados por encima de 1: %.2f %%\n', p_pos);
    % Recortamos valores al intervalo [0,1]
    im_corr = im_mod;
    im_corr(im_corr < 0) = 0;
    im_corr(im_corr > 1) = 1;
    % Mostramos la imagen corregida
    figure;
    imshow(im_corr);
    set(gcf, 'Name', 'Corrección Brillo-Contraste');
    title(sprintf('Imagen corregida (F = %.2f, \\delta = %.2f)', F, delta));
    % Mostramos el histograma
    figure;
    histogram(im_corr(:));
    xlim([-0.05 1.05]);
    grid on;
    title(sprintf('Histograma corregido (F = %.2f, \\delta = %.2f)', F, delta));
end