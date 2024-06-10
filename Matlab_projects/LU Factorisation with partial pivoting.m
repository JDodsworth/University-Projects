function [x,bn] = luppsolve(A,b)
% LUPPSOLVE: This function solves Ax = b by using an LU factorisation with 
% partial pivoting where:
% x is the solution vector, nx1, an output variable.
% bn is the pivotted b, nx1, an output variable.
% A is a dense non-singular square matrix, nxn, an input variable.
% b is a dense vector, nx1, an input variable.
 
n = size(A);
U = A;
L = eye(n);
bn = b;

% Iterative formula to first pivot rows, then to apply LU factoristaion.
% No swaps will occur in the last column because the the entry will be
% maximum. Therefore, iteration only has to go up to n-1.
for k = 1:n-1
    
    % Assigning a variable that represents the absolute maximum entry in 
    % the kth column. 
    [~, max_entry_row_index] = max(abs(U(k:n, k)));
    % Re-indexing to make it in accordance with the full height of the
    % matrix n.
    max_entry_row_index = max_entry_row_index + k - 1;
    
    % Pivotting rows within matrix U and L which initially is A and an 
    % identity matrix respectively.
    U([k, max_entry_row_index], k:n) = U([max_entry_row_index, k], k:n);
    L([k, max_entry_row_index],1:k-1) = L([max_entry_row_index, k],1:k-1);
    % Pivotting entries within bn in accordance with absolute maximum entry
    % in U.
    bn([k, max_entry_row_index]) = bn([max_entry_row_index, k]);
   
    % The below implementation is an amended section of the 1.5 algorithm 
    % seen in lecture notes. Equally, this implementation is an amended 
    % section of ludecomp function created by Daniel Loghin.
    for j=k+1:n
        % The iteration updates the matrix L entry-wise.
        L(j,k)=U(j,k)/U(k,k);
        % The iteration updates bn vector.
        bn(j)=bn(j)-L(j,k)*bn(k);
        % The iteration updates the matrix U entry-wise. 
        U(j,:)=U(j,:)-L(j,k)*U(k,:);
        % This update within one loop is highly computationally efficient.
    end
end

% Calculating x below with the following function.
x = backward_substitution(U,bn);

end

function x = backward_substitution(U,y)

% BACKWARD_SUBSTITUTION: This function file computes the solution of Ux=y
% using the backward substitution algorithm.
% Input: square upper triangular matrix U, column vector y.
% Output: solution x of linear system Ux=y.
% This function is influenced by the function found in lab 3 on Canvas.

[n,~] = size(U);
x = zeros(n,1);

for i = n:-1:1
    x(i) = (y(i) - U(i,i+1:n) * x(i+1:n)) / U(i,i);    
end
end
