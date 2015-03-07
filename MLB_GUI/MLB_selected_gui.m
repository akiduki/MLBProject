function varargout = MLB_selected_gui(varargin)
% MLB_SELECTED_GUI MATLAB code for MLB_selected_gui.fig
%      MLB_SELECTED_GUI, by itself, creates a new MLB_SELECTED_GUI or raises the existing
%      singleton*.
%
%      H = MLB_SELECTED_GUI returns the handle to a new MLB_SELECTED_GUI or the handle to
%      the existing singleton*.
%
%      MLB_SELECTED_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MLB_SELECTED_GUI.M with the given input arguments.
%
%      MLB_SELECTED_GUI('Property','Value',...) creates a new MLB_SELECTED_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MLB_selected_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MLB_selected_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MLB_selected_gui

% Last Modified by GUIDE v2.5 06-Mar-2015 20:23:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MLB_selected_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @MLB_selected_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MLB_selected_gui is made visible.
function MLB_selected_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MLB_selected_gui (see VARARGIN)

% Choose default command line output for MLB_selected_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MLB_selected_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MLB_selected_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
clc
set(handles.image_no,'string','0');
set(gcf,'pointer','fullcrosshair');
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_image.
function Load_image_Callback(hObject, eventdata, handles)
% hObject    handle to Load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.jpg';'*.bmp';'*.*'},'Open File');

if isequal(filename,0)
    msgbox('Did not choose any file !!?','File Open Error','error');
    return;
end
str = [pathname filename];

% read video frame
handles.frame_num = str2num(get(handles.edit2,'string'));
handles.vid_obj = VideoReader(str);
handles.img=read(handles.vid_obj,handles.frame_num);
axes(handles.axes1);
imshow(handles.img);
colormap('gray')


[y,x,o] = size(handles.img);
center_y = y/2;
center_x = x/2;

Select=['     1 ' ' x '; '     x ' ' x ']
pause
hold on
Points1 = get(gca,'CurrentPoint'); 
plot(Points1(1,1),Points1(1,2),'s','color','g','MarkerSize',10)
clc

Select=['     x ' ' x '; '     x ' ' 2 ']
pause
Points2 = get(gca,'CurrentPoint'); 
plot(Points2(1,1),Points2(1,2),'s','color','g','MarkerSize',10)
clc
handles.x_ul =round(Points1(1,1));
handles.y_ul =round(Points1(1,2));
handles.x_br =round(Points2(1,1));
handles.y_br =round(Points2(1,2));

p12_x = [Points1(1,1),Points2(1,1)];
p12_y = [Points1(1,2),Points1(1,2)];
line(p12_x,p12_y);
p23_x = [Points2(1,1),Points2(1,1)];
p23_y = [Points1(1,2),Points2(1,2)];
line(p23_x,p23_y);
p34_x = [Points2(1,1),Points1(1,1)];
p34_y = [Points2(1,2),Points2(1,2)];
line(p34_x,p34_y);
p14_x = [Points1(1,1),Points1(1,1)];
p14_y = [Points1(1,2),Points2(1,2)];
line(p14_x,p14_y);
hold off

guidata(hObject,handles);






% --- Executes on button press in rechoose.
function rechoose_Callback(hObject, eventdata, handles)
% hObject    handle to rechoose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.frame_num ~=  str2num(get(handles.edit2,'string'))
    handles.frame_num = str2num(get(handles.edit2,'string'));
end

handles.img=(read(handles.vid_obj,handles.frame_num));

[m,n,o] = size(handles.img );

axes(handles.axes1);
imshow(handles.img);
colormap('gray')

Select=['     1 ' ' x '; '     x ' ' x ']
pause
hold on
Points1 = get(gca,'CurrentPoint'); 

plot(Points1(1,1),Points1(1,2),'s','color','g','MarkerSize',10)
clc

Select=['     x ' ' x '; '     x ' ' 2 ']
pause
Points2 = get(gca,'CurrentPoint'); % 
plot(Points2(1,1),Points2(1,2),'s','color','g','MarkerSize',10)
clc
handles.x_ul =round(Points1(1,1));
handles.y_ul =round(Points1(1,2));
handles.x_br =round(Points2(1,1));
handles.y_br =round(Points2(1,2));

p12_x = [Points1(1,1),Points2(1,1)];
p12_y = [Points1(1,2),Points1(1,2)];
line(p12_x,p12_y);
p23_x = [Points2(1,1),Points2(1,1)];
p23_y = [Points1(1,2),Points2(1,2)];
line(p23_x,p23_y);
p34_x = [Points2(1,1),Points1(1,1)];
p34_y = [Points2(1,2),Points2(1,2)];
line(p34_x,p34_y);
p14_x = [Points1(1,1),Points1(1,1)];
p14_y = [Points1(1,2),Points2(1,2)];
line(p14_x,p14_y);
hold off


guidata(hObject,handles);

% --- Executes on button press in save_image.
function save_image_Callback(hObject, eventdata, handles)
% hObject    handle to save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.y_ul >handles.y_br
    img_y_start = handles.y_br;
    img_y_end   = handles.y_ul;
else
    img_y_start = handles.y_ul;
    img_y_end   = handles.y_br;
end
if handles.x_ul>handles.x_br
    img_x_start = handles.x_br;
    img_x_end   = handles.x_ul;
else
    img_x_start = handles.x_ul;
    img_x_end   = handles.x_br;
end

[m n o] = size(handles.img);

% img_selected = handles.f(img_y_start : img_y_end  , img_x_start : img_x_end ,:);
x_diff = round((img_x_end-img_x_start+1)/4);
y_diff = round((img_y_end-img_y_start+1)/8);

if(((img_y_start-y_diff)>=1)&((img_y_end+y_diff)<=m)&((img_x_start-x_diff)>=1)&((img_x_end+x_diff)<=n))
    img_selected = handles.img((img_y_start):(img_y_end),(img_x_start):(img_x_end),:);
    s_x = img_x_start-x_diff;
    s_y = img_y_start-y_diff;
    e_x = img_x_end+x_diff;
    e_y = img_y_end+y_diff;
else
    img_selected = handles.img((img_y_start):(img_y_end),(img_x_start):(img_x_end),:);

    x_s = max((img_x_start-x_diff),1);
    y_s = max((img_y_start-y_diff),1);
    x_e = min((img_x_end+x_diff),n);
    y_e = min((img_y_end+y_diff),m);

    x_lb =img_x_start-x_s;
    x_rb =x_e-img_x_end;
    y_lb =img_y_start-y_s;
    y_rb =y_e-img_y_end;
    
    x_d = min(x_lb,x_rb);
    y_d = min(y_lb,y_rb);
    
    s_x = img_x_start-x_d;
    s_y = img_y_start-y_d;
    e_x = img_x_end-x_d;
    e_y = img_y_end-y_d;
end


%%%

number = str2num(get(handles.image_no,'string'))+1;
set(handles.image_no,'string',number);
path_name = './img/';
filestr = 'MLBimg';
name = [path_name filestr];


% number = str2num(get(handles.normal_No,'string'))+1;
% set(handles.normal_No,'string',number);
filename = sprintf('%s_%.3d.jpg',name,number);

ori_filename = sprintf('./img/ori/%s_%.3d.jpg',filestr,number);


imwrite(img_selected,ori_filename);

img_selected = imresize(img_selected,[128 128]);
imwrite(img_selected,filename);
guidata(hObject,handles);


% --- Executes on button press in choose_another.
function choose_another_Callback(hObject, eventdata, handles)
% hObject    handle to choose_another (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[y,x,o] = size(handles.img);
center_y = y/2;
center_x = x/2;

Select=['     1 ' ' x '; '     x ' ' x ']
pause
hold on
Points1 = get(gca,'CurrentPoint'); 
plot(Points1(1,1),Points1(1,2),'s','color','g','MarkerSize',10)
clc

Select=['     x ' ' x '; '     x ' ' 2 ']
pause
Points2 = get(gca,'CurrentPoint'); 
plot(Points2(1,1),Points2(1,2),'s','color','g','MarkerSize',10)
clc
handles.x_ul =round(Points1(1,1));
handles.y_ul =round(Points1(1,2));
handles.x_br =round(Points2(1,1));
handles.y_br =round(Points2(1,2));

p12_x = [Points1(1,1),Points2(1,1)];
p12_y = [Points1(1,2),Points1(1,2)];
line(p12_x,p12_y);
p23_x = [Points2(1,1),Points2(1,1)];
p23_y = [Points1(1,2),Points2(1,2)];
line(p23_x,p23_y);
p34_x = [Points2(1,1),Points1(1,1)];
p34_y = [Points2(1,2),Points2(1,2)];
line(p34_x,p34_y);
p14_x = [Points1(1,1),Points1(1,1)];
p14_y = [Points1(1,2),Points2(1,2)];
line(p14_x,p14_y);
hold off

guidata(hObject,handles);

% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exit = questdlg('End the program ?','NTPU','Yes','No','No');
if exit == 'Yes'
    close(gcf)
end


function image_no_Callback(hObject, eventdata, handles)
% hObject    handle to image_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of image_no as text
%        str2double(get(hObject,'String')) returns contents of image_no as a double


% --- Executes during object creation, after setting all properties.
function image_no_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Fast_foward.
function Fast_foward_Callback(hObject, eventdata, handles)
% hObject    handle to Fast_foward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frame_num = str2num(get(handles.edit2,'string'));
set(handles.edit2,'string',num2str(frame_num+10));
handles.frame_num = frame_num+100;
handles.img=(read(handles.vid_obj,handles.frame_num));
axes(handles.axes1);
imshow(handles.img);
colormap('gray')
guidata(hObject,handles);
