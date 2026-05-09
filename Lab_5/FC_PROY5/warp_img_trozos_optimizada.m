function im2 = warp_img_trozos_optimizada(im, iP, zona)

% Dimensiones de la imagen
[N, M, C] = size(im);

% Reservamos las matrices de coordenadas a interpolar
X = zeros(N, M);
Y = zeros(N, M);

NT = length(iP);

% Recorremos los triángulos de la imagen de salida
for k = 1:NT
    % Consultamos qué píxeles pertenecen al triángulo
    pt = find(zona == k);

    if isempty(pt), continue; end

    % Convertimos índices lineales a coordenadas de imagen
    [v, u] = ind2sub(size(zona), pt');

    % Aplicamos transformación inversa
    [x, y] = convertir(u, v, iP{k});

    X(pt) = x;
    Y(pt) = y;
end

% Interpolamos cada plano de color por separado
im2 = zeros(N, M, C);
for c = 1:C
    im2(:,:,c) = interp2(im(:,:,c), X, Y, 'bicubic');
end

end
