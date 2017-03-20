function dist = FindDistWP(wp_k,wp_k1,vessel_pos)
%dist = FindDistWP(wp_k,wp_k1,vessel_pos) 
%   This function receives the waypoints that define the path and the
%   position of the vessel and calculates the distance from the crossing of
%   a perpendicular line to the path passing through the vessel position 
%   and the next waypoint.

k = ((wp_k1(2)-wp_k(2)) * (vessel_pos(1)-wp_k(1)) - (wp_k1(1)-wp_k(1)) * ...
    (vessel_pos(2)-wp_k(2))) / ((wp_k1(2)-wp_k(2))^2 + (wp_k1(1)-wp_k(1))^2);
x4 = vessel_pos(1) - k * (wp_k1(2)-wp_k(2));
y4 = vessel_pos(2) + k * (wp_k1(1)-wp_k(1));

dist=norm(wp_k1-[x4,y4]);
end

