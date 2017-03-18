%% Miniproject Code KUKA

%cam = webcam('Logitech');
%original=snapshot(cam);
%original=original(138:end,131:512,:);

final_poses=[0 0 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 0;
    0 0 0 0 0 0];
Homer=1;
Marge=1;
Bart=2;
Lisa=1;
Maggie=1;

if (size(final_poses,1)<Homer+Marge+Bart+Lisa+Maggie)
    disp('WARNING: Not enough room to place the desired figures')
else
    yellow=Homer+Marge+Bart+Lisa+Maggie;
    orange=Bart+Lisa;
    blue=Homer+Marge+Bart+Maggie;
    green=Marge;
    black=Homer;
    
    blocks=RecognizeBlocks(original);
    
    nyellow=size(blocks.yellow,1);
    norange=size(blocks.orange,1);
    nblue=size(blocks.blue,1);
    ngreen=size(blocks.green,1);
    nblack=size(blocks.black,1);
    
    if (nyellow<yellow)||(norange<orange)||(nblue<blue)||(ngreen<green)||(nblack<black)
        disp('WARNING: Not enough bricks to build the desired figures')
    else
        k=1;                        % Figure index
        for i=1:1:Homer             % Build Homer
            % Blue brick
            x=blocks.blue(nblue,1);
            y=blocks.blue(nblue,2);
            angle=blocks.blue(nblue,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z1;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nblue=nblue-1;
            
            % Black brick
            x=blocks.black(nblack,1);
            y=blocks.black(nblack,2);
            angle=blocks.black(nblack,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z2;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nblack=nblack-1;
            
            % Yellow brick
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z3;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nyellow=nyellow-1;
            
            k=k+1;
        end %Build Homer
        
        for i=1:1:Marge             % Build Marge
            % Green brick
            x=blocks.green(ngreen,1);
            y=blocks.green(ngreen,2);
            angle=blocks.green(ngreen,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z1;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            ngreen=ngreen-1;
            
            % Yellow brick
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z3;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nyellow=nyellow-1;
            
            % Blue brick
            x=blocks.blue(nblue,1);
            y=blocks.blue(nblue,2);
            angle=blocks.blue(nblue,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z3;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nblue=nblue-1;
            
            k=k+1;
        end % Build Marge
        
        for i=1:1:Bart             % Build Bart
            % Blue brick
            x=blocks.blue(nblue,1);
            y=blocks.blue(nblue,2);
            angle=blocks.blue(nblue,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z1;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nblue=nblue-1;
            
            % Orange brick
            x=blocks.orange(norange,1);
            y=blocks.orange(norange,2);
            angle=blocks.orange(norange,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z2;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            norange=norange-1;
            
            % Yellow brick
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z3;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nyellow=nyellow-1;
            
            k=k+1;
        end % Build Bart
        
        for i=1:1:Lisa             % Build Lisa
            % Yellow brick
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z1;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nyellow=nyellow-1;
            
            % Orange brick
            x=blocks.orange(norange,1);
            y=blocks.orange(norange,2);
            angle=blocks.orange(norange,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z2;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            norange=norange-1;
            
            % Yellow brick
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z3;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nyellow=nyellow-1;
            
            k=k+1;           
        end % Build Lisa
        
        for i=1:1:Marge             % Build Marge
            % Blue brick
            x=blocks.blue(nblue,1);
            y=blocks.blue(nblue,2);
            angle=blocks.blue(nblue,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z1;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nblue=nblue-1;
            
            % Yellow brick
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=Z2;
            PickPlace([x,y,Z,angle,0,0],final_poses(k,:),vel)
            nyellow=nyellow-1;
            
            k=k+1;           
        end % Build Maggie
        
    end % If there are enough bricks
    
end % If there is enought room