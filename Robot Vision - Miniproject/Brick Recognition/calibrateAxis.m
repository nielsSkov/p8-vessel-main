%cam = webcam('Logitech');
original=snapshot(cam);
original=original(138:end,131:512,:);
imtool(original)
image_points=[348 304;
              335 22;
              65 24;
              59 307
              183 139
              18 307;
              63 181]';

real_points=40*[0 0;
             7 0;
             7 7;
             0 7;
             4 4
             0 8;
             3 7]';
        
 K=vgg_H_from_x_lin(image_points,real_points);  
 p_image=[199 275 1]';
 K*p_image