function [dataPL, dataEP,outdata]=KingaBVTissueQuest()


warning off
[ffsel, psel]=uigetfile({'*.tiff;*.tif'});
if ~ffsel
    dataPL=[];
    dataEP=[];
    outdata=[];
    return
end
fsel=fullfile(psel,ffsel);
[~, ~, sinfo]=bfGetInfo(fsel);

[dapich, GFPch, TexasRedch, FarRedch]=dialogTissueFACS(sinfo);
IS=bfopen(fsel);
DAPI=IS{1,1}{1,1};
if GFPch
GFP=IS{1,1}{GFPch,1};
else
    GFP=zeros(size(DAPI),'like',DAPI);
end
if TexasRedch
TR=IS{1,1}{TexasRedch,1};
else
    TR=zeros(size(DAPI),'like',DAPI);
end
if FarRedch
CY5=IS{1,1}{FarRedch,1};
else
    CY5=zeros(size(DAPI),'like',DAPI);
end
omeMeta=IS{1,4};
Xvoxel=omeMeta.getPixelsPhysicalSizeX(0).value();
VoxX=Xvoxel.doubleValue()/1e3; %in mm^2


    inc=0.01;
    maxt=1;




%% 1st Step: Manually define threshold

Ims=min(size(DAPI));
if Ims>4000
si=numel(DAPI);
x=2000^2;
fra=round(si/x);
res=1/sqrt(fra);
DAPI=imresize(DAPI,res);
GFP=imresize(GFP,res);
TR=imresize(TR,res);
CY5=imresize(CY5,res);
VoxX=VoxX/res;
end

ft=figure('IntegerHandle','off');
ft.KeyPressFcn=@KPT;
chnames={'DAPI','GFP','TR','CY5'};
tvals=ones(4,1);
for i=1:4
IT=eval(chnames{i});
IT=imtophat(IT,strel('disk',5));
if any(IT,'all')
%imshow(IT,[0 quantile(IT(:),0.999)]);
it=graythresh(IT);
ITWP=imbinarize(IT,it);
O=imoverlay(imadjust(IT),ITWP,'r');
ft.Name=chnames{i};
hhii=imshow(O);
uiwait(ft);
tvals(i)=it;
else
    continue
end
end
close;



I=DAPI;
IW=imbinarize(I,tvals(1));
%% 2nd Step: Remove unwanted area

fd=figure('Name','Select region to ignore','IntegerHandle','off','KeyPressFcn',@rmRegion);
kk=1;
while kk
    imshow(I,[]);
delroi=drawfreehand();
Mdelroi=createMask(delroi);
IW(Mdelroi)=false;
I(Mdelroi)=0;uiwait;
end
close;
IWf=imfill(IW,'holes');
IC=imclose(IW,strel('disk',100));
f=1;
ICf=imclose(IWf,strel('disk',f));
EPW=bwareafilt(ICf,[8000 +Inf]);

%% Get channel binarization

%GFP(K)=0;
GFPt=imtophat(GFP,strel('disk',5));
%tg=graythresh(GFPt);
GFPW=imbinarize(GFPt,tvals(2));
%TR(K)=0;
TRt=imtophat(TR,strel('disk',5));
%tr=graythresh(TRt);
TRW=imbinarize(TRt, tvals(3));
%CY5(K)=0;
CY5t=imtophat(CY5,strel('disk',5));
%tb=graythresh(CY5t);
CY5W=imbinarize(CY5t, tvals(4));

%%Clever segmentation

[~, cm]=FastPeakFind(I);
cm=logical(cm);
cmr=bwmorph(cm,'Thicken',20);
cmr(~IW)=false;
cmrr=cmr;
cmrr=bwareaopen(cmrr,10);
RN=imreconstruct(cmr,EPW);
cmr(RN)=false;
NUC=bwareaopen(cmr,10);


%% 3rd Step: Select Lamina Propria

Sfig=figure('Name','Adjust Lamina Propria selection','IntegerHandle','off','KeyPressFcn',@KeyDef);
Sfig.UserData={ICf,f};
imshowpair(bwperim(NUC),I,'ColorChannels','red-cyan');
ICf=Sfig.UserData{1};
uiwait(Sfig);

roi=drawfreehand(gca);
MASK=createMask(roi);
NUCroi=NUC & MASK;
NUCroi=bwareaopen(NUCroi,5);
close(Sfig);

%imshowpair(bwperim(NUCroi),I,'ColorChannels','red-cyan');

%% 4th Step: refine stroma
PLuproi=roimov2(NUCroi,cmrr,I);

EProi=cmrr & ~PLuproi;
PLuproi=bwareaopen(PLuproi,5);
PLI=imclose(PLuproi,strel('disk',100));
EPI=IC;
EPI(PLI)=false;
PLSurf=numel(find(PLI))*VoxX^2;
EPSurf=numel(find(EPI))*VoxX^2;

Merge=cat(3,imadjust(TR),imadjust(GFP),imadjust(CY5));


C1=double(GFPW);
C2=double(TRW)*10;
C3=double(CY5W)*100;
RGB=C1+C2+C3;

%% Get PL data
StatsPL=regionprops(PLuproi,RGB,'PixelIdxList','PixelValues');
maxdatPL=cellfun(@max,{StatsPL.PixelValues}');
modedatPL=cellfun(@mode,{StatsPL.PixelValues}');
rgbtripPL=label2rgb(RGB,@lines,'k','outputFormat','triplets');
dataPL=struct();
dataPL.Stats=StatsPL;
dataPL.rgbtriplets=rgbtripPL;
dataPL.maxdat=maxdatPL;
dataPL.modedat=modedatPL;
dataPL.imsize=size(DAPI);
dataPL.nuc=PLuproi;

Pix=vertcat(StatsPL.PixelIdxList);
M=zeros(size(I));

for i=1:numel(StatsPL)
p=StatsPL(i).PixelValues;
if numel(find(p==maxdatPL(i)))>=3
StatsPL(i).PixelValues=repmat(maxdatPL(i),numel(p),1);
%Stats(i).PixelValues=repmat(101,numel(p),1);
else
StatsPL(i).PixelValues=repmat(modedatPL(i),numel(p),1);
%Stats(i).PixelValues=repmat(101,numel(p),1);
end
end
ColocMatPL=cellfun(@max,{StatsPL.PixelValues});
dataPL.Coloc=ColocMatPL';
Val=vertcat(StatsPL.PixelValues);
M(Pix)=Val;
cmap=zeros(111,3);
cmap(1,:)=[0 1 0];
cmap(10,:)=[1 0 0];
cmap(11,:)=[1 1 0];
cmap(100,:)=[0 0 1];
cmap(101,:)=[0 1 1];
cmap(110,:)=[1 0 1];
cmap(111,:)=[1 1 1];

rgb=label2rgb(M,cmap,'k');
figure, imshow(rgb)
Bb=bwboundaries(PLuproi);
hold on;
for i=1:length(Bb)
bb=Bb{i};
plot(gca,bb(:,2),bb(:,1),'w');
end
drawnow;pause(1);

%% Get EP data
StatsEP=regionprops(EProi,RGB,'PixelIdxList','PixelValues');
maxdatEP=cellfun(@max,{StatsEP.PixelValues}');
modedatEP=cellfun(@mode,{StatsEP.PixelValues}');
rgbtripEP=label2rgb(RGB,@lines,'k','outputFormat','triplets');
dataEP=struct();
dataEP.Stats=StatsEP;
dataEP.rgbtriplets=rgbtripEP;
dataEP.maxdat=maxdatEP;
dataEP.modedat=modedatEP;
dataEP.imsize=size(DAPI);
dataEP.nuc=EProi;

Pix=vertcat(StatsEP.PixelIdxList);
MEP=zeros(size(I));

for i=1:numel(StatsEP)
p=StatsEP(i).PixelValues;
if numel(find(p==maxdatEP(i)))>=3
StatsEP(i).PixelValues=repmat(maxdatEP(i),numel(p),1);
%Stats(i).PixelValues=repmat(101,numel(p),1);
else
StatsEP(i).PixelValues=repmat(modedatEP(i),numel(p),1);
%Stats(i).PixelValues=repmat(101,numel(p),1);
end
end
ColocMatEP=cellfun(@max,{StatsEP.PixelValues});
dataEP.Coloc=ColocMatEP';


Val=vertcat(StatsEP.PixelValues);
MEP(Pix)=Val;
cmap=zeros(111,3);
cmap(1,:)=[0 1 0];
cmap(10,:)=[1 0 0];
cmap(11,:)=[1 1 0];
cmap(100,:)=[0 0 1];
cmap(101,:)=[0 1 1];
cmap(110,:)=[1 0 1];
cmap(111,:)=[1 1 1];

rgbep=label2rgb(MEP,cmap,'k');
figure, imshow(rgbep)
Bb=bwboundaries(EProi);
hold on;
for i=1:length(Bb)
bb=Bb{i};
plot(gca,bb(:,2),bb(:,1),'w');
end

outdata=KingaBVcomputeCells(ColocMatPL,ColocMatEP,PLSurf,EPSurf);
xsel=[fsel(1:end-5) '.xlsx'];
writetable(outdata.fraction,xsel,'sheet','Count','WriteRowNames',true);
writetable(outdata.density,xsel,'sheet','Density');

%% CALLBACKS



    function KeyDef(fd,event)
        
        kk=event.Character;
        ICf=fd.UserData{1};
        f=fd.UserData{2};
        if double(kk)==107
            f=f+1;
            ICf=imclose(IWf,strel('disk',f));
            EPW=bwareafilt(ICf,[8000 +Inf]);
            cmr=bwmorph(cm,'Thicken',20);
            cmr(~IW)=false;
            RN=imreconstruct(cmr,EPW);
            cmr(RN)=false;
            NUC=bwareaopen(cmr,10);
            imshowpair(bwperim(NUC),I,'ColorChannels','red-cyan')
            fd.UserData{1}=ICf;
            fd.UserData{2}=f;
        elseif double(kk)==109
            %f=f+1;
            ICf=imerode(ICf,strel('disk',1));
            EPW=bwareafilt(ICf,[8000 +Inf]);
            cmr=bwmorph(cm,'Thicken',20);
            cmr(~IW)=false;
            RN=imreconstruct(cmr,EPW);
            cmr(RN)=false;
            NUC=bwareaopen(cmr,10);
            NUC=imreconstruct(NUC,cmrr);
            imshowpair(bwperim(NUC),I,'ColorChannels','red-cyan')
            fd.UserData{1}=ICf;
            fd.UserData{2}=f;
            elseif double(kk)==99
                            ICf=imclose(IWf,strel('disk',1));
            EPW=bwareafilt(ICf,[8000 +Inf]);
            cmr=bwmorph(cm,'Thicken',20);
            cmr(~IW)=false;
            RN=imreconstruct(cmr,EPW);
            cmr(RN)=false;
            NUC=bwareaopen(cmr,10);
            imshowpair(bwperim(NUC),I,'ColorChannels','red-cyan')
            fd.UserData{1}=ICf;
            fd.UserData{2}=1;
        elseif double(kk)==120
            
        
            
            uiresume;
        end
        
    end

    function KPT(ft,event)
        keyp=event.Key;
        switch keyp
            case 'rightarrow'
                if it<maxt
                    it=it+inc;
                    disp(it)
                    ITWPtemp=imbinarize(IT,it);
                    hhii.CData=imoverlay(imadjust(IT),ITWPtemp,'r');
                end
            case 'leftarrow'
                if it>inc
                    it =it-inc;
                    disp(it)
                    ITWPtemp=imbinarize(IT,it);
                    hhii.CData=imoverlay(imadjust(IT),ITWPtemp,'r');
                end
            case 'space'
                uiresume(ft);
        end
    end

    function rmRegion(src,evt)
    switch evt.Key
        case 'x'
            kk=0;uiresume;
        case 'space'
            uiresume;
    end
    end


end

