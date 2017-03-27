conv = 50;
P_E_raw = zeros(M+conv,1); % Price of Electricity [DKK/MWh] 
P_G_raw = zeros(M+conv,1); % Price of Gas [DKK/MWh] 
P_W_raw = 30*ones(M+conv,1); % Price of Waste [DKK/MWh] 

rng(1)

sigma_z = 50;
mu_z = 45;
z = ones(M+conv,1)*mu_z + sigma_z*randn(M+conv,1);

sigma_r = 15;
mu_r = 20;
r = ones(M+conv,1)*mu_r + sigma_r*randn(M+conv,1);

P_E_raw(1) = z(1);
P_G_raw(1) = r(1);

for i = 2:M+conv
    P_E_raw(i) = 0.7*P_E_raw(i-1)+z(i);
    P_G_raw(i) = 0.8*P_G_raw(i-1)+r(i);
end

% The price vectors
P_W = -30*ones(M,1); % Price of Waste [DKK/MWh] 
P_E = P_E_raw(conv+1:end);
P_G = P_G_raw(conv+1:end);