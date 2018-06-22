function [output_args] = v_mainwindow()
initGUI();


movegui(handles.fig, 'center');
handles.fig.Visible = 'on';

guidata(handles.fig, handles);
output_args = handles;

    function initGUI()
        handles.fig = figure('Visible','off',...
            'Position',[360,500,1000,600],...
            'menubar','none',...
            'Name','Time Series Analyzer',...
            'numbertitle','off',...
            'SizeChangedFcn',@resizeui,...
            'Color',[1 1 1]);
%         handles = guihandles(fig);
%         handles.fig = fig;
        guidata(handles.fig, handles);
        [handles, handles.toolbox_panel] = gui.v_toolbox(handles.fig);
        guidata(handles.fig, handles);
        [handles, handles.settings_panel] = gui.v_settings(handles.fig);
        %handles.toolbar_panel = gui.v_toolbar(handles.fig);
        %handles.plotwindow_panel = gui.v_plotwindow(handles.fig);
    end

    function resizeui(hObject,event)
        if ~exist('handles')
            return
        end
        
        % Get figure width and height
        fig_width = handles.fig.Position(3);
        fig_height = handles.fig.Position(4);
        
        rim = 10;
        
        toolbox_panel_height = max(0.1, 80);
        toolbox_panel_width = max(0.1,fig_width - 2*rim);
        handles.toolbox_panel.Position = [rim rim toolbox_panel_width toolbox_panel_height];
                
        toolbar_panel_height = max(0.1, 80);
        toolbar_panel_width = max(0.1,fig_width - 2*rim);
        handles.toolbar_panel.Position = [rim fig_height-toolbar_panel_height-rim ...
            toolbar_panel_width toolbar_panel_height];
        
        settings_panel_height = max(0.1, fig_height - toolbox_panel_height-toolbar_panel_height - 2*rim);
        settings_panel_width = 120;
        handles.settings_panel.Position = [fig_width-settings_panel_width-rim toolbox_panel_height+rim ...
            settings_panel_width settings_panel_height];
        
        plotwindow_panel_height = fig_height - toolbox_panel_height-toolbar_panel_height - 2*rim;
        plotwindow_panel_width = fig_width - settings_panel_width - 2*rim;
        handles.plotwindow_panel.Position = [rim toolbox_panel_height+rim ...
            plotwindow_panel_width plotwindow_panel_height];
    end
end


