function [dapich, GFPch, TexasRedch, FarRedch]=dialogTissueFACS(sinfo)

nch=sinfo.C;

dapich=1;GFPch=2;TexasRedch=3; FarRedch=4;



d=uifigure('Name','Select Channels','Position',[584 595 200 400],...
    'Color',[0.7020    0.9412    0.5451]);

channeltext=uicontrol(d,'Style','text','String',['Total Channels: ' int2str(nch)]);
channeltext.BackgroundColor=[0.702 0.9412 0.5451];
channeltext.Position=[10 300 180 20];

dapitext=uicontrol(d,'Style','text','Position',[20 200 120 20],...
    'String','DAPIch ','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
dapi=uicontrol(d,'Style','edit','Position',[120 200 40 20],...
    'String','1');
dapi.Callback=@dapi_callback;

gfptext=uicontrol(d,'Style','text','Position',[20 160 120 20],...
    'String','GFPch ','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
gfp=uicontrol(d,'Style','edit','Position',[120 160 40 20],...
    'String','2');
gfp.Callback=@gfp_callback;

texasredtext=uicontrol(d,'Style','text','Position',[20 120 120 20],...
    'String','TexasRedch ','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
texasred=uicontrol(d,'Style','edit','Position',[120 120 40 20],...
    'String','3');
texasred.Callback=@texasred_callback;

faredtext=uicontrol(d,'Style','text','Position',[20 80 120 20],...
    'String','FarRedch ','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
farred=uicontrol(d,'Style','edit','Position',[120 80 40 20],...
    'String','4');
farred.Callback=@farred_callback;


okbutton=uicontrol(d,"Style","pushbutton","String","OK", "Position",[80 30 60 20]);
okbutton.Callback=@okbutton_callback;


uiwait(d);


    function dapi_callback(dapi,event)
        dvalue=dapi.String;
        dapich=str2double(dvalue);
    end

    function gfp_callback(gfp,event)
        gvalue=gfp.String;
        GFPch=str2double(gvalue);
    end

    function texasred_callback(texasred,event)
        trvalue=texasred.String;
        TexasRedch=str2double(trvalue);
    end

    function farred_callback(farred,event)
        frvalue=farred.String;
        FarRedch=str2double(frvalue);
    end

   



    function okbutton_callback(okbutton,event)
        Allch=[dapich GFPch TexasRedch FarRedch];
        if sum(Allch>0)<=nch ...
                && max([dapich GFPch TexasRedch FarRedch])<=nch...
                && numel(unique(Allch(Allch>0)))==nch
        

        uiresume(d);
        close(d);
        end
    end

end

