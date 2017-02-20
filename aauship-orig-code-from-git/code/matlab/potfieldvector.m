function [ Fvl, Fij, Fca, Foa ] = potfield( pi, pi0, pj, pj0, po, vl, Fmax, Kvl, Kij, Kca, Koa, rsav)
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
    Fca = [0,0];
    Foa = [0,0];
    Fij = [0,0];
    % Force virtuel leader
%     Fvl = Kvl*(vl-pi - (vl-pi0));
    Fvl = Kvl*(vl-pi - (vl-pi0)+vl);

    % Force inter vehicle, emllem i og j (Trækker dem lidt sammen)
    for j = 1:size(pj,1)
        Fij_tmp(j,1:2) = Kij*(pj(j,1:2)-pi-(pj0(j,1:2)-pi0));
        Fij = Fij + Fij_tmp(j,1:2);
    end

    %Force collision avoidance (For at undgå sammenstød)
    for j = 1:size(pj,1)
        dij(j,1:2) = pj(j,1:2) - pi;% Udregning til senere brug under Fca
        if norm(dij(j,1:2)) < rsav
            Fca_tmp = ((Kca*rsav)/norm(dij(j,1:2))-Kca)*(dij(j,1:2)/norm(dij(j,1:2)));
        else
            Fca_tmp = [0,0];
        end
        Fca = Fca_tmp + Fca;
    end

    % Force object avoidance (For at undgå stillestående objekter)
    for j = 1:size(po,1)
        dki(j,1:2) = po(j,1:2) - pi;
        if norm(dki(j,1:2)) < rsav*2
            Foa_tmp = (Koa/norm(dki(j,1:2))-Koa/(rsav*2))*(dki(j,1:2)/norm(dki(j,1:2)));
        else
            Foa_tmp = [0,0];
        end
        Foa = Foa_tmp + Foa;
    end
end

