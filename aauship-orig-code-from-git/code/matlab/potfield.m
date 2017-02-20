function [ Fvlmagn, Fijmagn, Fcamagn, Foamagn ] = potfield( pi, pi0, pj, pj0, po, vl, Fmax, Kvl, Kij, Kca, Koa, rsav)
%POTFIELD Genererer potential field til punktet pi, som er bådens aktuelle
%pos
% pi, båd i's aktuelle pos [x , y]
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
    Fcamagn = 0;
    Foamagn = 0;
    Fijmagn = 0;
    % Force virtuel leader
%     Fvl = Kvl*(vl-pi - (vl-pi0));
    Fvl = Kvl*(vl-pi - (vl-pi0)+vl);
    Fvlmagn = norm(Fvl);

    % Force inter vehicle, emllem i og j (Trækker dem lidt sammen)
    for j = 1:length(pj)
        Fij(j,1:2) = Kij*(pj(j,1:2)-pi-(pj0(j,1:2)-pi0));
        Fijmagn = Fijmagn + norm(Fij(j,1:2));
    end

    %Force collision avoidance (For at undgå sammenstød)
    for j = 1:length(pj)
        dij(j,1:2) = pj(j,1:2) - pi;% Udregning til senere brug under Fca
        if norm(dij(j,1:2)) < rsav
            Fca = ((Kca*rsav)/norm(dij(j,1:2))-Kca)*(dij(j,1:2)/norm(dij(j,1:2)));
        else
            Fca = 0;
        end
    Fcamagn = Fcamagn + norm(Fca);
    end

    % Force object avoidance (For at undgå stillestående objekter)
    for j = 1:length(po)
        dki(j,1:2) = po(j,1:2) - pi;
        if norm(dki(j,1:2)) < rsav
            Foa = (Koa/norm(dki(j,1:2))-Koa/rsav)*(dki(j,1:2)/norm(dki(j,1:2)));
        else
            Foa = 0;
        end
    Foamagn = Foamagn +  norm(Foa);
    end
end

