function [L, R, S] = almLRPCA(b, sigma, m, n, maxiter, r, mu, lambda)
%
% Solves the Robust PCA problem using the augmented Lagrangian method:
%
%   min_{L, S} ||L||_* + \lambda||S||_1 subject to ||A(L + S) - b||_2 <= sigma
%
% Reference:
% E. J. Cand`es, X. Li, Y. Ma, and J. Wright, ?Robust principal
% component analysis?,? J. ACM, vol. 58, no. 3, pp. 11:1?11:37,
% June 2011.
%
% Our implementation adopts the following factorized formulation:
%
%   min_{L, R, S} 1/2( ||L||_F^2 + ||R||_F^2) + \lambda||S||_1 subject to ||A(L*R' + S) - b||_2 <= sigma

% Written by Hassan Mansour (mansour@merl.com)
% Modified by Yuanyi Xue (yxue@merl.com)


A = 1;

if ~exist('A', 'var') 
    A = opDirac(m*n);
elseif isempty(A)
    A = opDirac(m*n);
end

if ~exist('bTransf', 'var')
    bTransf = 0;
end

if ~exist('r', 'var')
    r = min(m,n);
end

if isempty(mu)
    mu = m*n/10/norm(b,1);
end

if ~exist('lambda', 'var')
    lambda = 1/sqrt(min(m,n));
end

B = reshape(A'*b, m,n);

% initialize the variables
Y = zeros(m,n);

R = rand(n,r);
S = zeros(m,n);

iter = 0;
fprintf('%-10s %-10s %-10s\n', 'Itn#','Resid', 'sigma');
while(1)
    iter = iter + 1;
    %% Find low-rank update
    Temp = (Y + mu*(B - S));
    L = Temp*R/(speye(r) + mu*(R'*R));
    R = Temp'*L/(speye(r) + mu*(L'*L));
    
    X = L*R';
    
    
    %% Find sparse update
    Temp = (B(:) - X(:) + Y(:)/mu);
    S = Temp - A*Temp;
    S = S + A*wthresh(Temp(:), 's', lambda/mu);
  
    S = reshape(S, m,n);

    %% Update Lagrange multiplier

    Y = Y + mu*(B - (X + S));
        
    %% Print progress
    res = norm(b(:) - A*(X(:) + S(:)));
    fprintf('%5d %10.4f %10.4f\n', iter, res, sigma);

    if (res <= sigma)
        display(['almRPCA stopped after ', num2str(iter), ' iterations.']);
        display('Data mismatch is smaller than prescribed sigma value.')
        break;
    end
    if (iter >= maxiter)
        display(['spgRPCA stopped after ', num2str(iter), ' iterations.']);
        display('Number of iterations exceeds maxiter.')
        break;
    end
end

S = reshape(A*S(:),m,n);
end