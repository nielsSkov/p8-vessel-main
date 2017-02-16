function[heading, wp_reached, cte] = wp_gen(wps,wpe,now)
%%WP_GEN Waypoint Generator
%   This calculates reference points for the path follower
%   
%   wp_gen(waypoint_start, waypoint_end, waypoint_now)

P_c = [now 0]; % [x y angle]
wp_r = 1; % Waypoint Radius
wp_reached = 0; % Waypoint not reached
v_i_len = 2; % length of intermediate vector

%% Initial calculations
% track = [wps;wpe];

%% Track-frame projected point
v_i = (wpe-wps)/norm(wpe-wps)*v_i_len; % Intermediate vector
P_i = [P_c(1)+v_i(1) P_c(2)+v_i(2)]; % Intermediate projected parallel point

%% Calculate projected point onto the track
A = P_i - wps;
B = wpe - wps;
r_p = ((dot(A,B))/((norm(B)^2)))*B; % Projection of vector on vector
P_p = r_p + wps;

%% The vessels predicted position
v_d = P_p - P_c(1:2);
v_ref = v_d/norm(v_d); % normaliserer
v_ref = v_ref * v_i_len;
P_ref = v_ref + now;
% plot(P_ref(2),P_ref(1),'*')

%% Calculate if waypoint is reached
dist = sqrt((P_c(1)-wpe(1))^2+(P_c(2)-wpe(2))^2);
if dist < wp_r
    wp_reached = 1;
end

%% Calculate heading
% heading = 2*pi-asin(( P_ref(1)-P_c(1) ) / sqrt( (P_ref(1)-P_c(1))  ^2 + (P_ref(2)-P_c(2))^2 ));
% heading = mod(atan2(v_ref(2),v_ref(1))+pi,2*pi)-pi;
heading = rad2pipi(atan2(v_ref(2),v_ref(1)));


%% CrossTrackError % MOD = HYP*SIN(A) => crosstrack = (pos-wps) * sin(vinkel mellem (pos-wps) og (pos-wps))
a = norm(now-wps);
b = norm(wpe-wps);
vinkel = (acos((now-wps)*(wpe-wps)'/(a*b)));
% vinkeligrader = vinkel*180/pi;
cte = a*sin(vinkel);
end