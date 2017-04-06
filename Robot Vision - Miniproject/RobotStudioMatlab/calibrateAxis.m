%cam = webcam('Logitech');
original=imread('pictures.png');
original=original(MyParameters.YMIN:MyParameters.YMAX,...
    MyParameters.XMIN:MyParameters.XMAX,:);
imtool(original)
image_points=[ 567 505;
              521 459;
              566 456;
              470 459;
              371 309;
              419 309;
              470 409]';

real_points=31.75*[0 0;
             1 1;
             1 0;
             1 2;
             4 4;
             4 3;
             2 2]';
        
 K=vgg_H_from_x_lin(image_points,real_points);  
 p_image=[470 409 1]';
 K*p_image