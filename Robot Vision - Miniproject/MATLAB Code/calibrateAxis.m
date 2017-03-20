%cam = webcam('Logitech');
original=snapshot(cam);
original=original(MyParameters.YMIN:MyParameters.YMAX,...
    MyParameters.XMIN:MyParameters.XMAX,:);
imtool(original)
image_points=[481 286;
              206 290;
              482 7;
              201 12;
              282 92;
              360 130]';

real_points=40*[0 0;
             0 7;
             7 0;
             7 7;
             5 5;
             4 3]';
        
 K=vgg_H_from_x_lin(image_points,real_points);  
 p_image=[351 257 1]';
 K*p_image