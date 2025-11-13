function smart_locker_system
%% -------------------- Main Menu --------------------
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

bgColor = [0.8 1 0.7]; % light green

hMain = figure('Name','Smart Locker System','NumberTitle','off', ...
    'Position',[screenWidth/4, screenHeight/4, screenWidth/2, screenHeight/2], ...
    'MenuBar','none','ToolBar','none','Color',bgColor);

uicontrol('Style','text','Parent',hMain,'String','Welcome — Smart Locker', ...
    'FontSize',16,'FontWeight','bold','ForegroundColor','black', ...
    'BackgroundColor',bgColor,'Position',[screenWidth/8-50, screenHeight/3, 300, 30]);

uicontrol('Style','pushbutton','Parent',hMain,'String','Register', ...
    'Position',[screenWidth/8-60, screenHeight/4, 100, 40], ...
    'Callback',@(src,evt) registerGUI(), 'FontWeight','bold');

uicontrol('Style','pushbutton','Parent',hMain,'String','Login', ...
    'Position',[screenWidth/8+60, screenHeight/4, 100, 40], ...
    'Callback',@(src,evt) loginGUI(), 'FontWeight','bold');

%% -------------------- Password Masking --------------------
function passwordKeyPress(src,evt,fig)
    stored = getappdata(fig,'passwordStore');
    if isempty(stored), stored = ''; end
    k = evt.Key; ch = evt.Character;
    switch k
        case 'backspace'
            if ~isempty(stored)
                stored = stored(1:end-1);
            end
        case 'delete'
            stored = '';
        case {'leftarrow','rightarrow','uparrow','downarrow','home','end','shift','control','alt'}
        otherwise
            if ~isempty(ch) && isstrprop(ch,'digit') % only digits
                stored = [stored ch];
            end
    end
    setappdata(fig,'passwordStore',stored);
    set(src,'String',repmat('*',1,numel(stored)));
end

%% -------------------- Registration GUI --------------------
function registerGUI()
screenSize = get(0, 'ScreenSize'); screenWidth = screenSize(3); screenHeight = screenSize(4);
fig = figure('Name','Register','NumberTitle','off', ...
    'Position',[screenWidth/4, screenHeight/4, screenWidth/2, screenHeight/2], ...
    'MenuBar','none','ToolBar','none','Color',bgColor);

uicontrol('Style','text','Parent',fig,'String','Register','FontSize',14,'FontWeight','bold', ...
    'ForegroundColor','black','BackgroundColor',bgColor,'Position',[20, screenHeight/2-45, 300, 28]);

uicontrol('Style','text','Parent',fig,'String','Name:','HorizontalAlignment','left', ...
    'Position',[20, screenHeight/2-85, 80, 20],'ForegroundColor','black','BackgroundColor',bgColor);
hName = uicontrol('Style','edit','Parent',fig,'Position',[110, screenHeight/2-85, 200, 28],'BackgroundColor','white');

uicontrol('Style','text','Parent',fig,'String','Mobile:','HorizontalAlignment','left', ...
    'Position',[20, screenHeight/2-125, 80, 20],'ForegroundColor','black','BackgroundColor',bgColor);
hMobile = uicontrol('Style','edit','Parent',fig,'Position',[110, screenHeight/2-125, 200, 28],'BackgroundColor','white');

uicontrol('Style','text','Parent',fig,'String','Password (1111–4444):','HorizontalAlignment','left', ...
    'Position',[20, screenHeight/2-165, 130, 20],'ForegroundColor','black','BackgroundColor',bgColor);
hPass = uicontrol('Style','edit','Parent',fig,'Position',[150, screenHeight/2-165, 160, 28],'BackgroundColor','white');

setappdata(fig,'passwordStore',''); set(hPass,'String','');
set(hPass,'KeyPressFcn',@(src,evt) passwordKeyPress(src,evt,fig));

uicontrol('Style','pushbutton','Parent',fig,'String','Register', ...
    'Position',[80, 50, 100, 30], 'Callback',@(src,evt) registerCallback(hName,hMobile,hPass,fig));
uicontrol('Style','pushbutton','Parent',fig,'String','Clear', ...
    'Position',[200, 50, 100, 30],'Callback',@(src,evt) clearFields(hName,hMobile,hPass,fig));
uicontrol('Style','pushbutton','Parent',fig,'String','Back', ...
    'Position',[320, 50, 100, 30],'Callback',@(src,evt) close(fig));
end

function clearFields(hName,hMobile,hPass,fig)
set(hName,'String',''); set(hMobile,'String',''); set(hPass,'String','');
setappdata(fig,'passwordStore','');
end

function registerCallback(hName,hMobile,hPass,fig)
name = strtrim(get(hName,'String'));
mobile = strtrim(get(hMobile,'String'));
password = getappdata(fig,'passwordStore');

if isempty(name), errordlg('Please enter a name.','Validation Error'); return; end
if isempty(mobile) || ~all(isstrprop(mobile,'digit')) || numel(mobile)~=10
    errordlg('Mobile must be 10 digits (numbers only).','Validation Error'); return;
end
if isempty(password) || numel(password)~=4 || ~all(isstrprop(password,'digit'))
    errordlg('Password must be 4 digits (numeric only).','Validation Error'); return;
end
numPass = str2double(password);
if numPass < 1111 || numPass > 4444
    errordlg('Password must be between 1111 and 4444.','Validation Error'); return;
end

% Load users safely
if exist('users.mat','file')
    load('users.mat','users');
    if ~isstruct(users)
        users = struct('Name', {}, 'Mobile', {}, 'Password', {});
    end
else
    users = struct('Name', {}, 'Mobile', {}, 'Password', {});
end

if ~isempty(users) && any(strcmp({users.Mobile},mobile))
    errordlg('Mobile already registered.','Duplicate');
    return;
end

newUser = struct('Name',name,'Mobile',mobile,'Password',password);
users(end+1) = newUser;
save('users.mat','users');
msgbox(sprintf('Registered %s successfully!',name),'Success','modal');
clearFields(hName,hMobile,hPass,fig);
end

%% -------------------- Login GUI --------------------
function loginGUI()
screenSize = get(0, 'ScreenSize'); screenWidth=screenSize(3); screenHeight=screenSize(4);
fig=figure('Name','Login','NumberTitle','off','Position',[screenWidth/4, screenHeight/4, screenWidth/2, screenHeight/2], ...
    'MenuBar','none','ToolBar','none','Color',bgColor);

uicontrol('Style','text','Parent',fig,'String','Login','FontSize',14,'FontWeight','bold', ...
    'Position',[20, screenHeight/2-45, 300, 24],'ForegroundColor','black','BackgroundColor',bgColor);
uicontrol('Style','text','Parent',fig,'String','Mobile:','HorizontalAlignment','left', ...
    'Position',[20, screenHeight/2-85, 80, 20],'ForegroundColor','black','BackgroundColor',bgColor);
hMobile=uicontrol('Style','edit','Parent',fig,'Position',[110, screenHeight/2-85, 200, 26],'BackgroundColor','white');

uicontrol('Style','text','Parent',fig,'String','Password:','HorizontalAlignment','left', ...
    'Position',[20, screenHeight/2-125, 80, 20],'ForegroundColor','black','BackgroundColor',bgColor);
hPass=uicontrol('Style','edit','Parent',fig,'Position',[110, screenHeight/2-125, 200, 26],'BackgroundColor','white');

setappdata(fig,'passwordStore',''); set(hPass,'String','');
set(hPass,'KeyPressFcn',@(src,evt) passwordKeyPress(src,evt,fig));

uicontrol('Style','pushbutton','Parent',fig,'String','Login', ...
    'Position',[120,50,100,34], 'Callback',@(src,evt) loginCallback(hMobile,hPass));
uicontrol('Style','pushbutton','Parent',fig,'String','Back', ...
    'Position',[240,50,100,34], 'Callback',@(src,evt) close(fig));
end

function loginCallback(hMobile,hPass)
mobile=strtrim(get(hMobile,'String'));
password=getappdata(gcf,'passwordStore');

if strcmpi(mobile,'admin') && strcmp(password,'admin')
    msgbox('Admin Access Granted','Admin','modal'); return;
end

if ~exist('users.mat','file'), errordlg('No users registered','Login Error'); return; end
load('users.mat','users');
idx=find(strcmp({users.Mobile},mobile),1);
if isempty(idx), errordlg('Mobile not registered','Login Error'); return; end
if strcmp(users(idx).Password,password)
    msgbox(sprintf('Welcome, %s!',users(idx).Name),'Login Success','modal');
    lockerGUI(users(idx).Name);
else, errordlg('Incorrect password','Login Error'); end
end

%% -------------------- Locker GUI --------------------
function lockerGUI(userName)
fig=figure('Name','Locker System','NumberTitle','off','Position',[400,200,700,450],'Color',bgColor);
uicontrol('Style','text','Parent',fig,'String',sprintf('Welcome, %s',userName), ...
    'FontSize',14,'FontWeight','bold','ForegroundColor','black','BackgroundColor',bgColor,'Position',[250,380,250,30]);

for i=1:3
    uicontrol('Style','text','Parent',fig,'String',sprintf('LOCKER %d',i),'FontSize',12,'FontWeight','bold',...
        'ForegroundColor','black','BackgroundColor',bgColor,'Position',[100+200*(i-1),320,100,30]);
    uicontrol('Style','text','Parent',fig,'String','AVAILABLE','FontSize',11,...
        'ForegroundColor','green','BackgroundColor',bgColor,'Position',[100+200*(i-1),280,100,30],'Tag',sprintf('Status%d',i));

    hBook=uicontrol('Style','pushbutton','Parent',fig,'String','BOOK','Position',[100+200*(i-1),220,100,40],'FontWeight','bold');
    hEnd=uicontrol('Style','pushbutton','Parent',fig,'String','END SESSION','Position',[100+200*(i-1),160,100,40],'FontWeight','bold','Enable','off');

    set(hBook,'Callback',@(~,~) startSession(i,hBook,hEnd,userName));
    set(hEnd,'Callback',@(~,~) endSession(i,hBook,hEnd,userName));
end
end

%% -------------------- Session Start --------------------
function startSession(lockerNum,hBook,hEnd,userName)
statusLabel=findobj('Tag',sprintf('Status%d',lockerNum));
set(statusLabel,'String','BOOKED','ForegroundColor','red'); set(hBook,'Enable','off'); set(hEnd,'Enable','on');
setappdata(0,['startTime' num2str(lockerNum)],datetime('now'));
end

%% -------------------- Session End --------------------
function endSession(lockerNum,hBook,hEnd,userName)
statusLabel=findobj('Tag',sprintf('Status%d',lockerNum));
set(statusLabel,'String','AVAILABLE','ForegroundColor','green'); set(hBook,'Enable','on'); set(hEnd,'Enable','off');

startTime=getappdata(0,['startTime' num2str(lockerNum)]); 
endTime=datetime('now'); 
durationMins=randi([5 20]); % Dummy duration
amount=durationMins*1; % ₹1 per minute

fig2=figure('Name','Session Summary','NumberTitle','off','Position',[450,200,450,350],'Color',bgColor);
uicontrol('Style','text','Parent',fig2,'String',sprintf('Start Time: %s',datestr(startTime)),'ForegroundColor','black','BackgroundColor',bgColor,'Position',[50,280,350,20]);
uicontrol('Style','text','Parent',fig2,'String',sprintf('End Time: %s',datestr(endTime)),'ForegroundColor','black','BackgroundColor',bgColor,'Position',[50,240,350,20]);
uicontrol('Style','text','Parent',fig2,'String',sprintf('Total Duration: %d min',durationMins),'ForegroundColor','black','BackgroundColor',bgColor,'Position',[50,200,350,20]);
uicontrol('Style','text','Parent',fig2,'String',sprintf('Amount: ₹%d',amount),'ForegroundColor','black','BackgroundColor',bgColor,'Position',[50,160,350,20]);

uicontrol('Style','pushbutton','Parent',fig2,'String','Online Payment','Position',[50,80,120,40],...
    'Callback',@(src,evt) onlinePayment(userName,lockerNum,startTime,endTime,amount,durationMins));
uicontrol('Style','pushbutton','Parent',fig2,'String','Cash Payment','Position',[250,80,120,40],...
    'Callback',@(src,evt) cashPayment(userName,lockerNum,startTime,endTime,amount,durationMins));
end

%% -------------------- Payment Functions --------------------
function onlinePayment(userName,lockerNum,startTime,endTime,amount,durationMins)
 if (durationMins<=5)
    url = 'https://rzp.io/rzp/rgwnbRBM'; 
elseif (durationMins>5 && durationMins<=10)
    url = 'https://rzp.io/rzp/10C3DuBl';
elseif (durationMins>10 && durationMins<=15)
    url = 'https://rzp.io/rzp/HsCDBe9';
elseif (durationMins>15 && durationMins<=20)
    url = 'https://rzp.io/rzp/10C3DuBl';
elseif (durationMins>20 && durationMins<=25)
    url = 'https://rzp.io/rzp/HsCDBe9';
elseif (durationMins>25 && durationMins<=30)
    url = 'https://rzp.io/rzp/10C3DuBl';
else
    url = 'https://rzp.io/rzp/HsCDBe9';
end

web(url); 
choice=questdlg('Payment Completed?','Online Payment','Yes','No','Yes');
if strcmp(choice,'Yes'), status='Paid Online'; else, status='Pending Online'; end
saveSession(userName,lockerNum,startTime,endTime,amount,status);
end

function cashPayment(userName,lockerNum,startTime,endTime,amount,durationMins)
prompt={'Enter Admin Username:','Enter Admin Password:'};
dlgtitle='Admin Authentication'; dims=[1 35]; definput={'admin','admin'};
answer=inputdlg(prompt,dlgtitle,dims,definput);
if isempty(answer), return; end
if strcmp(answer{1},'admin') && strcmp(answer{2},'admin')
    msgbox('Access Granted','Admin','modal');
    status='Cash Payment'; saveSession(userName,lockerNum,startTime,endTime,amount,status);
else
    errordlg('Access Denied','Admin'); 
end
end

%% -------------------- Save Session + Firebase --------------------
function saveSession(userName,lockerNum,startTime,endTime,amount,status)
sessionData=struct('UserName',userName,'Locker',lockerNum,'StartTime',datestr(startTime),...
    'EndTime',datestr(endTime),'Amount',amount,'PaymentStatus',status);

if exist('sessions.mat','file')
    load('sessions.mat','sessions');
    if ~isstruct(sessions)
        sessions = struct('UserName',{},'Locker',{},'StartTime',{},'EndTime',{},'Amount',{},'PaymentStatus',{});
    end
else
    sessions = struct('UserName',{},'Locker',{},'StartTime',{},'EndTime',{},'Amount',{},'PaymentStatus',{});
end

sessions(end+1)=sessionData;
save('sessions.mat','sessions');

msgbox('Session recorded successfully!','Success','modal');

firebaseUrl='https://smart-locker-da04e-default-rtdb.firebaseio.com';
authUrl=[firebaseUrl '/sessions.json'];
try
    options=weboptions('MediaType','application/json','RequestMethod','post','Timeout',30);
    webwrite(authUrl,sessionData,options);
    fprintf('✅ SUCCESS: session uploaded to Firebase!\n');
catch ME
    fprintf('⚠️ Firebase upload failed: %s\n',ME.message);
end
end

end
