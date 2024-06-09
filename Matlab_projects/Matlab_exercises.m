%I Vectors: operations and manipulations
%Key commands: colon,linspace,fliplr,flipud,reshape,sort,find,mod

%Q1: Regular vectors (1)
%Generate the row vector a with 50 evenly-spaced elements starting at  and ending at . No loops.
%Edit the line below to generate the vector a. 
a=linspace(sqrt(2),asinh(pi),50);

%Q2: Regular vectors (2)
%Generate the column vector b of length 51 with entries . No loops and no manual entry of all the elements of b.
%Edit the line below to generate the vector b. 
b = (mod(1:51, 2));
b = (b - 1) * -6 + 2;
b = b';

%Q3: Vectorised operations
%Generate the row vector c of length 50 with entries given by the reciprocals of the squares of the entries of the vector a in Q1. No loops and no manual entry of all the elements of c.
%Edit the line below to generate the vector c. 
c = (a.*a).^(-1);

%Q4: Extracting vectors
%Find the sub-vector d of the vector a in Q1 containing all the entries less than  in decreasing order. No loops.
%Edit the line below to generate the vector d. 
d=sort(a(find(a < pi/2)), 'descend');

%Q5: Swapping entries
rng(5);e=randn(1e4,1);%---> SETUP: do not edit
%Generate the column vector ee with the same entries as e defined in the above line, except for the first and last entries, which should be swapped over.
%Edit the line below to generate the vector ee.
ee=e;
ee(1,1) = e(end,end);
ee(end,end) = e(1,1);

%Q6: Outer products
%rng(6);y=randi(10,40,1);z=randi(10,60,1);%---> SETUP: do not edit
%Use the loop provided to implement the outer product F of the column vectors y and z (in that order) defined above. You should construct  by stacking up rows.
%Edit the lines below to generate the outer product F of column vectors y and z
F=[];
for i=1:1:length(y)
    irow = y(i) * z.';
    F = [F; irow];
end


%Q7: Reshaping vectors
%By generating a certain vector g, use the reshape command to generate the structured matrix G given below:

%Edit the line below to generate the matrix G (by reshaping the vector g)
g= [296:-5:1];
G=reshape(g,6,10);

%Q8: Finding entries in a vector
%rng(8);h=randn(1e4,1);%---> SETUP: do not edit
%Find the third largest entry hmax3 in the vector h defined above.
%Edit the line below to generate the third largest entry in h.
h=flipud(sort(h));
hmax3=h(3);

%Q9: Tiling vectors. 
%Let u be the first column of the structured matrix indicated below:

%Edit the loop below so that it generates the matrix by appending suitable column vectors.
%Edit the lines below to generate the matrix K described above.
u=[1:3:28];
K=[];
for k=0:1:3
    K=[(30*k+u);K];
end

%Q10: Comparing vectors. 
%Given two vectors , find all the indices  such that . Place these indices in increasing order in the row vector ind.
rng(10);s=randi(10,1e2,1);t=randi(10,1e2,1);%---> SETUP: do not edit
%Edit the line below to generate the vector ind described above.
ind = find(s == flipud(t));
ind = ind';

%II Matrices: operations and manipulations
%Key commands:  diag,flipud,fliplr,norm,vecnorm,max,triu,toeplitz,bandwidth

%Q11: Vector-matrix product
%Let . Left-multiplication of  by a row vector  is given by a row vector  which can be written as a linear combination of rows of : 
            
%where  denotes the ith row of A. Use the single loop provided to construct the row vector  as a linear combination of the rows of . 
%Note: other implementations of the matrix-vector product will not be accepted. In particular, you should not use nested loops.
rng(11);n=randi(50,1,1);m=randi(100,1,1); A=randi(10,m,n);y=randi(10,1,m);%---> SETUP: do not edit
%Edit the lines below to generate the vector-matrix product z
z=zeros(1,n);
for i=1:1:m
    z=z + y(i) * A(i,:);
end

%Q12: Matrix-matrix product
%Let . The matrix-matrix product is a matrix  with columns
            
%Use the single loop provided to construct the matrix C using the above expression. 
%Note: other implementations of the matrix-matrix product will not be accepted. In particular, you should not use nested loops.
rng(12);n=randi(50,1,1);m=randi(100,1,1);q=randi(20,1,1);%---> SETUP: do not edit
A=randi(20,m,n);B=randi(20,n,q);%---> SETUP: do not edit
%Edit the lines below to generate the matrix-matrix product for general
%matrix sizes m-by-n and n-by-q.
C=zeros(m,q);
for j=1:q
    C(:,j) = A * B(:,j);
end

%Q13: Matrix diagonals (1)
%Let  be given. Without using a loop, replace its diagonal entries  with ones. 
rng(13);n=randi([10 50]);m=randi([10 50]);%---> SETUP: do not edit
D=randi(20,m,n);%---> SETUP: do not edit
%Edit the line below to generate the diagonal matrix D.
D = D - (diag(D,0)-1).*eye(size(D));

%Q14: Matrix diagonals (2)
%Let  be even and let  be given. Construct a square matrix  of size  having as non-zero entries only two diagonals: 
%the main diagonal containing the entries from : ;
%the main 'anti-diagonal' containing the entries from : .
%No loops.
rng(14);n=2*randi(10,1,1);v=randi(20,n,1);w=randi(20,n,1);%---> SETUP: do not edit
%Edit the line below to generate the required matrix X.
X=diag(v,0) + fliplr(diag(w,0));

%Q15: Row-swaps
%Given a matrix  and two distinct row indices , overwrite the matrix with a matrix with rows  and  swapped over. 
rng(15);n=randi(20);m=randi(40);i1=randi([1 m]);i2=randi([1 n]);%---> SETUP: do not edit
B=randn(m,n);%---> SETUP: do not edit
%Edit the line below to overwrite B as required.
Bi1=B(i1,:);
B(i1,:) = B(i2,:);
B(i2,:) = Bi1;
B;

%Q16: Max-norm row
%The 2-norm of a vector  is the non-negative scalar . The 2-norm of  is denoted by  or . Type help norm for the corresponding Matlab usage.
%Given a matrix  find the row with maximum 2-norm. 
rng(16);n=randi(500);m=randi(20);%---> SETUP: do not edit
M=randi(20,m,n);%---> SETUP: do not edit
%Edit the line below to generate the row of M with the largest 2-norm.
[maxnorm, maxnormrowindex] = max(vecnorm(M,2,2));
maxnormrow=M(maxnormrowindex,:);

%Q17: 'Scaling' columns
%Let , where . Generate the matrix  whose th column is scaled (divided) by the th diagonal element . No loops.
rng(17);m=randi([50 100]);n=randi([30,50]);N=randi(20,m,n);%---> SETUP: do not edit
%Edit the line below to generate the scaled matrix N_s.
Ns=N.*(diag(N).^-1)';

%Q18: Banded matrices
%Construct an upper triangular matrix  with upper bandwidth . The non-zero entries should be alternating between  and  in each row, with the diagonal entries equal to 1. 
rng(18);n=randi([20 40]);p=randi(10);
%Edit the line below to generate the banded matrix U.
U=tril(triu(toeplitz(mod(1:n,2)*2-1)), p);

%Q19: Tridiagonal matrices
%Tridiagonal matrices are sparse matrices, with non-zeros only on the main diagonal and the first sub-diagonal and the first super-diagonal. Construct a square tridiagonal matrix  satisfying
%the main diagonal contains consecutive powers of 2 starting at 2 (in increasing order),
%the superdiagonal contains consecutive odd integers starting at 1 (in increasing order),
%the subdiagonal contains consecutive multiples of 3 starting at 0 (in increasing order).
rng(19);n=randi([10 50]);%---> SETUP: do not edit
%Edit the line below to generate the required matrix T.
T=zeros(n);
T(1:n+1:end) = 2.^(1:n);
T(2:n+1:end) = 0:3:3*(n-2);
T = T + diag((1:2:2*(n-1)-1),1);

%Q20: Complexity calculation
%The command flops used to be available in early versions of Matlab. Currently, cputime,etime,tic/toc are the only available commands if you want to indirectly evaluate complexity. 
%Let . Consider the matrix vector product . By definition,

%Modify this expression for the case where  is a dense lower-triangular matrix, so that operations with the zero entries in  are excluded.
%Implement your modified expression using the nested loop below so that it computes the matrix-vector product, while at the same time it updates a variable flops that counts the number of operations to termination.
rng(20);m=randi([11 20]);n=randi(10);%---> SETUP: do not edit
A=tril(randn(m,n));x=randn(n,1);%---> SETUP: do not edit
y=zeros(m,1);
flops=0;
for i=1:m
    for j=1:min(i,n)
       y(i) = y(i) + A(i, j) * x(j);
       flops=flops + 2;
    end
end

%---> End of Task1
%---> SETUP: do not edit
%List of variables to be checked:
xvars={a b c d ee F G hmax3 K ind z C D X B maxnormrow Ns U T flops};
%---> SETUP: do not edit
