function ver_lap(p)

figure('Name','Piramide Laplaciana'); 

L=length(p);  [N,M,Nc]=size(p{1});

res=zeros(N,M,Nc);

dx=0; dy=0;
for k=1:L
  nivel=p{k};
  if k<L, nivel=0.5+2*nivel; end
  nivel([1 2 N-1 N],:,1:2)=0; nivel(:,[1 2 M-1 M],1:2)=0;
  nivel([1 2 N-1 N],:,3)=1; nivel(:,[1 2 M-1 M],3)=1;
  res((1:N)+dy,(1:M)+dx,:)=nivel;
  N=N/2; M=M/2;
end

imshow(res);

end
