%% Miniproject Code KUKA
clear
close all
clc
kuka=RobotConnectorKUKA;
cam = webcam('Logitech');
%original=snapshot(cam);
%original=original(138:end,131:512,:);

%%
MoveHome(kuka);
final_poses=[80, 500, 5, 0, 0, 0;
    160, 500, 5, 0, 0, 0];
Homer=0;
Marge=0;
Bart=1;
Lisa=0;
Maggie=1;
vel=0.7;

if (size(final_poses,1)<Homer+Marge+Bart+Lisa+Maggie)
    disp('WARNING: Not enough room to place the desired figures')
else
    yellow=Homer+Marge+Bart+2*Lisa+Maggie;
    orange=Bart+Lisa;
    blue=Homer+Marge+Bart+Maggie;
    green=Marge;
    black=Homer;
    
    original=snapshot(cam);
    original=original(MyParameters.YMIN:MyParameters.YMAX,...
        MyParameters.XMIN:MyParameters.XMAX,:);
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
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.blue(nblue,1);
            y=blocks.blue(nblue,2);
            angle=blocks.blue(nblue,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z1;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nblue=nblue-1;
            
            % Black brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.black(nblack,1);
            y=blocks.black(nblack,2);
            angle=blocks.black(nblack,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z2;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nblack=nblack-1;
            
            % Yellow brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z3;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nyellow=nyellow-1;
            
            k=k+1;
        end %Build Homer
        
        for i=1:1:Marge             % Build Marge
            % Green brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.green(ngreen,1);
            y=blocks.green(ngreen,2);
            angle=blocks.green(ngreen,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z1;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            ngreen=ngreen-1;
            
            % Yellow brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z2;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nyellow=nyellow-1;
            
            % Blue brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.blue(nblue,1);
            y=blocks.blue(nblue,2);
            angle=blocks.blue(nblue,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z3;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nblue=nblue-1;
            
            k=k+1;
        end % Build Marge
        
        for i=1:1:Bart             % Build Bart
            % Blue brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.blue(nblue,1);
            y=blocks.blue(nblue,2);
            angle=blocks.blue(nblue,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z1;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nblue=nblue-1;
            
            % Orange brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.orange(norange,1);
            y=blocks.orange(norange,2);
            angle=blocks.orange(norange,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z2;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            norange=norange-1;
            
            % Yellow brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z3;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nyellow=nyellow-1;
            
            k=k+1;
        end % Build Bart
        
        for i=1:1:Lisa             % Build Lisa
            % Yellow brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z1;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nyellow=nyellow-1;
            
            % Orange brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.orange(norange,1);
            y=blocks.orange(norange,2);
            angle=blocks.orange(norange,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z2;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            norange=norange-1;
            
            % Yellow brick
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z3;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nyellow=nyellow-1;
            
            k=k+1;
        end % Build Lisa
        
        for i=1:1:Maggie             % Build Maggie
            % Blue brick
            clear original blocks
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.blue(nblue,1);
            y=blocks.blue(nblue,2);
            angle=blocks.blue(nblue,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z1;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nblue=nblue-1;
            
            % Yellow brick
            clear original blocks
            original=snapshot(cam);
            original=original(MyParameters.YMIN:MyParameters.YMAX,...
                MyParameters.XMIN:MyParameters.XMAX,:);
            blocks=RecognizeBlocks(original);
            x=blocks.yellow(nyellow,1);
            y=blocks.yellow(nyellow,2);
            angle=blocks.yellow(nyellow,3);
            if (angle>0)
                angle=angle-45;
            else
                angle=angle+45;
            end
            final_poses(k,3)=MyParameters.Z2;
            PickPlace([x,y,MyParameters.Z,angle,0,0],final_poses(k,:),vel,kuka)
            nyellow=nyellow-1;
            
            k=k+1;
        end % Build Maggie
        
        MoveHome(kuka);
    end % If there are enough bricks
    
end % If there is enought room