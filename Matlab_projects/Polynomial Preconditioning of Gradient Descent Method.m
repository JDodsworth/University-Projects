function [xk, k] = polysd(A, b, a, tol, kmax)
% POLYSD: The function implements the Steepest Descent method with
% polynomial preconditioning based on Richardson splitting to solve the
% linear system Ax = b.
% Input: A is a sparse nxn matrix; b is an nx1 column vector; a is a scalar
% that is the Richardson parameter; tol is the tolerance which is compared
% to the normalised residuls. Normalised residuals that are less than the
% tolerance imply convergence of the Steepest Gradient method.
% kmax is the maximum number of steps the Steepest Descent method will
% take to reach convergence
% Output: xk is the solution of the linear system Ax = b found using the
% Steepest Descent method at the kth step; k is the step where the
% Steepest Descent method has reached.

% Any matrix A, whether in sparse form or not, is converted into sparse
% form for computational efficiency.
A = sparse(A);

% Initialise k and xk.
k = 0;
xk = zeros(size(b));

% Obtain the initial residual by applying the norm to the difference of b
% and A * xk.  
r = b - A*xk;
res0 = norm(r);
% res is calculated as a ratio which initially starts at 1 and decreases as
% the Steepeset Gradient method converges. This 'scaled' residual allows
% the comparison against tolerance to be always suitable, otherwise the
% choice of tolerance may be poorly compared against the residuals found 
% from the differences Ax and b.
res = norm(r)/res0;
% Iterate through the Steepest Descent method until either kmax is reached
% or the residual is within the tolerance. 
while k<kmax && res>tol
    % z is found using a local function precond.
    z = precond(A, r, a);
    % alpha represents the step size.
    alpha = (r'*z)/(z'*A*z);
    % The update rule for xk, r, res, and k.
    xk = xk + alpha*z;
    r = b - A*xk;
    res = norm(r)/res0;
    k = k + 1;
end
end

function [z] = precond(A, r, a)
% PRECOND: A function that finds the preconditioning step z based on
% Richardson splitting.
% Input: A is a sparse nxn matrix; r is the updated residual nx1 vector; 
% a is a scalar that is the Richardson parameter.
% Output: z is the preconditioining step nx1 vector

% As required from the task instructions, below is the explicit expression
% of q3(t).
% q3(t) = 4I - 6at + 4a^2t^2 - a^3t^3
% where t is replaced with A and G = I - aA
% The expression G = I - aA is obtained via manipulations of the following
% equations: A = M - N; G = M^(-1)N; M = a^(-1)I - (Richardson splitting)
% We know that p3(G) = q3(A) and that p3(G) = I + G + G^2 + G^3. From these
% results we can obtain q3(t)

% z = P^(-1)r
% P^(-1) = p3(G) M^(-1)
% z = p3(G) M^(-1) r
%   = q3(A) aI r
%   = (4I - 6aA + 4a^2A^2 - a^3A^3) aI r
% The following formulas are used to maximise on computational efficiency
% by applying matrix-vector multiplication throughout the process of
% calculating z
A0r = r;
A1r = A*A0r;
A2r = A*A1r;
A3r = A*A2r;
z = a*4*A0r - a^2*6*A1r + a^3*4*A2r - a^4*A3r;

end
