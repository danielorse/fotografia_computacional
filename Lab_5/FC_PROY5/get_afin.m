function P=get_afin(x,y,u,v)
x=x'; y=y'; u=u'; v=v';
z=0*x; unos=x.^0; % 0's y 1's
M = [x y unos z z z; 
     z z z x y unos];
uv=[u;v]; sol= M\uv;
P = [sol(1:3)'; sol(4:6)'; 0 0 1];
end