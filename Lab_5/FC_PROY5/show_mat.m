function show_mat(A)
fprintf('Matriz:\n');
if numel(A)==9
  fprintf('%7.4f %7.4f %7.2f\n',A')
else
  fprintf('%7.2f %7.4f %7.4f %8.5f\n',A')  
end
end