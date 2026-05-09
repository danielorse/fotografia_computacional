function im2 = warp_img_trozos(im, iP, zona)

% Dimensiones de la imagen
[N, M, C] = size(im);

% Reservamos la imagen de salida y matrices de coordenadas a interpolar
im2 = zeros(N, M, C);
X = zeros(N, M);
Y = zeros(N, M);

% Recorremos las coordenadas en la imagen de salida
for u = 1:M
    for v = 1:N
        % Consultamos a qué triángulo pertenecen los píxeles
        idx = zona(v, u);
        % Aplicamos transformación inversa
        [x, y] = convertir(u, v, iP{idx});
        X(v, u) = x;
        Y(v, u) = y;
    end
end

% Interpolamos cada plano de color por separado
for c = 1:C
    im2(:,:,c) = interp2(im(:,:,c), X, Y, 'bicubic');
end
end