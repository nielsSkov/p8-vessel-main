function h = circle(x,y,r)
%     hold on
    th = 0:pi/30:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit);
%     hold off
end