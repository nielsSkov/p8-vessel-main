%cam = webcam('Logitech');
original=snapshot(cam);
original=original(MyParameters.YMIN:MyParameters.YMAX,...
    MyParameters.XMIN:MyParameters.XMAX,:);
imtool(original)
image_points=[335 292;
              50 295;
              326 15;
              55 17;
              134 93;
              212 130]';

real_points=40*[0 0;
             0 7;
             7 0;
             7 7;
             5 5;
             4 3]';
        
 K=vgg_H_from_x_lin(image_points,real_points);  
 p_image=[337 334 1]';
 K*p_image