function [K] = CCF(A,B)


%Test Problem
%A = [2 -11 12 31; -3 13 -11 -33; 4 -25 14 51; -3 16 -11 -36];
%B = [-1 -4; 1 6; -1 -11; 1 7];
tolerance = 1e-5;
P = [];
B_controls = [];

%Grab full control matrix and pick the columns until nxn matrix and full
%rank.
P_full = ctrb(A,B);
power_it = 1;
cur_B = 1;
while size(P, 2) < size(A,2)
    %Grab a column
    P_temp = [P P_full(:,power_it)];
    %Check full rank
    if rank(P_temp, tolerance) == size(P_temp,2)
        P = P_temp;
        %Keep track of the B column used, for later
        B_controls = [B_controls cur_B];
    end
    %Check next column
    power_it = power_it + 1;
    cur_B = cur_B + 1;
    %If at end of B's, start over.
    if cur_B > size(B, 2)
        cur_B = 1;
    end
end

%Compute M matrix. Done by ordering the P matrix by which B was used,
%essentially enforcing B1 AB1 B2 AB2 ....
M = [];
for i = unique(B_controls)
    controls_it = find(B_controls == i);
    for j = controls_it
        M = [M P(:,j)];
    end
     
end
M_inv = M^-1;

%Compute transform, done by taking the bottom row of each "B section" and
%multiplying it by A.
T = [];
B_controls = sort(B_controls);
for i = unique(B_controls)
    controls_it = find(B_controls == i);
    p = M_inv(controls_it(end), :);
    for j = 1:length(controls_it)
        if j == 1
            T = [T; p];
        else
            T = [T; p*A^(j-1)];
        end
    end
end

%Transform and get rid of annoying decimals.
A_con = T*A*T^-1;
A_con = round((A_con * 10000))/10000;
B_con = T*B;
B_con = round((B_con * 10000))/10000;

%Test problem
%syms k11 k12 k13 k14 k21 k22 k23 k24 z
%K = [k11 k12 k13 k14; k21 k22 k23 k24];
%eigens_desired = [5, 5, 3 + 3i, 3 - 3i];
%Real Problem
syms k11 k12 k13 k14 k15 k16 k17 k18 k19 k110 z
syms k21 k22 k23 k24 k25 k26 k27 k28 k29 k210
syms k31 k32 k33 k34 k35 k36 k37 k38 k39 k310
%syms k41 k42 k43 k44 k45 k46 k47 k48 k49 k410
syms k51 k52 k53 k54 k55 k56 k57 k58 k59 k510
syms k61 k62 k63 k64 k65 k66 k67 k68 k69 k610
K = [k11 k12 k13 k14 k15 k16 k17 k18 k19 k110; ...
k21 k22 k23 k24 k25 k26 k27 k28 k29 k210; ...
k31 k32 k33 k34 k35 k36 k37 k38 k39 k310; ...
%k41 k42 k43 k44 k45 k46 k47 k48 k49 k410; ...
k51 k52 k53 k54 k55 k56 k57 k58 k59 k510; ...
k61 k62 k63 k64 k65 k66 k67 k68 k69 k610];
eigens_desired = ones(1,10)*5;%[1,1,1,1,1,1,1,1,1,1];
coeffs_k = A_con+B_con*K;

A_des = [];
for i = 1:2:length(eigens_desired)
    zeros_before = zeros(1,i-1);
    zeros_after = zeros(1, size(A_con,2) - (length(zeros_before) + 2));
    A_des = [A_des; zeros(1, i) 1 zeros_after];
    coeffs_des = -coeffs(expand((z + eigens_desired(i))*(z + eigens_desired(i+1))));
    coeffs_des = eval(coeffs_des(1:2));
    A_temp = [zeros_before coeffs_des(1) coeffs_des(2) zeros_after];
    A_des = [A_des; A_temp];
end

coeffs_k = solve(A_des == coeffs_k);

K_ans = [coeffs_k.k11 coeffs_k.k12 coeffs_k.k13 coeffs_k.k14 coeffs_k.k15 coeffs_k.k16 coeffs_k.k17 coeffs_k.k18 coeffs_k.k19 coeffs_k.k110; ...
coeffs_k.k21 coeffs_k.k22 coeffs_k.k23 coeffs_k.k24 coeffs_k.k25 coeffs_k.k26 coeffs_k.k27 coeffs_k.k28 coeffs_k.k29 coeffs_k.k210; ...
coeffs_k.k31 coeffs_k.k32 coeffs_k.k33 coeffs_k.k34 coeffs_k.k35 coeffs_k.k36 coeffs_k.k37 coeffs_k.k38 coeffs_k.k39 coeffs_k.k310; ...
%coeffs_k.k41 coeffs_k.k42 coeffs_k.k43 coeffs_k.k44 coeffs_k.k45 coeffs_k.k46 coeffs_k.k47 coeffs_k.k48 coeffs_k.k49 coeffs_k.k410; ...
coeffs_k.k51 coeffs_k.k52 coeffs_k.k53 coeffs_k.k54 coeffs_k.k55 coeffs_k.k56 coeffs_k.k57 coeffs_k.k58 coeffs_k.k59 coeffs_k.k510; ...
coeffs_k.k61 coeffs_k.k62 coeffs_k.k63 coeffs_k.k64 coeffs_k.k65 coeffs_k.k66 coeffs_k.k67 coeffs_k.k68 coeffs_k.k69 coeffs_k.k610];


K = eval(K_ans * T^1);
