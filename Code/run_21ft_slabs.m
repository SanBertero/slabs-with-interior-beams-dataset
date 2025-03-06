%% Previa
% Borrar todo
clear;
clc;

tic
%% Input
% Iterated Input
beta = [1.0 1.2 1.4 1.6 1.8 2.0];
alpha = [0 0.5 1.0 2.0 4.0 8.0 12.0 16.0];
% beta = 2;
% alpha = 8.774;
filename = 'RunDataInteriorBeams_21ft.mat';

% Fixed Input
BEAMSATT = "YES";
BEAMEFFECT = "NO";
DROP = "NO";
INTERIOR = "YES";

Losas = cell(numel(beta),numel(alpha));

for nn = 1:numel(beta)
for jj = 1:numel(alpha)
%% DATOS DEL MODELO
% numero de niveles
n = 2;
% Luces
Ly = 21; % ft
Lx = Ly/beta(nn); % ft
% Vanos
Nx = 3;
Ny = 3;
% Altura de entrepisos
hp = 12; % ft

% Lado de columnas
ax = ceil(Lx/10*12/2)*2; % in
ay = ceil(Ly/10*12/2)*2; % in

% Cargas
gD = 30; % lb/ft2
gL = 80; % lb/ft2

% Creep coefficient
lambda = 2;
% Shrinkage Coefficient
sc = 0.0005;
% sc = 0.0000;

if alpha(jj)~=0 && strcmp(BEAMSATT,"YES")
    BEAMS = "YES";
else
    BEAMS = "NO";
end

if strcmp(DROP,"YES")
    if strcmp(BEAMS,"YES")
        % Espesor de losa
        % hl = ceil(max(Lx-ax/12,Ly-ay/12)/36*12/0.25)*0.25; % in (Losa c/vigas)
        % if hl>6
        %     hl = ceil(max(Lx-ax/12,Ly-ay/12)/36*12/0.5)*0.5; % in (Losa c/vigas)
        % end
        
        if strcmp(BEAMEFFECT,"YES")
            hl = max(max(Lx-ax/12,Ly-ay/12)/36*12,4);
        else
            hl = max(max(Lx-ax/12,Ly-ay/12)/33*12,4);
        end

        % Dimensiones de viga
        [hvxe,bvxe] = findExteriorBeam(hl,Ly*12,alpha(jj));
        [hvye,bvye] = findExteriorBeam(hl,Lx*12,alpha(jj));
        
    else
        % Espesor de losa
        % hl = ceil(max(Lx-ax/12,Ly-ay/12)/33*12/0.25)*0.25; % in (Losa c/vigas)
        % if hl>6
        %     hl = ceil(max(Lx-ax/12,Ly-ay/12)/33*12/0.5)*0.5; % in (Losa c/vigas)
        % end

        hl = max(max(Lx-ax/12,Ly-ay/12)/33*12,4);
    end

    % Espesor del capitel
    hd = ceil(1.25*hl/0.25)*0.25;
    if (hd-hl)>6
        hd = ceil(1.25*hl/0.5)*0.5; % in (Losa c/vigas)
    end

elseif strcmp(BEAMS,"YES")
    % Espesor de losa
    % hl = ceil(max(Lx-ax/12,Ly-ay/12)/33*12/0.25)*0.25; % in (Losa c/vigas)
    % if hl>6
    %     hl = ceil(max(Lx-ax/12,Ly-ay/12)/33*12/0.5)*0.5; % in (Losa c/vigas)
    % end

    if strcmp(INTERIOR,"YES")
        if alpha(jj)>2
            hl = max(max(Lx-ax/12,Ly-ay/12)*12*(0.8+60000/200000)/(36+9*beta(nn)),3.5);
        elseif alpha(jj)>0.2
            hl = max(max(Lx-ax/12,Ly-ay/12)*12*(0.8+60000/200000)/(36+5*beta(nn)*(alpha(jj)-0.2)),5);
        else
            hl = max(max(Lx-ax/12,Ly-ay/12)/33*12,5);
        end

        [hvxi,bvxi,hvyi,bvyi,alphax,alphay] = findCentralBeams(hl,Lx*12,Ly*12,alpha(jj));
        [hvxe,bvxe] = findExteriorBeam(hl,Ly*12,alphax);
        [hvye,bvye] = findExteriorBeam(hl,Lx*12,alphay);

    elseif strcmp(BEAMEFFECT,"YES")
        hl = max(max(Lx-ax/12,Ly-ay/12)/33*12,5);

        [hvxe,bvxe] = findExteriorBeam(hl,Ly*12,alpha(jj));
        [hvye,bvye] = findExteriorBeam(hl,Lx*12,alpha(jj));
    else
        hl = max(max(Lx-ax/12,Ly-ay/12)/30*12,5);

        [hvxe,bvxe] = findExteriorBeam(hl,Ly*12,alpha(jj));
        [hvye,bvye] = findExteriorBeam(hl,Lx*12,alpha(jj));
    end

    % Dimensiones de viga
    % hv = ceil(2*hl/2)*2; % in
    % bv = hv; % in

else
    % Espesor de losa
    % hl = ceil(max(Lx-ax/12,Ly-ay/12)/30*12/0.25)*0.25; % in (Losa s/vigas)
    % if hl>6
    %     hl = ceil(max(Lx-ax/12,Ly-ay/12)/30*12/0.5)*0.5; % in (Losa s/vigas)
    % end

    hl = max(max(Lx-ax/12,Ly-ay/12)/30*12,5);
end

%% Arranque
% true() para usar un programa abierto, false() para abrir una instancia de
% SAFE nueva
AttachToInstance = false(); 

% true() para especificar el path a SAFE, false() para usar la version mas
% nueva instalada
SpecifyPath = false(); 

% En caso de true(), definir el path
ProgramPath = 'C:\Program Files\Computers and Structures\SAFE 21\SAFE.exe';

% Path completo al API
APIDLLPath = 'C:\Program Files\Computers and Structures\SAFE 21\SAFEv1.dll';

% Path donde guardar el modelo
ModelDirectory = 'C:\Users\santi\OneDrive - fi.uba.ar\Desktop\Losas';
if ~exist(ModelDirectory, 'dir')
    mkdir(ModelDirectory);
end

ModelName = 'SAFE_API_Example_2.sdb';
ModelPath = strcat(ModelDirectory, filesep, ModelName);

% API helper object
a = NET.addAssembly(APIDLLPath);
helper = SAFEv1.Helper;
helper = NET.explicitCast(helper,'SAFEv1.cHelper');

if AttachToInstance
    % entrar en instancia abierta de SAFE
    SafeObject = helper.GetObject('CSI.SAFE.API.ETABSObject');
    SafeObject = NET.explicitCast(SafeObject,'SAFEv1.cOAPI');
else
    if SpecifyPath
        % abrir instancia de SAFE en Path especificado
        SafeObject = helper.CreateObject(ProgramPath);
    else
        % abrir version mas reciente de SAFE
        SafeObject = helper.CreateObjectProgID('CSI.SAFE.API.ETABSObject');
    end
    SafeObject = NET.explicitCast(SafeObject,'SAFEv1.cOAPI');
    % Abrir SAFE
    SafeObject.ApplicationStart;
end
helper = 0; 

%% Crear Modelo
SapModel = NET.explicitCast(SafeObject.SapModel,'SAFEv1.cSapModel');

% inicializar modelo
ret = SapModel.InitializeNewModel;

% Crear modelo con template de grilla
File = NET.explicitCast(SapModel.File,'SAFEv1.cFile');
ret = File.NewGridOnly(n, hp, hp, Nx+1, Ny+1, Lx, Ly);

%% Tablas para modificar el database a mano
DatabaseTables = NET.explicitCast(SapModel.DatabaseTables,'SAFEv1.cDatabaseTables');

NumberTables = 0;
TableKey = [];
TableName = [];
ImportType = [];
IsEmpty = [];

[ret, NumberTables, TableKey, TableName, ImportType, IsEmpty] = DatabaseTables.GetAllTables(NumberTables, TableKey, TableName, ImportType, IsEmpty);

%% Propiedades del Material
% Uso las default (4000psi)
PropMaterial = NET.explicitCast(SapModel.PropMaterial,'SAFEv1.cPropMaterial');

%% Propiedades de las secciones
PropFrame = NET.explicitCast(SapModel.PropFrame,'SAFEv1.cPropFrame');
PropArea = NET.explicitCast(SapModel.PropArea,'SAFEv1.cPropArea');

% Columnas
ret = PropFrame.SetRectangle('Cols', '4000psi', ax, ay);

% Losa
ret = PropArea.SetSlab('Slabs', SAFEv1.eSlabType.Slab, SAFEv1.eShellType.ShellThick, '4000psi', hl);

%% Crear elementos
% Columnas
FrameObj = NET.explicitCast(SapModel.FrameObj,'SAFEv1.cFrameObj');
PointObj = NET.explicitCast(SapModel.PointObj,'SAFEv1.cPointObj');

% Condiciones de vinculo
PointName1 = "";
PointName2 = "";
Restraint = NET.createArray('System.Boolean',6);
for i=1:6
    Restraint(i) = true();
end

% crear columnas
for i=1:Nx+1
    for j=1:Ny+1
        FrameName = "";
        x = (i-1)*Lx*12;
        y = (j-1)*Ly*12;
        
        % Col inf
        [ret, FrameName] = FrameObj.AddByCoord(x, y, -hp*12, x, y, 0, FrameName,'Cols', "", 'Global');
        [ret, PointName1, PointName2] = FrameObj.GetPoints(FrameName, PointName1, PointName2);
        ret = PointObj.SetRestraint(PointName1, Restraint);
        
        % Col sup
        [ret, FrameName] = FrameObj.AddByCoord(x, y, 0, x, y, hp*12, FrameName,'Cols', "", 'Global');
        [ret, PointName1, PointName2] = FrameObj.GetPoints(FrameName, PointName1, PointName2);
        ret = PointObj.SetRestraint(PointName2, Restraint);
    end
end

% losas
AreaObj = NET.explicitCast(SapModel.AreaObj,'SAFEv1.cAreaObj');

xs = [-ax/2,Nx*Lx*12+ax/2,Nx*Lx*12+ax/2,-ax/2];
ys = [-ay/2,-ay/2,Ny*Ly*12+ay/2,Ny*Ly*12+ay/2];
zs = [0,0,0,0];
AreaName = "";
[ret, xs, ys, zs, AreaName] = AreaObj.AddByCoord(4, xs, ys, zs, AreaName, 'Slabs', "", 'Global');
% Agregar cargas
ret = AreaObj.SetLoadUniform(AreaName, 'DEAD', gD/144/1000, 10);
ret = AreaObj.SetLoadUniform(AreaName, 'LIVE', gL/144/1000, 10);

% Drop panels
if strcmp(DROP,"YES")
    % Crear Drop
    ret = PropArea.SetSlab('Drops', SAFEv1.eSlabType.Drop, SAFEv1.eShellType.ShellThick, '4000psi', hd);

    if strcmp(BEAMS,"YES")
        i_ini = 2;
        i_fin = Nx;
        j_ini = 2;
        j_fin = Ny;
    else
        i_ini = 1;
        i_fin = Nx+1;
        j_ini = 1;
        j_fin = Ny+1;
    end

    for i=i_ini:i_fin
        for j=j_ini:j_fin
            AreaName = "";
            xc = (i-1)*Lx*12;
            yc = (j-1)*Ly*12;

            xs = min(max(xc+12*[-Lx/6,Lx/6,Lx/6,-Lx/6],-ax/2),Nx*Lx*12+ax/2);
            ys = min(max(yc+12*[-Ly/6,-Ly/6,Ly/6,Ly/6],-ay/2),Ny*Ly*12+ay/2);
            zs = [0,0,0,0];
                        
            % losa
            [ret, xs, ys, zs, AreaName] = AreaObj.AddByCoord(4, xs, ys, zs, AreaName, 'Drops', "", 'Global');
        end
    end
end

% Cambiar cardinal point de la losa
SelectedTable = 'Area Assignments - Insertion Point';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

for i=1:NumberRecords
    TableData((i-1)*FieldsKeysIncluded.Length+2) = "Top"; % Insertion Point
end

FillImportLog = true();
NumFatalErrors = 0;
NumErrorsMsgs = 0;
NumWarnMsgs = 0;
NumInfoMsgs = 0;
ImportLog = [];

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

%% Agregar estados de carga no lineales
SelectedTable = 'Load Case Definitions - Nonlinear Static';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

NumberRecords = 2;
TableLength = FieldsKeysIncluded.Length * NumberRecords - 1;
TableData = string([]);

% D short
TableData(1) = "D-short"; % Name of case
TableData(5) = "Load Pattern"; % Load type
TableData(6) = "DEAD"; % Load name
TableData(7) = "1"; % Load scale factor
TableData(31) = "Short Term"; % Creep & Shrinkage

% D+L short
TableData(1+FieldsKeysIncluded.Length) = "D+L-short"; % Name of case
TableData(5+FieldsKeysIncluded.Length) = "Load Pattern"; % Load type
TableData(6+FieldsKeysIncluded.Length) = "DEAD"; % Load name
TableData(7+FieldsKeysIncluded.Length) = "1"; % Load scale factor
TableData(31+FieldsKeysIncluded.Length) = "Short Term"; % Creep & Shrinkage
TableData(1+2*FieldsKeysIncluded.Length) = "D+L-short"; % Name of case
TableData(5+2*FieldsKeysIncluded.Length) = "Load Pattern"; % Load type
TableData(6+2*FieldsKeysIncluded.Length) = "Live"; % Load name
TableData(7+2*FieldsKeysIncluded.Length) = "1"; % Load scale factor

% D long
TableData(1+3*FieldsKeysIncluded.Length) = "D-long"; % Name of case
TableData(5+3*FieldsKeysIncluded.Length) = "Load Pattern"; % Load type
TableData(6+3*FieldsKeysIncluded.Length) = "DEAD"; % Load name
TableData(7+3*FieldsKeysIncluded.Length) = "1"; % Load scale factor
TableData(31+3*FieldsKeysIncluded.Length) = "Long Term"; % Creep & Shrinkage
TableData(32+3*FieldsKeysIncluded.Length) = "User Specified"; % Long Term Options
TableData(35+3*FieldsKeysIncluded.Length) = string(lambda); % Creep Coefficient
TableData(36+3*FieldsKeysIncluded.Length) = string(sc); % Creep Coefficient

FillImportLog = true();
NumFatalErrors = 0;
NumErrorsMsgs = 0;
NumWarnMsgs = 0;
NumInfoMsgs = 0;
ImportLog = [];

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

%% Agregar combinaciones de carga
SelectedTable = 'Load Combination Definitions';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

TableData = string([]);

% L short
TableData(1) = "L-short"; % Name of case
TableData(2) = "Linear Add"; % Combination type
TableData(4) = "D+L-short"; % Load name
TableData(6) = "1"; % Load scale factor
TableData(1+FieldsKeysIncluded.Length) = "L-short"; % Name of case
TableData(4+FieldsKeysIncluded.Length) = "D-short"; % Load name
TableData(6+FieldsKeysIncluded.Length) = string(-1); % Load scale factor

% D+L sus
TableData(1+2*FieldsKeysIncluded.Length) = "D+L-sus"; % Name of case
TableData(2+2*FieldsKeysIncluded.Length) = "Linear Add"; % Combination type
TableData(4+2*FieldsKeysIncluded.Length) = "D+L-short"; % Load name
TableData(6+2*FieldsKeysIncluded.Length) = "1"; % Load scale factor
TableData(1+3*FieldsKeysIncluded.Length) = "D+L-sus"; % Name of case
TableData(4+3*FieldsKeysIncluded.Length) = "D-short"; % Load name
TableData(6+3*FieldsKeysIncluded.Length) = string(-1); % Load scale factor
TableData(1+4*FieldsKeysIncluded.Length) = "D+L-sus"; % Name of case
TableData(4+4*FieldsKeysIncluded.Length) = "D-long"; % Load name
TableData(6+4*FieldsKeysIncluded.Length) = "1"; % Load scale factor

FillImportLog = true();
NumFatalErrors = 0;
NumErrorsMsgs = 0;
NumWarnMsgs = 0;
NumInfoMsgs = 0;
ImportLog = [];

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

%% Agregar puntos para Middle Strips
for i = 1:Nx
    PointName = "";
    x = (i-1/2)*Lx*12;

    [ret, PointName] = PointObj.AddCartesian(x,-ay/2,0,PointName);

    [ret, PointName] = PointObj.AddCartesian(x,Ny*Ly*12+ay/2,0,PointName);

    [ret, PointName] = PointObj.AddCartesian(x,0,0,PointName);
    % ret = PointObj.SetSpecialPoint(PointName,false());

    [ret, PointName] = PointObj.AddCartesian(x,Ny*Ly*12,0,PointName);
    % ret = PointObj.SetSpecialPoint(PointName,false());
end
for i = 1:Ny
    PointName = "";
    y = (i-1/2)*Ly*12;

    [ret, PointName] = PointObj.AddCartesian(-ax/2,y,0,PointName);

    [ret, PointName] = PointObj.AddCartesian(Nx*Lx*12+ax/2,y,0,PointName);

    [ret, PointName] = PointObj.AddCartesian(0,y,0,PointName);
    % ret = PointObj.SetSpecialPoint(PointName,false());

    [ret, PointName] = PointObj.AddCartesian(Nx*Lx*12,y,0,PointName);
    % ret = PointObj.SetSpecialPoint(PointName,false());
end

%% Agregar Puntos para Column Strips
for i = 1:Nx+1
    PointName = "";
    x = (i-1)*Lx*12;

    [ret, PointName] = PointObj.AddCartesian(x,-ay/2,0,PointName);

    [ret, PointName] = PointObj.AddCartesian(x,Ny*Ly*12+ay/2,0,PointName);
end
for i = 1:Ny+1
    PointName = "";
    y = (i-1)*Ly*12;

    [ret, PointName] = PointObj.AddCartesian(-ax/2,y,0,PointName);

    [ret, PointName] = PointObj.AddCartesian(Nx*Lx*12+ax/2,y,0,PointName);
end

%% Agregar Strips de Diseno
% Obtener Matriz con los puntos de la estructura
SelectedTable = 'Point Object Connectivity';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

FieldsKeyList =[];
GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, FieldsKeyList, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForDisplayArray(SelectedTable, FieldsKeyList, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

Data_array = string(TableData);
ncols = FieldsKeysIncluded.Length;
Data_array = reshape(Data_array,ncols,[])';

% Asignar Strips
SelectedTable = 'Strip Object Connectivity';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

NumberRecords = 2*Nx+1+2*Ny+1;
TableLength = FieldsKeysIncluded.Length * NumberRecords - 1;
TableData = string([]);

count = 0;
% Agregar column strips en X
for i = 1:Ny+1
    % Agregar a Tabla
    TableData(1+count*FieldsKeysIncluded.Length) = string(['CSA' num2str(i)]);
    TableData(9+count*FieldsKeysIncluded.Length) = "A";

    % Encontrar puntos
    TableData(2+count*FieldsKeysIncluded.Length) = Data_array(sum(Data_array(:,[4 5 6])==[string(-ax/2) string((i-1)*Ly*12) string(0)],2)==3,1);
    TableData(3+count*FieldsKeysIncluded.Length) = Data_array(sum(Data_array(:,[4 5 6])==[string(Nx*Lx*12+ax/2) string((i-1)*Ly*12) string(0)],2)==3,1);

    % Ancho de faja
    if i==1
        TableData(4+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
        TableData(6+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
        TableData(5+count*FieldsKeysIncluded.Length) = string(ay/2);
        TableData(7+count*FieldsKeysIncluded.Length) = string(ay/2);
    elseif i==Ny+1
        TableData(4+count*FieldsKeysIncluded.Length) = string(ay/2);
        TableData(6+count*FieldsKeysIncluded.Length) = string(ay/2);
        TableData(5+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
        TableData(7+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
    else
        TableData(4+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
        TableData(6+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
        TableData(5+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
        TableData(7+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
    end

    count = count +1;
end

% Agregar column strips en Y
for i = 1:Nx+1
    % Agregar a Tabla
    TableData(1+count*FieldsKeysIncluded.Length) = string(['CSB' num2str(i)]);
    TableData(9+count*FieldsKeysIncluded.Length) = "B";

    % Encontrar puntos
    TableData(2+count*FieldsKeysIncluded.Length) = Data_array(sum(Data_array(:,[4 5 6])==[string((i-1)*Lx*12) string(-ay/2) string(0)],2)==3,1);
    TableData(3+count*FieldsKeysIncluded.Length) = Data_array(sum(Data_array(:,[4 5 6])==[string((i-1)*Lx*12) string(Ny*Ly*12+ay/2) string(0)],2)==3,1);

    % Ancho de faja
    if i==Ny+1
        TableData(4+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
        TableData(6+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
        TableData(5+count*FieldsKeysIncluded.Length) = string(ax/2);
        TableData(7+count*FieldsKeysIncluded.Length) = string(ax/2);
    elseif i==1
        TableData(4+count*FieldsKeysIncluded.Length) = string(ax/2);
        TableData(6+count*FieldsKeysIncluded.Length) = string(ax/2);
        TableData(5+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
        TableData(7+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
    else
        TableData(4+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
        TableData(6+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
        TableData(5+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
        TableData(7+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
    end

    count = count +1;
end

% Agregar Middle Strips en X
for i = 1:Ny
    % Agregar a Tabla
    TableData(1+count*FieldsKeysIncluded.Length) = string(['MSA' num2str(i)]);
    TableData(9+count*FieldsKeysIncluded.Length) = "A";

    % Encontrar puntos
    TableData(2+count*FieldsKeysIncluded.Length) = Data_array(sum(Data_array(:,[4 5 6])==[string(-ax/2) string((i-1/2)*Ly*12) string(0)],2)==3,1);
    TableData(3+count*FieldsKeysIncluded.Length) = Data_array(sum(Data_array(:,[4 5 6])==[string(Nx*Lx*12+ax/2) string((i-1/2)*Ly*12) string(0)],2)==3,1);

    % Ancho de faja
    TableData(4+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
    TableData(6+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
    TableData(5+count*FieldsKeysIncluded.Length) = string(Ly/4*12);
    TableData(7+count*FieldsKeysIncluded.Length) = string(Ly/4*12);

    count = count +1;
end

% Agregar Middle strips en Y
for i = 1:Nx
    % Agregar a Tabla
    TableData(1+count*FieldsKeysIncluded.Length) = string(['MSB' num2str(i)]);
    TableData(9+count*FieldsKeysIncluded.Length) = "B";

    % Encontrar puntos
    TableData(2+count*FieldsKeysIncluded.Length) = Data_array(sum(Data_array(:,[4 5 6])==[string((i-1/2)*Lx*12) string(-ay/2) string(0)],2)==3,1);
    TableData(3+count*FieldsKeysIncluded.Length) = Data_array(sum(Data_array(:,[4 5 6])==[string((i-1/2)*Lx*12) string(Ny*Ly*12+ay/2) string(0)],2)==3,1);

    % Ancho de faja
    TableData(4+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
    TableData(6+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
    TableData(5+count*FieldsKeysIncluded.Length) = string(Lx/4*12);
    TableData(7+count*FieldsKeysIncluded.Length) = string(Lx/4*12);

    count = count +1;
end

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

% Setear Middle Strips Correctamente
SelectedTable = 'Concrete Slab Design Overwrites - Strip Based';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

Data_array = reshape(string(TableData),FieldsKeysIncluded.Length,[])';
for i=1:NumberRecords
    if strncmpi(Data_array(i,1),"M",1)==true()
       TableData((i-1)*FieldsKeysIncluded.Length+3) = "Middle Strip";
    end
end

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

%% Agregar intersecciones rigidas
SelectedTable = 'Frame Section Property Definitions - Concrete Rectangular';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

Data_array = reshape(string(TableData),FieldsKeysIncluded.Length,[])';

idx = find(string(TableData)=="Cols");
TableData(idx+7) = "Yes"; % Rigid?

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

%% AGREGAR VIGAS DE BORDE
if strcmp(BEAMS,"YES")
    % Editar seccion de viga
    SelectedTable = 'Frame Section Property Definitions - Concrete Rectangular';
    TableVersion = 0;
    NumberFields = 0;
    FieldKey = [];
    FieldName = [];
    Description = [];
    UnitsString = [];
    IsImportable = [];
    
    [ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);
    
    GroupName = [];
    FieldsKeysIncluded = [];
    NumberRecords = 0;
    TableData = [];
    
    [ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
    
    Data_array = reshape(string(TableData),FieldsKeysIncluded.Length,[])';

    idx = find(string(Data_array(:,1))=="ConcBm");
    Data_array = [Data_array; Data_array(idx,:); Data_array(idx,:); Data_array(idx,:); Data_array(idx,:)];
    
    Data_array(end-1,[1 6 7]) = ["ConcBmExtx" hvxe bvxe];
    Data_array(end,[1 6 7])   = ["ConcBmExty" hvye bvye];
    if strcmp(INTERIOR,"YES")
        Data_array(end-3,[1 6 7]) = ["ConcBmIntx" hvxi bvxi];
        Data_array(end-2,[1 6 7]) = ["ConcBmInty" hvyi bvyi];
    else
        Data_array(end-3,1) = "ConcBmIntx";
        Data_array(end-2,1) = "ConcBmInty";
    end
    
    % idx = find(string(TableData)=="ConcBm");
    % TableData(idx+5) = string(hv); % Altura
    % TableData(idx+6) = string(bv); % Ancho
    TableData = reshape(Data_array',[],1)';
    
    [ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
    [ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

    % Agregar vigas en el perimetro
    for i=1:Nx
        FrameName = "";
        x1 = (i-1)*Lx*12;
        x2 = i*Lx*12;
        
        % Beam Y=0
        [ret, FrameName] = FrameObj.AddByCoord(x1, 0, 0, x2, 0, 0, FrameName,'ConcBmExtx', "", 'Global');
        
        % Beam Y=end
        [ret, FrameName] = FrameObj.AddByCoord(x1, Ny*Ly*12, 0, x2, Ny*Ly*12, 0, FrameName,'ConcBmExtx', "", 'Global');
    end
    for i=1:Ny
        FrameName = "";
        y1 = (i-1)*Ly*12;
        y2 = i*Ly*12;
        
        % Beam X=0
        [ret, FrameName] = FrameObj.AddByCoord(0, y1, 0, 0, y2, 0, FrameName,'ConcBmExty', "", 'Global');
        
        % Beam X=end
        [ret, FrameName] = FrameObj.AddByCoord(Nx*Lx*12, y1, 0, Nx*Lx*12, y2, 0, FrameName,'ConcBmExty', "", 'Global');
    end

    % Ajustar insertion point de las vigas
    SelectedTable = 'Frame Assignments - Insertion Point';
    TableVersion = 0;
    NumberFields = 0;
    FieldKey = [];
    FieldName = [];
    Description = [];
    UnitsString = [];
    IsImportable = [];
    
    [ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);
    
    GroupName = [];
    FieldsKeysIncluded = [];
    NumberRecords = 0;
    TableData = [];
    
    [ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
    
    for i=1:NumberRecords
        if str2double(string(TableData((i-1)*FieldsKeysIncluded.Length+1)))>(Nx+1)*(Ny+1)*2
            TableData((i-1)*FieldsKeysIncluded.Length+2) = "8 (Top Center)"; % Insertion Point
        end
    end
    
    FillImportLog = true();
    NumFatalErrors = 0;
    NumErrorsMsgs = 0;
    NumWarnMsgs = 0;
    NumInfoMsgs = 0;
    ImportLog = [];
    
    [ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
    [ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);
end

%% AGREGAR VIGAS INTERIORES
if strcmp(INTERIOR,"YES")
    % Agregar vigas en el perimetro
    for j=1:Ny-1
        for i=1:Nx
            FrameName = "";
            x1 = (i-1)*Lx*12;
            x2 = i*Lx*12;
            
            % Beam Y=0
            [ret, FrameName] = FrameObj.AddByCoord(x1, j*Ly*12, 0, x2, j*Ly*12, 0, FrameName,'ConcBmIntx', "", 'Global');
        end
    end
    for j=1:Nx-1
        for i=1:Ny
            FrameName = "";
            y1 = (i-1)*Ly*12;
            y2 = i*Ly*12;
            
            % Beam X=0
            [ret, FrameName] = FrameObj.AddByCoord(j*Lx*12, y1, 0, j*Lx*12, y2, 0, FrameName,'ConcBmInty', "", 'Global');
        end
    end

    % Ajustar insertion point de las vigas
    SelectedTable = 'Frame Assignments - Insertion Point';
    TableVersion = 0;
    NumberFields = 0;
    FieldKey = [];
    FieldName = [];
    Description = [];
    UnitsString = [];
    IsImportable = [];
    
    [ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);
    
    GroupName = [];
    FieldsKeysIncluded = [];
    NumberRecords = 0;
    TableData = [];
    
    [ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
    
    for i=1:NumberRecords
        if str2double(string(TableData((i-1)*FieldsKeysIncluded.Length+1)))>(Nx+1)*(Ny+1)*2
            TableData((i-1)*FieldsKeysIncluded.Length+2) = "8 (Top Center)"; % Insertion Point
        end
    end
    
    FillImportLog = true();
    NumFatalErrors = 0;
    NumErrorsMsgs = 0;
    NumWarnMsgs = 0;
    NumInfoMsgs = 0;
    ImportLog = [];
    
    [ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
    [ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);
end


% %% Mallado
% % Mesh setting
% SelectedTable = 'Area Assignments - Floor Auto Mesh Options';
% TableVersion = 0;
% NumberFields = 0;
% FieldKey = [];
% FieldName = [];
% Description = [];
% UnitsString = [];
% IsImportable = [];
% 
% [ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);
% 
% GroupName = [];
% FieldsKeysIncluded = [];
% NumberRecords = 0;
% TableData = [];
% 
% [ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
% 
% for i=1:NumberRecords
%     if strcmp(string(TableData(1+(i-1)*FieldsKeysIncluded.Length)),"1")
%         TableData(2+(i-1)*FieldsKeysIncluded.Length) = "Auto Cookie Cut"; % Mesh Type
%         TableData(5+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % At Beams
%         TableData(6+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % At Walls
%         TableData(7+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % At Grids
%         TableData(8+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % Submesh
%         TableData(9+(i-1)*FieldsKeysIncluded.Length) = string(min(Lx,Ly)/20*12); % Max SubMesh size
%     end
% end
% 
% [ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
% [ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

%% Setear el tamano del mallado
SelectedTable = 'Analysis Options - Automatic Mesh Settings for Floors';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

TableData(1) = "Rectangular"; % Mesh Type
TableData(2) = "Yes"; % Localized Meshing
TableData(3) = "Yes"; % Merge Joints
TableData(4) = string(min(Lx,Ly)/20*12); % Max Mesh size

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);


%% Hacer lo mismo para columnas y vigas
SelectedTable = 'Analysis Options - Automatic Rectangular Mesh Options for Walls';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

TableData(1) = string(min(Lx,Ly)/20*12); % Max Mesh size

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

SelectedTable = 'Frame Assignments - Frame Auto Mesh Options';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

for i=1:NumberRecords
    % TableData(1) = "1"; % Name
    TableData(2+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % Mesh Type
    TableData(3+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % At Joints
    TableData(4+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % At Intersections
    TableData(5+(i-1)*FieldsKeysIncluded.Length) = "No"; % Min Number
    TableData(7+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % Max Length
    TableData(8+(i-1)*FieldsKeysIncluded.Length) = string(min(Lx,Ly)/20*12); % Max Mesh size
end

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);


%% Agregar puntos clave faltantes para desplazamientos
for i = 1:Nx
    for j=1:Ny-1
        PointName = "";
        x = (i-1/2)*Lx*12;
        y = j*Ly*12;

        [ret, PointName] = PointObj.AddCartesian(x,y,0,PointName);
        % ret = PointObj.SetSpecialPoint(PointName,false());
    end
end
for i = 1:Ny
    for j=1:Nx-1
        PointName = "";
        y = (i-1/2)*Ly*12;
        x = j*Lx*12;

        [ret, PointName] = PointObj.AddCartesian(x,y,0,PointName);
        % ret = PointObj.SetSpecialPoint(PointName,false());
    end
end
for i = 1:Nx
    for j=1:Ny
        PointName = "";
        x = (i-1/2)*Lx*12;
        y = (j-1/2)*Ly*12;

        [ret, PointName] = PointObj.AddCartesian(x,y,0,PointName);
        % ret = PointObj.SetSpecialPoint(PointName,false());
    end
end

%% Icluir puntos en MESH
% Levantar nombres de todos los puntos
SelectedTable = 'Joint Assignments - Summary';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, FieldsKeyList, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForDisplayArray(SelectedTable, FieldsKeyList, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

NumJoints = NumberRecords;

% Agregarlos en el mesh
SelectedTable = 'Joint Assignments - Floor Meshing Option';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForEditingArray(SelectedTable, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

TableData = string([]);
for i=1:NumJoints
    TableData(1+(i-1)*FieldsKeysIncluded.Length) = string(i); % Label
    TableData(2+(i-1)*FieldsKeysIncluded.Length) = "Yes"; % Add to Mesh
end

[ret, TableVersion, TableData] = DatabaseTables.SetTableForEditingArray(SelectedTable, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);
[ret, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog] = DatabaseTables.ApplyEditedTables(FillImportLog, NumFatalErrors, NumErrorsMsgs, NumWarnMsgs, NumInfoMsgs, ImportLog);

%% Correr Estructura PARA DISENAR
ret = File.Save(ModelPath);
Analyze = NET.explicitCast(SapModel.Analyze,'SAFEv1.cAnalyze');

% Elegir casos
% ret = Analyze.SetRunCaseFlag([],false(),true());
% ret = Analyze.SetRunCaseFlag("Dead",true());
% ret = Analyze.SetRunCaseFlag("Live",true());
% ret = Analyze.SetRunCaseFlag("DConS1",true());
% ret = Analyze.SetRunCaseFlag("DConS2",true());

ret = Analyze.RunAnalysis;

% Disenar Estructura
DesignConcreteSlab = NET.explicitCast(SapModel.DesignConcreteSlab,'SAFEv1.cDesignConcreteSlab');
ret = DesignConcreteSlab.StartSlabDesign;

if strcmp(BEAMS,"YES")
    DesignConcrete = NET.explicitCast(SapModel.DesignConcrete,'SAFEv1.cDesignConcrete');
    ret = DesignConcrete.StartDesign;
end

% Correr los casos NO LINEALES
% ret = Analyze.SetRunCaseFlag([],true(),true());

ret = File.Save(ModelPath);
% Analyze = NET.explicitCast(SapModel.Analyze,'SAFEv1.cAnalyze');
ret = Analyze.RunAnalysis;

% DesignConcreteSlab = NET.explicitCast(SapModel.DesignConcreteSlab,'SAFEv1.cDesignConcreteSlab');
ret = DesignConcreteSlab.StartSlabDesign;

if strcmp(BEAMS,"YES")
    % DesignConcrete = NET.explicitCast(SapModel.DesignConcrete,'SAFEv1.cDesignConcrete');
    ret = DesignConcrete.StartDesign;
end

%% Extraer Desplazamientos
SelectedTable = 'Joint Displacements';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, FieldsKeyList, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForDisplayArray(SelectedTable, FieldsKeyList, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

% Ordenar como Tabla
Data_array_Disp = reshape(string(TableData),FieldsKeysIncluded.Length,[])';
Table_Disp = array2table(Data_array_Disp,'VariableNames',string(FieldsKeysIncluded));

%% Extraer numeracion de puntos
SelectedTable = 'Objects and Elements - Joints';
TableVersion = 0;
NumberFields = 0;
FieldKey = [];
FieldName = [];
Description = [];
UnitsString = [];
IsImportable = [];

[ret, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable] = DatabaseTables.GetAllFieldsInTable(SelectedTable, TableVersion, NumberFields, FieldKey, FieldName, Description, UnitsString, IsImportable);

GroupName = [];
FieldsKeysIncluded = [];
NumberRecords = 0;
TableData = [];

[ret, FieldsKeyList, TableVersion, FieldsKeysIncluded, NumberRecords, TableData] = DatabaseTables.GetTableForDisplayArray(SelectedTable, FieldsKeyList, GroupName, TableVersion, FieldsKeysIncluded, NumberRecords, TableData);

% Ordenar como Tabla
Data_array_Joints = reshape(string(TableData),FieldsKeysIncluded.Length,[])';
Table_Joints = array2table(Data_array_Joints,'VariableNames',string(FieldsKeysIncluded));

%% Identificar Puntos Clave
% Listado de puntos de interes
Xv = string((0:Lx/2:Nx*Lx)*12);
Yv = string((0:Ly/2:Ny*Ly)*12);
Z = string(0);
List = combinations(Xv,Yv,Z);

% Encontrar el nombre de los puntos
idx = find(ismember(Table_Joints{:,[4 5 6]},List{:,:},"rows"));
Names = Table_Joints{idx,"ObjName"};
XY = Table_Joints{idx,["GlobalX" "GlobalY"]};

%% Identificar los puntos en la tabla de desplazamientos
% Filas con puntos clave
idx2 = find(ismember(Table_Disp{:,"UniqueName"},Names,"rows"));

% Eliminar el resto
Table_Disp = Table_Disp(idx2,{'UniqueName','OutputCase','StepType','Uz'});

% Eliminar los Casos "StepMin"
Table_Disp = Table_Disp(Table_Disp{:,'StepType'}~="Max",{'UniqueName','OutputCase','StepType','Uz'});

% Reoordenar la Tabla por estado de carga
FinalArray = [];
for i=1:numel(Names)
    if i==1
        VarNames = ["Label" "X [ft]" "Y [ft]" Table_Disp{Table_Disp{:,"UniqueName"}==Names(i),"OutputCase"}'];
    end
    FinalArray = [FinalArray;[Names(i) XY(i,:) Table_Disp{Table_Disp{:,"UniqueName"}==Names(i),"Uz"}']];
end
TableFinal = array2table(str2double(FinalArray),'VariableNames',VarNames);

% Ordenar Tabla
for i=1:numel(TableFinal{:,1})
    sorting(i) = find(ismember(TableFinal{:,[2 3]},str2double(List{i,[1 2]}),"rows"));
end

TableFinal = TableFinal(sorting,:);
TableFinal{:,[2 3]} = TableFinal{:,[2 3]}/12;

%% CHEQUEO
disp(TableFinal)

%% Paneles
% Numero de Paneles
NP = Nx*Ny;

% Definicion de indeces para cada panel
Panel_idx = [];
for i=1:Nx
    for j=1:Ny
        sol1 = (i-1)*2*(2*Ny+1)+(j-1)*2+[1 2 3];
        sol2 = sol1+(2*Ny+1);
        sol3 = sol1+2*(2*Ny+1);
        Panel_idx = [Panel_idx;[sol1 sol2 sol3]];
    end
end

% % Maximo Desplazamiento de Cada Panel
% for i=1:NP
%     NodeIdx = str2double(Table_Joints{:,"GlobalX"})>=TableFinal{Panel_idx(i,1),"X [ft]"}*12 &...
%         str2double(Table_Joints{:,"GlobalX"})<=TableFinal{Panel_idx(i,9),"X [ft]"}*12 &...
%         str2double(Table_Joints{:,"GlobalY"})>=TableFinal{Panel_idx(i,1),"Y [ft]"}*12 &...
%         str2double(Table_Joints{:,"GlobalY"})<=TableFinal{Panel_idx(i,9),"Y [ft]"}*12 &...
%         str2double(Table_Joints{:,"GlobalZ"})==0;
% 
%     PosNodes = Table_Joints{NodeIdx,["GlobalX" "GlobalY"]};
%     DispNodes = Table_Disp{NodeIdx,[""]}
%     [MaxDisp,MaxLoc] = min(TableFinal{Panel_idx(i,:),"D+L-sus"});
% end

%% Calculo de Distorsiones en Paneles
% Long Term
Dist2 = zeros(NP,9);
for i=1:NP
    % Verificacion 1
    p1 = Panel_idx(i,1);
    p2 = Panel_idx(i,2);
    p3 = Panel_idx(i,3);
    Dist2(i,1) = ((TableFinal{p1,"D+L-sus"}+TableFinal{p3,"D+L-sus"})/2-TableFinal{p2,"D+L-sus"})/12/Ly;

    % Verificacion 2
    p1 = Panel_idx(i,1);
    p2 = Panel_idx(i,4);
    p3 = Panel_idx(i,7);
    Dist2(i,2) = ((TableFinal{p1,"D+L-sus"}+TableFinal{p3,"D+L-sus"})/2-TableFinal{p2,"D+L-sus"})/12/Lx;

    % Verificacion 3
    p1 = Panel_idx(i,7);
    p2 = Panel_idx(i,8);
    p3 = Panel_idx(i,9);
    Dist2(i,3) = ((TableFinal{p1,"D+L-sus"}+TableFinal{p3,"D+L-sus"})/2-TableFinal{p2,"D+L-sus"})/12/Ly;

    % Verificacion 4
    p1 = Panel_idx(i,3);
    p2 = Panel_idx(i,6);
    p3 = Panel_idx(i,9);
    Dist2(i,4) = ((TableFinal{p1,"D+L-sus"}+TableFinal{p3,"D+L-sus"})/2-TableFinal{p2,"D+L-sus"})/12/Lx;

    % Verificacion 5
    p1 = Panel_idx(i,4);
    p2 = Panel_idx(i,5);
    p3 = Panel_idx(i,6);
    Dist2(i,5) = ((TableFinal{p1,"D+L-sus"}+TableFinal{p3,"D+L-sus"})/2-TableFinal{p2,"D+L-sus"})/12/Ly;

    % Verificacion 6
    p1 = Panel_idx(i,2);
    p2 = Panel_idx(i,5);
    p3 = Panel_idx(i,8);
    Dist2(i,6) = ((TableFinal{p1,"D+L-sus"}+TableFinal{p3,"D+L-sus"})/2-TableFinal{p2,"D+L-sus"})/12/Lx;
    
    % Verificacion 7
    p1 = Panel_idx(i,1);
    p2 = Panel_idx(i,5);
    p3 = Panel_idx(i,9);
    Dist2(i,7) = ((TableFinal{p1,"D+L-sus"}+TableFinal{p3,"D+L-sus"})/2-TableFinal{p2,"D+L-sus"})/12/norm([Lx Ly]);

    % Verificacion 8
    p1 = Panel_idx(i,3);
    p2 = Panel_idx(i,5);
    p3 = Panel_idx(i,7);
    Dist2(i,8) = ((TableFinal{p1,"D+L-sus"}+TableFinal{p3,"D+L-sus"})/2-TableFinal{p2,"D+L-sus"})/12/norm([Lx Ly]);

    % Verificacion 9 (Proposal Simple)
    p2 = Panel_idx(i,5);
    Locs = TableFinal{Panel_idx(i,:),["X [ft]" "Y [ft]"]};

    [MaxDisp, Ind] = min(TableFinal{Panel_idx(i,:),"D+L-sus"});
    MaxLoc = Locs(Ind,:);
    
    DistPoints = Panel_idx(i,[1 3 7 9]);
    if strcmp(INTERIOR,"YES")
        DistPoints = [DistPoints Panel_idx(i,[2 4 6 8])];
    elseif strcmp(BEAMS,"YES")
        if ismember(i,1:Ny:(Nx-1)*Ny+1)
            DistPoints = [DistPoints Panel_idx(i,4)];
        end
        if ismember(i,Ny:Ny:Nx*Ny)
            DistPoints = [DistPoints Panel_idx(i,6)];
        end
        if ismember(i,1:Ny)
            DistPoints = [DistPoints Panel_idx(i,2)];
        end
        if ismember(i,(Nx-1)*Ny+1:Nx*Ny)
            DistPoints = [DistPoints Panel_idx(i,8)];
        end
    end
    [~,idx] = setdiff(TableFinal{DistPoints,["X [ft]" "Y [ft]"]},MaxLoc,'rows');
    Dist2(i,9) = -MaxDisp/12/2/min(vecnorm(MaxLoc'-TableFinal{DistPoints(idx),["X [ft]" "Y [ft]"]}'));
    Dist2(i,10) = -MaxDisp/12/sqrt(Lx^2+Ly^2);
    Dist2(i,11) = -MaxDisp/12/max(Lx,Ly);
    Dist2(i,12) = -MaxDisp/12/min(Lx,Ly);

    % Verificacion 10 (Proposal Relativo)
    p2 = Panel_idx(i,5);
    Locs = TableFinal{Panel_idx(i,:),["X [ft]" "Y [ft]"]};

    [MaxDisp, Ind] = min(TableFinal{Panel_idx(i,:),"D+L-sus"});
    MaxLoc = Locs(Ind,:);
    
    DistPoints = Panel_idx(i,[1 3 7 9]);
    if strcmp(INTERIOR,"YES")
        DistPoints = [DistPoints Panel_idx(i,[2 4 6 8])];
    elseif strcmp(BEAMS,"YES")
        if ismember(i,1:Ny:(Nx-1)*Ny+1)
            DistPoints = [DistPoints Panel_idx(i,4)];
        end
        if ismember(i,Ny:Ny:Nx*Ny)
            DistPoints = [DistPoints Panel_idx(i,6)];
        end
        if ismember(i,1:Ny)
            DistPoints = [DistPoints Panel_idx(i,2)];
        end
        if ismember(i,(Nx-1)*Ny+1:Nx*Ny)
            DistPoints = [DistPoints Panel_idx(i,8)];
        end
    end
    [~,idx] = setdiff(TableFinal{DistPoints,["X [ft]" "Y [ft]"]},MaxLoc,'rows');
    DistTemp = (-MaxDisp+TableFinal{DistPoints(idx),"D+L-sus"}')/12/2./vecnorm(MaxLoc'-TableFinal{DistPoints(idx),["X [ft]" "Y [ft]"]}');
    Dist2(i,13) = max(DistTemp);
end

LoadSus = array2table([(1:NP)' Dist2*240],'VariableNames',["Panel" "V1-sus" "V2-sus" "V3-sus" "V4-sus" "V5-sus" "V6-sus" "V7-sus" "V8-sus" "V9-sus" "V10-sus" "V11-sus" "V12-sus" "V13-sus"]);
disp(LoadSus)

% Live Distorions
Dist = zeros(NP,9);
for i=1:NP
    % Verificacion 1
    p1 = Panel_idx(i,1);
    p2 = Panel_idx(i,2);
    p3 = Panel_idx(i,3);
    Dist(i,1) = ((TableFinal{p1,"L-short"}+TableFinal{p3,"L-short"})/2-TableFinal{p2,"L-short"})/12/Ly;

    % Verificacion 2
    p1 = Panel_idx(i,1);
    p2 = Panel_idx(i,4);
    p3 = Panel_idx(i,7);
    Dist(i,2) = ((TableFinal{p1,"L-short"}+TableFinal{p3,"L-short"})/2-TableFinal{p2,"L-short"})/12/Lx;

    % Verificacion 3
    p1 = Panel_idx(i,7);
    p2 = Panel_idx(i,8);
    p3 = Panel_idx(i,9);
    Dist(i,3) = ((TableFinal{p1,"L-short"}+TableFinal{p3,"L-short"})/2-TableFinal{p2,"L-short"})/12/Ly;

    % Verificacion 4
    p1 = Panel_idx(i,3);
    p2 = Panel_idx(i,6);
    p3 = Panel_idx(i,9);
    Dist(i,4) = ((TableFinal{p1,"L-short"}+TableFinal{p3,"L-short"})/2-TableFinal{p2,"L-short"})/12/Lx;

    % Verificacion 5
    p1 = Panel_idx(i,4);
    p2 = Panel_idx(i,5);
    p3 = Panel_idx(i,6);
    Dist(i,5) = ((TableFinal{p1,"L-short"}+TableFinal{p3,"L-short"})/2-TableFinal{p2,"L-short"})/12/Ly;

    % Verificacion 6
    p1 = Panel_idx(i,2);
    p2 = Panel_idx(i,5);
    p3 = Panel_idx(i,8);
    Dist(i,6) = ((TableFinal{p1,"L-short"}+TableFinal{p3,"L-short"})/2-TableFinal{p2,"L-short"})/12/Lx;
    
    % Verificacion 7
    p1 = Panel_idx(i,1);
    p2 = Panel_idx(i,5);
    p3 = Panel_idx(i,9);
    Dist(i,7) = ((TableFinal{p1,"L-short"}+TableFinal{p3,"L-short"})/2-TableFinal{p2,"L-short"})/12/norm([Lx Ly]);

    % Verificacion 8
    p1 = Panel_idx(i,3);
    p2 = Panel_idx(i,5);
    p3 = Panel_idx(i,7);
    Dist(i,8) = ((TableFinal{p1,"L-short"}+TableFinal{p3,"L-short"})/2-TableFinal{p2,"L-short"})/12/norm([Lx Ly]);

    % Verificacion 9 (Proposal Simple)
    p2 = Panel_idx(i,5);
    Locs = TableFinal{Panel_idx(i,:),["X [ft]" "Y [ft]"]};

    [MaxDisp, Ind] = min(TableFinal{Panel_idx(i,:),"L-short"});
    MaxLoc = Locs(Ind,:);
    
    DistPoints = Panel_idx(i,[1 3 7 9]);
    if strcmp(INTERIOR,"YES")
        DistPoints = [DistPoints Panel_idx(i,[2 4 6 8])];
    elseif strcmp(BEAMS,"YES")
        if ismember(i,1:Ny:(Nx-1)*Ny+1)
            DistPoints = [DistPoints Panel_idx(i,4)];
        end
        if ismember(i,Ny:Ny:Nx*Ny)
            DistPoints = [DistPoints Panel_idx(i,6)];
        end
        if ismember(i,1:Ny)
            DistPoints = [DistPoints Panel_idx(i,2)];
        end
        if ismember(i,(Nx-1)*Ny+1:Nx*Ny)
            DistPoints = [DistPoints Panel_idx(i,8)];
        end
    end
    [~,idx] = setdiff(TableFinal{DistPoints,["X [ft]" "Y [ft]"]},MaxLoc,'rows');
    Dist(i,9) = -MaxDisp/12/2/min(vecnorm(MaxLoc'-TableFinal{DistPoints(idx),["X [ft]" "Y [ft]"]}'));
    Dist(i,10) = -MaxDisp/12/sqrt(Lx^2+Ly^2);
    Dist(i,11) = -MaxDisp/12/max(Lx,Ly);
    Dist(i,12) = -MaxDisp/12/min(Lx,Ly);

    % Verificacion 10 (Proposal Relativo)
    p2 = Panel_idx(i,5);
    Locs = TableFinal{Panel_idx(i,:),["X [ft]" "Y [ft]"]};

    [MaxDisp, Ind] = min(TableFinal{Panel_idx(i,:),"L-short"});
    MaxLoc = Locs(Ind,:);
    
    DistPoints = Panel_idx(i,[1 3 7 9]);
    if strcmp(INTERIOR,"YES")
        DistPoints = [DistPoints Panel_idx(i,[2 4 6 8])];
    elseif strcmp(BEAMS,"YES")
        if ismember(i,1:Ny:(Nx-1)*Ny+1)
            DistPoints = [DistPoints Panel_idx(i,4)];
        end
        if ismember(i,Ny:Ny:Nx*Ny)
            DistPoints = [DistPoints Panel_idx(i,6)];
        end
        if ismember(i,1:Ny)
            DistPoints = [DistPoints Panel_idx(i,2)];
        end
        if ismember(i,(Nx-1)*Ny+1:Nx*Ny)
            DistPoints = [DistPoints Panel_idx(i,8)];
        end
    end
    [~,idx] = setdiff(TableFinal{DistPoints,["X [ft]" "Y [ft]"]},MaxLoc,'rows');
    DistTemp = (-MaxDisp+TableFinal{DistPoints(idx),"L-short"}')/12/2./vecnorm(MaxLoc'-TableFinal{DistPoints(idx),["X [ft]" "Y [ft]"]}');
    Dist(i,13) = max(DistTemp);
end

LoadL = array2table([(1:NP)' Dist*360],'VariableNames',["Panel" "V1-L" "V2-L" "V3-L" "V4-L" "V5-L" "V6-L" "V7-L" "V8-L" "V9-L" "V10-L" "V11-L" "V12-L" "V13-L"]);
disp(LoadL)

%% Save to Excel
% filename = 'BeamSlab-27ft-30psf-80-psf-l2.xls';
% writetable(LoadSus,filename,'Sheet','DistorsionsSus');
% writetable(LoadL,filename,'Sheet','DistorsionsLive');
% writetable(TableFinal,filename,'Sheet','Displacements');

%% Close SAFE
ret = File.Save(ModelPath);
ret = SafeObject.ApplicationExit(false());

%% Calculo de alpha_fm
if strcmp(BEAMS,"YES")
% Internal
    % Slab Inertia
    Isx = Ly*12*hl^3/12;

    Isy = Lx*12*hl^3/12;

    % Additional Flange as a function of beam
    bf = @(hb) 2*min(4*hl,max(hb-hl,0));

    % Beam centroid as a function of height
    Yg = @(hb,bb) (bb.*hb.^2/2 + bf(hb)*hl^2/2)./(bb.*hb+bf(hb)*hl);

    % Beam Inertia as a function of height
    Ib = @(hb,bb) bb.*hb.^3/12+bf(hb)*hl^3/12+bb.*hb.*(Yg(hb,bb)-hb/2).^2+...
        bf(hb).*hl.*(Yg(hb,bb)-hl/2).^2;

    % Alpha Int x
    AlphaIntX = Ib(hvxi,bvxi)/Isx;
    AlphaIntY = Ib(hvyi,bvyi)/Isy;

% External
    % Slab Inertia
    Isx = (Ly/2*12+bvxe/2)*hl^3/12;

    Isy = (Lx/2*12+bvye/2)*hl^3/12;

    % Additional Flange as a function of beam
    bf = @(hb) min(4*hl,max(hb-hl,0));

    % Beam centroid as a function of height
    Yg = @(hb,bb) (bb.*hb.^2/2 + bf(hb)*hl^2/2)./(bb.*hb+bf(hb)*hl);

    % Beam Inertia as a function of height
    Ib = @(hb,bb) bb.*hb.^3/12+bf(hb)*hl^3/12+bb.*hb.*(Yg(hb,bb)-hb/2).^2+...
        bf(hb).*hl.*(Yg(hb,bb)-hl/2).^2;

    % Alpha Ext x
    AlphaExtX = Ib(hvxe,bvxe)/Isx;
    AlphaExtY = Ib(hvye,bvye)/Isy;


% Esquina
alpha_cor = 0.25*(AlphaIntX+AlphaIntY+AlphaExtX+AlphaExtY);
alpha_lon = 0.25*(2*AlphaIntX+AlphaIntY+AlphaExtY);
alpha_sht = 0.25*(2*AlphaIntY+AlphaIntX+AlphaExtX);
alpha_cen = 0.5*(AlphaIntX+AlphaIntY);
end


%% Crear Estuctura con Datos y Resultados
Losa.Lx = Lx;
Losa.Ly = Ly;
Losa.Beta = max(Lx,Ly)/min(Lx,Ly);
Losa.Alpha = alpha(jj);
Losa.gD = gD;
Losa.gL = gL;
Losa.lambda = lambda;
Losa.h = hl;
Losa.Beams = BEAMS;
Losa.Drop = DROP;
Losa.Disps = TableFinal;
Losa.LoadSus = LoadSus;
Losa.LoadL = LoadL;

Losas{nn,jj} = Losa;
end
end

%% Save Data
save(filename,'Losas')
toc