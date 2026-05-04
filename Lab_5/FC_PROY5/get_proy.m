function P=get_proy(x,y,u,v)

x=x'; y=y'; u=u'; v=v';
z=0*x; unos=x.^0; % 0's y 1's

M = [x y unos z z z -u.*x -u.*y; 
     z z z x y unos -v.*x -v.*y];

uv=[u;v]; 
sol= M\uv;

P = [sol(1:3)'; 
     sol(4:6)'; 
     sol(7:8)' 1];

end