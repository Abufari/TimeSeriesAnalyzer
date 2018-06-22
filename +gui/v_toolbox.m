function [handles, panel_toolbox] = v_toolbox(parent)
handles = guidata(parent);
initGUI();
handles.model = AnalyzerModel.ModalAnalysisModel();

% guidata(handles.panel_toolbox, handles);
guidata(parent, handles);
panel_toolbox = handles.panel_toolbox;

setCallbacks();
initPanel();

    function initGUI()
        handles.button_image_dark = zeros(74,100,3);
        handles.button_image_dark(:,:,:) = 0.85;
        handles.button_image_light = zeros(74,100,3);
        handles.button_image_light(:,:,:) = 0.9;
        handles.panel_toolbox = uipanel('Parent',parent,...
            'Visible','off',...
            'FontSize',9,...
            'Position',[10 10 0.8 0.9],...
            'Units','pixels',...
            'SizeChangedFcn',@resizepanel,...
            'BorderType','none',...
            'BackgroundColor',[0.9 0.9 0.9]);
        handles.buttongroup = uibuttongroup('Parent',handles.panel_toolbox,...
            'BorderType','none',...
            'SelectionChangedFcn',@buttongroupselection);
        handles.button_timesignal = uicontrol('Parent',handles.buttongroup,...
            'Style','pushbutton',...
            'String','Time Signal',...
            'Tag','togglebutton_signal',...
            'FontSize',9,...
            'CData',handles.button_image_light,...
            'Units','pixels');
        handles.button_frequencysignal = uicontrol('Parent',handles.buttongroup,...
            'Style','pushbutton',...
            'String','Frequency Signal',...
            'Tag','togglebutton_frequency',...
            'FontSize',9,...
            'CData',handles.button_image_light,...
            'Units','pixels');
        
        handles.toolboxbuttons = {handles.button_timesignal, ...
            handles.button_frequencysignal};
    end

    function setCallbacks()
        set(handles.buttongroup, 'SelectionChangedFcn', @buttongroupselection);
        set(handles.button_timesignal,'Callback', @buttondowncallback);
        set(handles.button_frequencysignal,'Callback', @buttondowncallback);
    end

function initPanel()
buttondowncallback(handles.button_timesignal, 0);
handles.panel_toolbox.Visible = 'on';
end

    function resizepanel(hObject,event)
        panel_width = handles.panel_toolbox.Position(3);
        panel_height = handles.panel_toolbox.Position(4);
        
        rim = 3;
        
        handles.buttongroup.Position = [0 0 panel_width panel_height];
        
        button_height = panel_height - 2*rim;
        button_width = 100;
        for i = 1 : numel(handles.toolboxbuttons)
            handles.toolboxbuttons{i}.Position = [rim+(i-1)*button_width rim button_width button_height];
        end
    end
end

function buttongroupselection(object, event)
fprintf('Clicked %s\n', event.NewValue.Tag);
end

function buttondowncallback(object,event)
handles = guidata(object);
for i = 1 : numel(handles.toolboxbuttons)
    handles.toolboxbuttons{i}.ForegroundColor = [0 0 0];
    handles.toolboxbuttons{i}.CData = handles.button_image_light;
end
object.ForegroundColor = [0 0.3 0.5];
object.CData = handles.button_image_dark;
guidata(object, handles);
end