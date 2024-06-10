function [Q,R] = givensqr(H)
% This file computes the Givens-QR factorisation [Q,R] of 
% a general square upper Hessenberg matrix H.
% Q is an nxn orthogonal matrix.
% R is an nxn upper triangular matrix.

n=size(H,1);
Q=eye(n);
R=H;

% Iterative formula to update Q and R. The unchanged final column is the
% reason the index going up to n-1.

for i=1:n-1
    % Finding the rotation matrix using specfic H entries.
    G=grot(R(i,i),R(i+1,i));
    
    % Updating specific entries in the Q matrix,
    % whilst ignoring zero entries within the ith and i+1th row and
    % the first column up to the i+1th column
    % The reasoning for the transpose of the givens matrix is because the
    % transpose is equivalent to the inverse since G and Q are orthogonal 
    Q(1:i+1,i:i+1)=Q(1:i+1,i:i+1)*G';
    
    % Updating specific entries in the R matrix, 
    % whilst ignoring zero entries within the ith and i+1th row.
    R(i:i+1,i:end)=G*R(i:i+1,i:end);
    end
end

function G=grot(a,b)

% This file computes the Givens rotation matrix G(c)
% corresponding to a vector c=[a;b].

G=[a b;-b a]/norm([a;b]);

end
