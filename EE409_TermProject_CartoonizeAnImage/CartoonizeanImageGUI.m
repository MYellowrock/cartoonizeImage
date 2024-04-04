function varargout = CartoonizeanImageGUI(varargin)
% CARTOONIZEANIMAGEGUI MATLAB code for CartoonizeanImageGUI.fig
%      CARTOONIZEANIMAGEGUI, by itself, creates a new CARTOONIZEANIMAGEGUI or raises the existing
%      singleton*.
%
%      H = CARTOONIZEANIMAGEGUI returns the handle to a new CARTOONIZEANIMAGEGUI or the handle to
%      the existing singleton*.
%
%      CARTOONIZEANIMAGEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CARTOONIZEANIMAGEGUI.M with the given input arguments.
%
%      CARTOONIZEANIMAGEGUI('Property','Value',...) creates a new CARTOONIZEANIMAGEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CartoonizeanImageGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CartoonizeanImageGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CartoonizeanImageGUI

% Last Modified by GUIDE v2.5 24-Dec-2022 14:23:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CartoonizeanImageGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CartoonizeanImageGUI_OutputFcn, ...
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


% --- Executes just before CartoonizeanImageGUI is made visible.
function CartoonizeanImageGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CartoonizeanImageGUI (see VARARGIN)

% Choose default command line output for CartoonizeanImageGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CartoonizeanImageGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CartoonizeanImageGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
global file_name;
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

max_luminosity = str2double(get(handles.edit2,'String'));
index1 = get(handles.radiobutton1,'value');
index2 = get(handles.radiobutton3,'value');
value = get(handles.slider1,'Value');
value = fix(value);

threshold = 16 - value;

img = imread(file_name);
axes(handles.axes1);
imshow(img)
[M, N, I] = size(img);

% A ---  Histogram Equalization  ------------------------------------------------------------------------------------------------------

img_filtered = img;

% Apply medfilt2 on each color

for c = 1:I
    img_filtered(:, :, c) = medfilt2(img(:, :, c), [5, 5]);
end

image_lab = rgb2lab(img_filtered);

L = image_lab(:,:,1)/max_luminosity;

image_histeq = image_lab;
image_histeq(:,:,1) = histeq(L)*max_luminosity;
image_histeq = lab2rgb(image_histeq);

% B ---  Edge Detection using Sobel   ------------------------------------------------------------------------------------------------------

[M, N, I] = size(img_filtered);
dup = zeros(M,N);

for i = 1:M
    for j = 1:N
        dup(i,j) = img_filtered(i,j);
    end
end

edges = edge(dup, "sobel", "both");

sel = strel("rectangle", [1, 1]);
dilated_img = imdilate(edges, sel);
dilated_img = imcomplement(dilated_img);

% C --- Bilateral Filtering  -----------------------------------------------------------------------------------------------

img1 = image_histeq;

img1 = img1+0.03*randn(size(img1));
img1(img1<0) = 0; img1(img1>1) = 1;

w     = 5;       % bilateral filter half-width
sigma = [3 0.1]; % bilateral filter standard deviations

image_filtered = bfilter2(img1,w,sigma);
 
% D --- Color Quantization  -----------------------------------------------------------------------------------------------

quantize_img = image_filtered;

threshRGB = multithresh(quantize_img, threshold);

threshForPlanes = zeros(3,7);

for i = 1:3
    threshForPlanes(i, : ) = multithresh(quantize_img(:, :, i), 7);
end

value = [0, threshRGB(2:end), 255];
quantRGB = imquantize(quantize_img, threshRGB, value);

% Apply medfilt2 on each color
C_new = quantRGB;

for c = 1:3
    C_new(:, :, c) = medfilt2(quantRGB(:, :, c), [5, 5]);
end

cartoon = imsharpen(C_new);

% E --- Recombine  -----------------------------------------------------------------------------------------------
 
cartoon_edge = imfuse(C_new, dilated_img,"blend");

if index1 == 1
    axes(handles.axes3);
    imshow(cartoon)
else if index2 == 1
    axes(handles.axes3);
    imshow(cartoon_edge)
    end
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes3);
cla
axes(handles.axes1);
cla


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname, filterindex] = uiputfile( ...
    {'*.jpg','JPEG image (*.jpg)'; ...
    '*bmp','Windows Bitmap (*.bmp)'; ...
    '*.*','All Files (*.*)'}, ...
    'Save as');
f = getframe(handles.axes3);
[a b] = frame2im(f);
imwrite(a,filename);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

value = get(handles.slider1,'Value');
set(handles.text8,'String',value);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
global file_name;
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.*');
file_name = fullfile(path,file);
image = imread(file_name);
axes(handles.axes1);
imshow(image)


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1

set(handles.radiobutton1,'value',1);
set(handles.radiobutton3,'value',0);

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


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


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.radiobutton3,'value',1);
set(handles.radiobutton1,'value',0);

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
