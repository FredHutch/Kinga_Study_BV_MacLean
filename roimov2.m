function uproi=roimov2(NUCroi,EXroi,I)




hf=figure('IntegerHandle','off');
hf.Name='Select more cells';
hf.Pointer='custom';
hf.PointerShapeCData=NaN(16);
hf.UserData{1}=NUCroi;
hf.UserData{2}=80;
hManager = uigetmodemanager(hf);
[hManager.WindowListenerHandles.Enabled] = deal(false); 
%set(hf, 'WindowKeyPressFcn', []);


hip=imshowpair(NUCroi,I,'ColorChannels','red-cyan');
hf.UserData{3}=[hip.Parent.XLim;hip.Parent.YLim];




roi = images.roi.Circle(hf.CurrentAxes);
roi.Radius=hf.UserData{2};
pm.enterFcn = [];
pm.exitFcn  = [];
pm.traverseFcn = @(~,~) set(roi, 'Center',hf.CurrentAxes.CurrentPoint(1,1:2),'InteractionsAllowed','none','Linewidth',1,'Color','y','FaceAlpha',0);
iptSetPointerBehavior(hf.CurrentAxes, pm);
iptPointerManager(hf,'enable');
set(hf,'WindowButtonMotionFcn',@(~,~)NaN);
set(hf,'KeyPressFcn',@KP);

set(hf,'WindowButtonDownFcn',@ButtonDown);uiwait(hf);
uproi=hf.UserData{1};close;



    function ButtonDown(hf,~)
        
        modi=get(gcf,'currentModifier');
        
        ROI=createMask(roi);
        if ismember('control',modi)
        NUCroi(EXroi & ROI)=false;
        else
          NUCroi(EXroi & ROI)=true;
        end
        hf.UserData{1}=NUCroi;
        hip=imshowpair(NUCroi,I,'ColorChannels','red-cyan');
        XY=hf.UserData{3};
        hip.Parent.XLim=XY(1,:);
        hip.Parent.YLim=XY(2,:);
        
        roi = images.roi.Circle(hf.CurrentAxes);
        roi.Radius=hf.UserData{2};
        pm.enterFcn = [];
        pm.exitFcn  = [];
        pm.traverseFcn = @(~,~) set(roi, 'Center',hf.CurrentAxes.CurrentPoint(1,1:2),'InteractionsAllowed','none','Linewidth',1,'Color','y','FaceAlpha',0);
        iptSetPointerBehavior(hf.CurrentAxes, pm);
        iptPointerManager(hf,'enable');
        
        
        
    end

    function KP(hf,event)

        
        switch event.Key
            
            case 'a'
            roi.Radius=roi.Radius+10;
            hf.UserData{2}=roi.Radius;
            case 'z'
            if roi.Radius>10
            roi.Radius=roi.Radius-10;
            elseif roi.Radius<=10 && roi.Radius>1
                roi.Radius=roi.Radius-1;
            else
                roi.Radius=roi.Radius;
            end
            hf.UserData{2}=roi.Radius;
            case 'w'
            zoom(gcf,'on')
            zoom(gcf,2)
            xx=get(gca,'XLim');
            yy=get(gca,'YLim');
            hf.UserData{3}=[xx;yy];
            zoom(gcf,'off')
            case 's'
            zoom(gcf,'on')
            zoom(gcf,0.5)
            xx=get(gca,'XLim');
            yy=get(gca,'YLim');
            hf.UserData{3}=[xx;yy];
            zoom(gcf,'off')
            case 'leftarrow' %Left arrow key
            xx=get(gca,'XLim');
            xx=xx-100;
            yy=get(gca,'YLim');
            set(gca,'XLim',xx);
            hf.UserData{3}=[xx;yy];
            case 'uparrow' %up arrow
            xx=get(gca,'XLim');
            yy=get(gca,'YLim');
            yy=yy-100;
            set(gca,'YLim',yy);
            hf.UserData{3}=[xx;yy];
            case 'rightarrow' %right
            xx=get(gca,'XLim');
            xx=xx+100;
            yy=get(gca,'YLim');
            set(gca,'XLim',xx);
            hf.UserData{3}=[xx;yy];
            case 'downarrow' %down
            xx=get(gca,'XLim');
            yy=get(gca,'YLim');
            yy=yy+100;
            set(gca,'YLim',yy);
            hf.UserData{3}=[xx;yy];
            case 'x'
            uiresume(hf);
        end
        

            
        
    end
end

