function mask=crea_mask(dims,w)

if nargin==1, w=[90 180]; end 

N=dims(1); M=dims(2); 
wy=w(1); wx=w(2);
  
x=(-M/2+1:M/2)/wx; 
y=(-N/2+1:N/2)'/wy; 
r = sqrt(x.^2 + y.^2);

mask = (r<=1); 
mask=double(mask);

end