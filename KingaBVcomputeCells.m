function outdata=KingaBVcomputeCells(ColocMatPL,ColocMatEP,PLSurf,EPSurf)

PLDat=ColocMatPL';EPDat=ColocMatEP';
PLtot=numel(PLDat);EPtot=numel(EPDat);


GPL=numel(find(PLDat==1));
RPL=numel(find(PLDat==10));
BPL=numel(find(PLDat==100));
GRPL=numel(find(PLDat==11));
GBPL=numel(find(PLDat==101));
RBPL=numel(find(PLDat==110));
GRBPL=numel(find(PLDat==111));

GEP=numel(find(EPDat==1));
REP=numel(find(EPDat==10));
BEP=numel(find(EPDat==100));
GREP=numel(find(EPDat==11));
GBEP=numel(find(EPDat==101));
RBEP=numel(find(EPDat==110));
GRBEP=numel(find(EPDat==111));
Frac=zeros(4,8);
Frac(1,:)=[PLtot GPL RPL BPL GRPL GBPL RBPL GRBPL];
Frac(2,:)=[PLtot GPL RPL BPL GRPL GBPL RBPL GRBPL]/PLtot;
Frac(3,:)=[EPtot GEP REP BEP GREP GBEP RBEP GRBEP];
Frac(4,:)=[EPtot GEP REP BEP GREP GBEP RBEP GRBEP]/EPtot;
dPL=horzcat(PLSurf,[GPL RPL BPL GRPL GBPL RBPL GRBPL]/PLSurf) ;

dEP=horzcat(EPSurf ,[GEP REP BEP GREP GBEP RBEP GRBEP]/EPSurf);

fracT=array2table(Frac,'VariableNames',{'Total','GreenOnly','RedOnly','BlueOnly','Green-Red','Green-Blue','Red-Blue','Green-Red-Blue'},...
    'RowNames',{'LPRaw','LPFraction','EPRaw','EPFraction'});
denT=array2table([dPL;dEP],'VariableNames',{'Area(mm2)','GreenOnly','RedOnly','BlueOnly','Green-Red','Green-Blue','Red-Blue','Green-Red-Blue'},...
    'RowNames',{'Lamina Propria','Epithelium'});

outdata.fraction=fracT;
outdata.density=denT;

