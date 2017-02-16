function [ pip, minval  ] = pathgen( n, r, pip, pi0, pj, pj0, po, vl, Fmax, Kvl, Kij, Kca, Koa, rsav )
%PATHGEN Genererer path for den i'te båd
% n er opløsning af punkter vi kontrollerer ud til fra aktuel pos
% r er radius punkterne skal skaleres ud med
% pip er aktuel pos på path [x , y]
% pi0, båd i's endepunkt [x , y]
% pj, pos af andre både, array af pos [x , y]
% pj0, ønsket pos af andre både, array af pos [x , y]
% po, pos af objekter, array af pos [x , y]
% vl, pos af virtuel leader
% Fmax, den maksimale størrelse af potfield, bruges til plots
% Kvl, gain på virtuel leader
% Kij, gain på inter vehicle
% Kca, gain på collision avoidance
% Koa, gain på obkect avoidance
% rsav, safety radius
    clear pi
    % This point iteration takes 18.129 µs for n = 24
    % or                         20.090 ms for n = 360
    for m = 1:n 
        x0(m) = sin(2*pi/n*m)*r;
        y0(m) = cos(2*pi/n*m)*r;
    end
    pil = zeros(n,2);
    Ftotmagn2 = zeros(n,1);
    for l = 1:n
        pil(l,:) = pip + [x0(l),y0(l)];
        [Fvlmagn, Fijmagn, Fcamagn, Foamagn] = potfield(pil(l,:), pi0, pj, pj0, po, vl, Fmax, Kvl, Kij, Kca, Koa, rsav);
        Ftotmagn2(l) = Fvlmagn + Fijmagn + Fcamagn + Foamagn;
    end
    [minval,lol] = min(Ftotmagn2);
    minval = min(minval,Fmax);
    pip = pil(lol,:);
end

