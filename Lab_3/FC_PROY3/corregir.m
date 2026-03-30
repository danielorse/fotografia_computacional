function im_corr = corregir(im, F, delta)
% Normalizamos la imagen al rango [0,1]
m = min(im(:));
M = max(im(:));
im_norm = (im - m) / (M - m);
% Aplicamos la corrección de brillo y contraste
im_mod = F * im_norm - delta;
% Calculamos el  porcentaje de píxeles saturados antes de recortar
% (Cambios)
[Mdim, Ndim, ~] = size(im_mod);

sat_neg = any(im_mod < 0, 3);
sat_pos = any(im_mod > 1, 3);

p_neg = 100 * sum(sat_neg(:)) / (Mdim * Ndim);
p_pos = 100 * sum(sat_pos(:)) / (Mdim * Ndim);
fprintf('Pixeles saturados por debajo de 0: %.4f %%\n', p_neg);
fprintf('Pixeles saturados por encima de 1: %.4f %%\n', p_pos);
% Recortamos valores al intervalo [0,1]
im_corr = im_mod;
im_corr(im_corr < 0) = 0;
im_corr(im_corr > 1) = 1;
% Mostramos la imagen corregida
figure;
imshow(im_corr);
set(gcf, 'Name', 'Corrección Brillo-Contraste');
title(sprintf('Imagen corregida (F = %.4f, \\delta = %.4f)', F, delta));
% Mostramos el histograma
figure;
histogram(im_corr(:));
xlim([-0.05 1.05]);
grid on;
title(sprintf('Histograma corregido (F = %.4f, \\delta = %.4f)', F, delta));
end