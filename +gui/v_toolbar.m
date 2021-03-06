function output_handles = v_toolbox(parent)
initGUI();
handles.model = AnalyzerModel.ModalAnalysisModel();

guidata(handles.panel_toolbar, handles);
output_handles = handles.panel_toolbar;


    function initGUI()
        handles.panel_toolbar = uipanel('Parent',parent,...
            'Title','Toolbar Panel',...
            'FontSize',9,...
            'Position',[10 10 0.8 0.9],...
            'Units','pixels',...
            'SizeChangedFcn',@resizepanel,...
            'BorderType','none',...
            'BackgroundColor',[0.9 0.9 0.9]);
        handles.button = uicontrol('Parent',handles.panel_toolbar,...
            'Style','pushbutton',...
            'String','Mein ToolbarButton',...
            'Position',[10 10 100 30],...
            'Units','pixels');
    end

    function resizepanel(hObject,event)
        
    end
end

