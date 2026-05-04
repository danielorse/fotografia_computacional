function [u,v] = convertir(x,y,P)
x = x(:)';
y = y(:)';

X = [x; y; ones(1,length(x))];

U = P * X;

u = U(1,:) ./ U(3,:);
v = U(2,:) ./ U(3,:);
end
