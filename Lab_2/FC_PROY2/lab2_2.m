clear;clc;
im = imread('fotomovil.jpeg');
[N,M,~]=size(im);
aux=rgb2gray(im); G=fspecial('gaussian',15,5); aux=imfilter(aux,G);figure(1); imshow(im)
lista={'superior izda ','superior drcha','inferior drcha','inferior izda '};
u=zeros(1,4); v=zeros(1,4);
for k=1:4
    fprintf('Pincha esquina %s:',lista{k});
    [x,y]=ginput(1);
    fprintf('x=%6.1f,y=%6.1f\n',x,y);
    hold on;
    plot(x,y,'ro','MarkerFaceCol','r','MarkerSize',3);
    [x,y]=refinar(x,y,aux);
    fprintf('Coordenadas refinadas: x=%6.1f,y=%6.1f\n',x,y);
    u(k)=x; v(k)=y;
    plot(x,y,'go','MarkerFaceCol','g','MarkerSize',5);
    hold off
end

X = [-100 100 100 -100];
Y = [  60  60 -60  -60];

H = get_proy(X,Y,u,v);

fprintf('Matriz H:\n');
vuelca_matriz(H);

load malla_XY
Xm = X;
Ym = Y;
XY = [Xm;Ym;ones(1,length(Xm))];
UVW = H*XY;
up = UVW(1,:)./UVW(3,:);
vp = UVW(2,:)./UVW(3,:);

u=zeros(1,77);
v=zeros(1,77);
for k=1:77
    [u(k),v(k)] = refinar(up(k),vp(k),aux);
end

du = u-up;
dv = v-vp;

d = sqrt(du.^2+dv.^2);

fprintf('Distancia media: %.3f px\n',mean(d));

figure
plot(d,'.-')
grid on
title('Error homografia')

show_err_malla(du,dv)

H =  get_proy(Xm,Ym,u,v);

fprintf('Nueva matriz H77:\n');
vuelca_matriz(H);

save H77 H

[f,R,X0] = get_data_from_H(H);

w = convertir_Rw(R);

P0 = [w;X0;f];

err = error_uv(P0,Xm,Ym,u,v);

norm_err = norm(err);

fprintf('Error inicial: %.3f\n',norm_err);

du0 = u - up;
dv0 = v - vp;

show_err_malla(du0,dv0)
title('Errores iniciales')

opts = optimset('Algorithm','levenberg-marquardt','Display','off');

f_min = @(P) error_uv(P,Xm,Ym,u,v);

P_opt = lsqnonlin(f_min,P0,[],[],opts);

w_opt  = P_opt(1:3);
X0_opt = P_opt(4:6);
f_opt  = P_opt(7);

fprintf('Focal optimizada: %.3f px\n',f_opt);

err_opt = error_uv(P_opt,Xm,Ym,u,v);

norm_err_opt = norm(err_opt);

fprintf('Error optimizado: %.3f\n',norm_err_opt);

du_opt = err_opt(1:77);
dv_opt = err_opt(78:154);

show_err_malla(du_opt,dv_opt)
title('Errores optimizados')

k1_0 = 0;

P0_k1 = [w;X0;f;k1_0];

P_opt_k1 = lsqnonlin(f_min,P0_k1,[],[],opts);

w_k1  = P_opt_k1(1:3);
X0_k1 = P_opt_k1(4:6);
f_k1  = P_opt_k1(7);
k1    = P_opt_k1(8);

fprintf('k1 = %.6f\n',k1);

err_k1 = error_uv(P_opt_k1,Xm,Ym,u,v);

norm_err_k1 = norm(err_k1);

fprintf('Error con distorsion: %.3f\n',norm_err_k1);

du_k1 = err_k1(1:77);
dv_k1 = err_k1(78:154);

show_err_malla(du_k1,dv_k1)
title('Errores con distorsion')

sensor_width = 8.2;   % mm de la camara

px_mm = M / sensor_width;

f_mm = f_opt / px_mm;

fprintf('Focal estimada: %.3f mm\n',f_mm);

dist = norm(X0_opt);

fprintf('Distancia camara-centro malla: %.2f mm\n',dist);

%%  FUNCIONES AUXILIARES A COMPLETAR   %%

function [x,y]=refinar(x,y,aux)
R=25; % Definici�n del tama�o de la zona a explorar
rr=(-R:R); cx=ones(length(rr),1)*rr; cy=cx';

% redondeamos las coordenadas iniciales X, Y
x=round(x);
y=round(y);
% extraemos subimagen s
s = aux(y-R:y+R,x-R:x+R);
% Convertimos s a double y calculamos su valor minimo
s = double(s);
m = min(s(:));
% Diferencias respecto al valor minimo
d = abs(s - m);
% Calculamos pesos y obtenemos matriz de pesos
w = exp(-d);
w = w/sum(w(:));
% Calculamos el desplazamiento
x = x + sum(sum(cx.*w));
y = y + sum(sum(cy.*w));

end

function [f,R,X0]=get_data_from_H(H)
% Definir valores de u0, v0
im=imread('fotomovil.jpeg');
[N,M,~]=size(im);
u0 = M/2;
v0 = N/2;
fprintf('Usamos u0=%1.f, v0=%.1f   (px)\n', u0, v0);
% Construimos la matriz B
B = [1 0 -u0; 0 1 -v0; -u0 -v0 (u0^2 + v0^2)];
% Obtenemos las dos primeras columnas de la matriz H y (H31 H32 H33)
h1 = H(:,1);
h2 = H(:,2);
H31 = H(3,1); H32 = H(3,2); H33 = H(3,3);
% Calculamos f
numerador = -(h1.' * B * h2);
denominador = (H31 * H32 * H33);
f = sqrt(numerador / denominador);
fprintf('La f local que obtenemos es: f = %.2f px\n', f);

% Calculamos K
K = [f 0 u0;0 f v0; 0 0 1];
Q = K \ H; % Calculamos Q = K^-1 * H
fprintf('Matriz Q:\n');
vuelca_matriz(Q);
fprintf('\n');

% Extraemos r1, r2 y t
r1 = Q(:,1);
r2 = Q(:,2);
t = Q(:,3);
% Calculamos sus normas
n1 = norm(r1);
n2 = norm(r2);
lambda = sqrt(n1*n2);
% Corregir escala
r1 = r1 / lambda;
r2 = r2 / lambda;
t  = t  / lambda;
% fprintf('n1 = %.6f\n', n1);
% fprintf('n2 = %.6f\n', n2);
% fprintf('lambda = %.6f\n', lambda);
% fprintf('r1 corregido:\n'); disp(r1);
% fprintf('r2 corregido:\n'); disp(r2);
% fprintf('t corregido:\n');  disp(t);

% Tercera columna de R y construcción de R
r3 = cross(r1, r2);
R  = [r1 r2 r3];
fprintf('Matriz R :\n');
disp(R);

% Comprobamos los resultados de R*R' y R'*R
Ident = eye(3);
M1 = R*R'; M2 = R'*R;
% fprintf('R*R'' =\n'); disp(M1);
% fprintf('R''*R =\n'); disp(M2);
Dif1 = M1 - Ident;
Dif2 = M2 - Ident;
% fprintf('||R''R - I|| = \n'); disp(Dif1);
% fprintf('||RR'' - I|| = \n'); disp(Dif2);

% Despejamos X0 a partir de R y t
X0 = -R' * t;

end

function out=convertir_Rw(in)

Ndata=numel(in);

if Ndata==9   % Conversion R --> w

    R = in;

    theta = acos((trace(R)-1)/2);

    if abs(theta) < 1e-10
        w = [0;0;0];
    else
        wx = (R(3,2)-R(2,3))/(2*sin(theta));
        wy = (R(1,3)-R(3,1))/(2*sin(theta));
        wz = (R(2,1)-R(1,2))/(2*sin(theta));

        w = theta * [wx; wy; wz];
    end

    out = w;

else   % Conversion w --> R

    w = in;

    theta = norm(w);

    if theta < 1e-10
        R = eye(3);
    else

        k = w/theta;

        K = [  0    -k(3)  k(2);
            k(3)   0    -k(1);
            -k(2)  k(1)   0   ];

        R = eye(3) + sin(theta)*K + (1-cos(theta))*(K*K);

    end

    out = R;

end
end

function err=error_uv(P,X,Y,u,v)

% Reservar vectores
N = length(u);
up = zeros(1,N);
vp = zeros(1,N);

% Extraer parametros
w  = P(1:3);
X0 = P(4:6);
f  = P(7);

if numel(P) >= 8
    k1 = P(8);
else
    k1 = 0;
end
% Obtener matriz de rotacion
R = convertir_Rw(w);

% Vector traslacion
t = -R*X0;

% Matriz Q
Q = [R(:,1) R(:,2) t];

% Coordenadas homogeneas del plano
XY = [X; Y; ones(1,N)];

% Coordenadas en camara
XYZ_cam = Q * XY;

Xcam = XYZ_cam(1,:);
Ycam = XYZ_cam(2,:);
Zcam = XYZ_cam(3,:);

% Coordenadas normalizadas
xn = Xcam ./ Zcam;
yn = Ycam ./ Zcam;

r2 = xn.^2 + yn.^2;

xn = xn .* (1 + k1 * r2);
yn = yn .* (1 + k1 * r2);

% centro imagen
im = imread('fotomovil.jpeg');
[Nim,Mim,~] = size(im);

u0 = Mim/2;
v0 = Nim/2;

% pasar a pixeles
up = u0 + f * xn;
vp = v0 + f * yn;

% errores
du = u - up;
dv = v - vp;

% vector error
err = [du dv]';

end

%% FUNCIONES AUXILIARES PARA USAR (NO MODIFICAR)

% Vuelca valores de una matriz 3x3
function vuelca_matriz(H)
fprintf('%7.3f %7.3f %8.2f\n',H');
end

% Pintar malla + errores en los nodos como flechas
function show_err_malla(du,dv,S)
if nargin==2, S=1; end

s=sqrt(du.^2+dv.^2); s=mean(s);

figure;
hold off
for k=1:11, plot([k k],[0.5 7.5],'b'); hold on; end
for k=1:7, plot([0.5 11.5],[k k],'b'); hold on; end

du=flipud(reshape(du/s,11,7)');
dv=-flipud(reshape(dv/s,11,7)');
quiver(du,dv,(s/20)*S,'r','LineWidth',2)
hold off
xlim([0 12]); ylim([0 8])

end


