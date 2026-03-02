im=imread('malla.jpg'); 
[N,M,~]=size(im); 

% Calcular imagen auxiliar aux a partir de im 
aux=rgb2gray(im); G=fspecial('gaussian',15,5); aux=imfilter(aux,G); 

% Bucle para marcar los puntos.
figure(1); imshow(im)
lista={'superior izda ','superior drcha','inferior drcha','inferior izda '};
u=zeros(1,4); v=zeros(1,4);  % vectores para guardar coordenadas esquinas   
for k=1:4  
  fprintf('Pincha esquina %s:',lista{k});  
  [x,y]=ginput(1); 
  
  fprintf('x=%6.1f,y=%6.1f\n',x,y);
  hold on; 
   plot(x,y,'ro','MarkerFaceCol','r','MarkerSize',3); 
   % === modificación del bucle ===
    [x,y]=refinar(x,y,aux);
    fprintf('Coordenadas refinadas: x=%6.1f,y=%6.1f\n',x,y);
   % guardamos coordenadas refinadas
    u(k)=x; v(k)=y;
   % marcamos el punto refinado en verde
    plot(x,y,'go','MarkerFaceCol','g','MarkerSize',5);
   % ===============================
  hold off
   
end


%% Continuar aqu� el script con el resto de los apartados del script

% Calculo de la matriz H
X = [-100, 100, 100, -100];
Y = [  60,  60, -60,  -60];
H = get_proy(X,Y,u,v);
% Mostramos H
fprintf('Matriz H:\n'); vuelca_matriz(H);
% Guardamos lla matriz
save H1 H;

figure(2); imshow(im)
lista2={'superior izda ','superior drcha','inferior drcha','inferior izda '};
u1=zeros(1,4); v1=zeros(1,4);  % vectores para guardar coordenadas esquinas   
for k=1:4  
  fprintf('Pincha esquina %s:',lista2{k});  
  [x,y]=ginput(1); 
  
  fprintf('x=%6.1f,y=%6.1f\n',x,y);
  hold on; 
   plot(x,y,'ro','MarkerFaceCol','r','MarkerSize',3); 
   % === modificación del bucle ===
    [x,y]=refinar(x,y,aux);
    fprintf('Coordenadas refinadas: x=%6.1f,y=%6.1f\n',x,y);
   % guardamos coordenadas refinadas
    u1(k)=x; v1(k)=y;
   % marcamos el punto refinado en verde
    plot(x,y,'go','MarkerFaceCol','g','MarkerSize',5);
   % ===============================
  hold off
end

X1 = [80,100,100,80];
Y1 = [60,60,40,40];

H2 = get_proy(X1,Y1,u1,v1);
% Mostramos H
fprintf('Matriz H2:\n'); vuelca_matriz(H2);
% Guardamos lla matriz
save H2 H2;

% Cargar coordenadas en papel de los 77 puntos de la malla
load malla_XY
%Predecir posiciones (u,v) en la imagen usando H1
load H1
% Construir matriz XY homogénea (3x77)
XY = [X; Y; ones(1, length(X))];
% Proyectar con H1
UVW = H * XY;
% Dividir punto a punto: U/W y V/W
up = UVW(1,:) ./ UVW(3,:); 
vp = UVW(2,:) ./ UVW(3,:);
% Refinar cada uno de los 77 puntos con refinar()
u = zeros(1,77);
v = zeros(1,77); 
for k = 1:77
  [u(k), v(k)] = refinar(up(k), vp(k), aux);
end
% Calcular errores entre predichos y refinados
du = u - up;
dv = v - vp;
d  = sqrt(du.^2 + dv.^2);
fprintf('Distancia media entre predichos y refinados: %.3f píxeles\n', mean(d));
% Plot del vector de distancias
figure;
plot(d, 'b.-');
xlabel('Índice del punto'); ylabel('Distancia (píxeles)');
title('Error de predicción H1 en los 77 cruces');
grid on;
% Visualización de errores como flechas sobre la malla
show_err_malla(du, dv);
% Paso 4: Recalcular H con los 77 puntos
H = get_proy(X, Y, u, v);
fprintf('Nueva matriz H (77 puntos):\n');
vuelca_matriz(H);
% Guardar como H77 para uso en apartados posteriores
save H77 H;





%%  FUNCIONES AUXILIARES A COMPLETAR   %%

function [x,y]=refinar(x,y,aux)
R=50; % Definici�n del tama�o de la zona a explorar
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

 
end

function out=convertir_Rw(in)
Ndata=numel(in);
if Ndata==9  % Conversion R --> w
  R = in; w=zeros(3,1); % Inicializo vector w 
  % Calcula vector de giro w equivalente a matriz R
   
  out=w;  % Asigno w a la salida
else   % Conversion w --> R
  w=in;  
  % Calcula matriz de rotacion R equivalente a vector w

  out = R;  % Asigno R a la salida 
end    

end

function err=error_uv(P,X,Y,u,v)

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


