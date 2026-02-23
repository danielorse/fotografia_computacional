% ============================

% LABORATORIO 1 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================

clear;clc;

%Cuantificador
function x = quant(v,L)
    x = round(v*(L-1)) /(L-1);
end

L = 8;

x = [0:0.01:1];
y = quant(x,L);

figure
plot(x,y,'LineWidth',2)
xlabel('Entrada')
ylabel('Salida')
title('Tabla L=8')

%Dither Hilbert para L

function im = dither_hilbert_L(im,L)

    load ("FC_PROY1/hilbert.mat"); %I,J

    im = im2double(im);
    e = 0;

    for k = 1:length(I)

        i = I(k);
        j = J(k);

        V = im(i,j) + e;

        out = quant(V,L);

        e = V - out;
    
        im(i,j) = out;
    end

end

im = imread('FC_PROY1/imagen.png');
im = im2double(im);

im8 = dither_hilbert_L(im,8);

figure
imshow(im8)
title('Dithering Hilbert L=8')

figure
hist(im8(:),100)
title('Histograma imagen L=8')

im_unit8 = imread('FC_PROY1/imagen.png');
im3 = bitand(im_unit8, 224);

figure
imshow(im3)
title('Imagen con 3 bits')

%RGB332
imc = imread('FC_PROY1/color.jpg');

R = imc(:,:,1);
G = imc(:,:,2);
B = imc(:,:,3);

R = bitand(R, 224);   
G = bitand(G, 224);  
B = bitand(B, 192);   

imc2 = cat(3,R,G,B);
figure
imshow([imc imc2])
title("Imagen y RGB332");