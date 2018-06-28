classdef v_TimeSeriesAnalyzer < handle & dynamicprops
    
    properties (Access=public)
        initial_width = 1418;
        initial_height = 815;
        initial_position_width = -1600;
        initial_position_height = 156;

        figure_name = 'Time Series Analyzer';
    end

    properties (Dependent = true, SetAccess = private, GetAccess = public)
        % define some dynamic properties
        button_image_light
        button_image_dark
    end
    
    properties        
        axes_data

        figure_handle
        panels_handle
        buttons_handle
        axes_handle
        sliders_handle
        tabs_handle
        
        baseModel
        listener_handle
        
        lightGrey = [0.9 0.9 0.9]
        
        
        % height definitions
        toolbar_height = 120
        button_height = 70
        toolbox_height = 80
        settings_width = 150
    end
    
    % Figure management methods
    methods (Access = public)
        
        % Constructor
        function self = v_TimeSeriesAnalyzer(baseModel)
            self.figure_handle = NaN;
            self.baseModel = baseModel;
            self.init();

            % Turn off warnings
            warning('off','MATLAB:uitabgroup:OldVersion');
        end
        
        % Destructor
        function delete(self)
            if self.is_open()
                self.close();
            end
        end

        % Reset GUI
        function init(self)
            % Close GUI if necessary
            self.close();

            % Reinitialize handles
            self.axes_data = struct();
            self.sliders_handle = struct();
            self.panels_handle = struct();
            self.axes_handle = struct();
            self.buttons_handle = struct();
            self.tabs_handle = struct();
            
            self.listener_handle = struct();
        end

        % Construct GUI
        function build(self)
            % Reinitialize GUI
            self.init();

            % Open new figure
            self.create_figure();
            self.create_panels();
            self.create_tabs();
            self.create_buttons();
            self.create_axes();
            
            self.set_listener();
            
            self.figure_handle.Visible = 'on';
        end

        % Close GUI properly
        function close(self)
            if self.is_open()
                close(self.figure_handle());
            end

            self.figure_handle = NaN;
        end

        % Check if GUI is open
        function status = is_open(self)
            status = ishandle(self.figure_handle);
        end
    end
    
    % GUI building methods
    methods (Access = private)
        function create_figure(self)
            self.figure_handle = figure(...
                'Position',[self.initial_position_width,...
                            self.initial_position_height,...
                            self.initial_width,...
                            self.initial_height],...
                'Units', 'pixels',...
                'Visible','off',...
                'Name', self.figure_name,...
                'Tag', 'main_figure',...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'SizeChangedFcn', @self.resizeWindow,...
                'Color', [1 1 1]);

        end

        function create_panels(self)
            self.panels_handle.toolbox = uipanel(...
                'Parent', self.figure_handle,...
                'Tag', 'toolbox_panel',...
                'FontSize', 9,...
                'Units', 'pixels',...
                'SizeChangedFcn', @self.resizeWindow,...
                'BorderType', 'none',...
                'BackgroundColor', self.lightGrey);

            self.panels_handle.settings = uipanel(...
                'Parent', self.figure_handle,...
                'Tag', 'settings_panel',...
                'Title','Settings Panel',...
                'FontSize',9,...
                'Position',[10 10 0.8 0.9],...
                'Units','pixels',...
                'SizeChangedFcn',@self.resizeWindow,...
                'BorderType','none',...
                'BackgroundColor',[0.95 0.95 0.95]);

            self.panels_handle.toolbar = uipanel(...
                'Parent', self.figure_handle,...
                'Tag', 'toolbar_panel',...
                'FontSize',9,...
                'Position',[10 10 0.8 0.9],...
                'Units','pixels',...
                'SizeChangedFcn',@self.resizeWindow,...
                'BorderType','none',...
                'BackgroundColor',[1 1 1]);

            self.panels_handle.plotwindow = uipanel(...
                'Parent', self.figure_handle,...
                'Tag', 'plotwindow_panel',...
                'FontSize',9,...
                'Position',[10 10 0.8 0.9],...
                'Units','pixels',...
                'SizeChangedFcn',@self.resizeWindow,...
                'BorderType','none',...
                'BackgroundColor',[1 1 1]);
        end
            
        function create_tabs(self)
            self.tabs_handle.toolbargroup = uitabgroup(...
                'Parent',self.panels_handle.toolbar,...
                'Position',[0 0 1 1]);
            self.tabs_handle.toolstab = uitab(...
                'Parent',self.tabs_handle.toolbargroup,...
                'Title','Start',...
                'BackgroundColor',[1 1 1]);
            self.tabs_handle.sparklinestab = uitab(...
                'Parent',self.tabs_handle.toolbargroup,...
                'Title','Sparklines',...
                'BackgroundColor',[1 1 1]);
        end

        function create_buttons(self)
            % toolbox buttons
            self.buttons_handle.toolbox_buttongroup = uibuttongroup(...
                'Parent', self.panels_handle.toolbox,...
                'BorderType', 'none',...
                'Tag', 'toolbox_buttongroup',...
                'BackgroundColor', self.lightGrey,...
                'SelectionChangedFcn', @self.callback_buttongroupSelection);

            self.buttons_handle.toolbox_button_timesignal = uicontrol(...
                'Parent', self.buttons_handle.toolbox_buttongroup,...
                'Style', 'togglebutton',...
                'String', 'Time Signal',...
                'Tag', 'pushbutton_signal',...
                'ForegroundColor', [0 0.3 0.5],...
                'FontSize',9,...
                'CData',self.button_image_dark,...
                'Units', 'pixels');

            self.buttons_handle.toolbox_button_frequencysignal = uicontrol(...
                'Parent', self.buttons_handle.toolbox_buttongroup,...
                'Style', 'togglebutton',...
                'String', 'Frequency Signal',...
                'Tag', 'pushbutton_frequency',...
                'FontSize',9,...
                'CData',self.button_image_light,...
                'Units', 'pixels');

            self.buttons_handle.toolbox_button_modalanalysis = uicontrol(...
                'Parent', self.buttons_handle.toolbox_buttongroup,...
                'Style', 'togglebutton',...
                'String', 'Modal Analysis',...
                'Tag', 'pushbutton_modalanalysis',...
                'FontSize',9,...
                'CData',self.button_image_light,...
                'Units', 'pixels');

            self.buttons_handle.toolbox_button_tft = uicontrol(...
                'Parent', self.buttons_handle.toolbox_buttongroup,...
                'Style', 'togglebutton',...
                'String', 'Time Fourier',...
                'Tag', 'pushbutton_tft',...
                'FontSize',9,...
                'CData',self.button_image_light,...
                'Units', 'pixels');

            self.buttons_handle.toolbox_button_features = uicontrol(...
                'Parent', self.buttons_handle.toolbox_buttongroup,...
                'Style', 'togglebutton',...
                'String', 'Features',...
                'Tag', 'pushbutton_features',...
                'FontSize',9,...
                'CData',self.button_image_light,...
                'Units', 'pixels');

            % settings buttons
            self.buttons_handle.settings_button = uicontrol(...
                'Parent',self.panels_handle.settings,...
                'Style','pushbutton',...
                'String','Mein SettingsButton',...
                'Position',[10 10 100 30],...
                'Units','pixels');

            % toolbar buttons
            self.buttons_handle.toolbar_open = uicontrol(...
                'Parent',self.tabs_handle.toolstab,...
                'Style','pushbutton',...
                'String','Open',...
                'Tag','pushbutton_open',...
                'Position',[10 10 100 self.button_height],...
                'Units','pixels');
            
            self.buttons_handle.toolbar_append = uicontrol(...
                'Parent',self.tabs_handle.toolstab,...
                'Style','pushbutton',...
                'String','Append',...
                'Tag','pushbutton_append',...
                'Position',[110 10 100 self.button_height],...
                'Units','pixels');
            
            self.buttons_handle.toolbar_reset = uicontrol(...
                'Parent',self.tabs_handle.toolstab,...
                'Style','pushbutton',...
                'String','Reset GUI',...
                'Tag','pushbutton_reset',...
                'Position',[210 10 100 self.button_height],...
                'Units','pixels');

            % plotwindow buttons
        end
        
        function create_axes(self)
            self.axes_handle.time_axis = axes(...
                'Parent', self.panels_handle.plotwindow,...
                'Position', [0.1 0.1 0.9 0.9],...
                'FontSize',9,...
                'Tag', 'time_axis',...
                'Box', 'on');
            xlabel(self.axes_handle.time_axis, 'Time (s)');
            ylabel(self.axes_handle.time_axis, 'Amplitude (dB_{AE})');
            
            self.axes_handle.sparkline_axis = cell(1,1);
        end
        
        function draw_sparkline_axes(self)
            for i = 1 : self.baseModel.n_timeSeries
                self.axes_handle.sparkline_axis{i} = axes(...
                    'Parent', self.tabs_handle.sparklinestab,...
                    'XAxisLocation','origin',...
                    'YAxisLocation','origin',...
                    'Units','pixels',...
                    'Position', [3+(i-1)*(self.button_height+3) 3 self.button_height self.button_height],...
                    'Box','off',...
                    'UserData',struct('index',i),...
                    'NextPlot','add');
                
                
                timeSeries = self.baseModel.timeSeries{i};
                sampleRate = self.baseModel.metadata{self.baseModel.currentDataIndex,...
                    self.baseModel.featureNames('SamplingRate')};
                t = 1 : numel(timeSeries);
                t = t'./sampleRate;
                plothandle = plot(self.axes_handle.sparkline_axis{i}, t, timeSeries,...
                    'Color',AnalyzerModel.Colors.YlGnBu6);
                % Set HitTest off, so that Callback of Parent is called
                set(plothandle, 'HitTest','off');
                set(self.axes_handle.sparkline_axis{i}, 'XTick',[]);
                set(self.axes_handle.sparkline_axis{i}, 'YTick',[]);
            end
        end
        
        function set_listener(self)
            self.listener_handle.timeSeries = event.listener(self.baseModel, 'timeSeriesChanged',...
                @(source,event) self.onChangedTimeSeries(source,event));
        end
    end
    
    % Static properties
    methods (Static = true)
    end
    
    % Dynamic properties
    methods
        function out = get.button_image_dark(self)
            out = zeros(74,110,3);
            out(:,:,1) = AnalyzerModel.Colors.YlGnBu3(1);
            out(:,:,2) = AnalyzerModel.Colors.YlGnBu3(2);
            out(:,:,3) = AnalyzerModel.Colors.YlGnBu3(3);
        end

        function out = get.button_image_light(self)
            out = zeros(74,110,3);
            out(:,:,1) = self.lightGrey(1);
            out(:,:,2) = self.lightGrey(2);
            out(:,:,3) = self.lightGrey(3);
        end
    end
    
    % Callback methods
    methods (Access = private)
        function resizeWindow(self, object, event)
            switch object.Tag
                case 'main_figure'
                    self.resizeMainWindow();
                case 'toolbox_panel'
                    self.resizeToolboxPanel();
                case 'toolbar_panel'
                    self.resizeToolbarPanel();
                case 'settings_panel'
                    self.resizeSettingsPanel();
                case 'plotwindow_panel'
                    self.resizePlotwindowPanel();
                otherwise
                    error('Figure Tag or Panel Tag unknown');
            end
        end
        
        function resizeMainWindow(self)
            if ~ishandle(self.figure_handle)
                return
            end
            % Get figure width and height
            fig_width = self.figure_handle.Position(3);
            fig_height = self.figure_handle.Position(4);
            
            rim = 10;
            
            toolbox_panel_height = self.toolbox_height;
            toolbox_panel_width = max(0.1,fig_width - 2*rim);
            self.panels_handle.toolbox.Position = [rim rim toolbox_panel_width toolbox_panel_height];
            
            toolbar_panel_height = self.toolbar_height;
            toolbar_panel_width = max(0.1,fig_width - 2*rim);
            self.panels_handle.toolbar.Position = [rim fig_height-toolbar_panel_height-rim ...
                toolbar_panel_width toolbar_panel_height];
            
            settings_panel_height = max(0.1, fig_height - toolbox_panel_height-toolbar_panel_height - 2*rim);
            settings_panel_width = self.settings_width;
            self.panels_handle.settings.Position = [fig_width-settings_panel_width-rim toolbox_panel_height+rim ...
                settings_panel_width settings_panel_height];
            
            plotwindow_panel_height = max(0.1,fig_height - toolbox_panel_height-toolbar_panel_height - 2*rim);
            plotwindow_panel_width = max(0.1,fig_width - settings_panel_width - 2*rim);
            self.panels_handle.plotwindow.Position = [rim toolbox_panel_height+rim ...
                plotwindow_panel_width plotwindow_panel_height];
        end
        
        function resizeToolboxPanel(self)
            if ~isfield(self.panels_handle,'toolbox')
                return
            end
            panel_width = self.panels_handle.toolbox.Position(3);
            panel_height = self.panels_handle.toolbox.Position(4);
            
            rim = 3;
            
            self.buttons_handle.toolbox_buttongroup.Position = [0 0 panel_width panel_height];
            
            button_height = panel_height - 2*rim;
            button_width = 110;
            buttongroup_children = flipud(self.buttons_handle.toolbox_buttongroup.Children);
            for i = 1 : numel(buttongroup_children)
                buttongroup_children(i).Position =...
                    [rim+(i-1)*button_width rim button_width button_height];
            end
        end
        
        function resizeToolbarPanel(self)
            panel_width = self.panels_handle.toolbar.Position(3);
            panel_height = self.panels_handle.toolbar.Position(4);
            
%             self.tabs_handle.toolbargroup.Position = self.panels_handle.toolbar.Position;
        end
        
        function resizeSettingsPanel(self)
        end
        
        function resizePlotwindowPanel(self)
            panel_width = self.panels_handle.plotwindow.Position(3);
            panel_height = self.panels_handle.plotwindow.Position(4);
            
            rim = 60;
            
            self.axes_handle.time_axis.Units = 'pixels';
            
            axes_width = max(0.1, panel_width - 2*rim);
            axes_height = max(0.1, panel_height - 2*rim);
            self.axes_handle.time_axis.Position = ...
                [rim rim axes_width axes_height];
        end
        
        function callback_buttongroup_selection(self, object, event)
            fprintf('Clicked %s\n', event.NewValue.Tag);
        end

        function callback_buttongroupSelection(self, object, event)
            if strcmp(object.Tag, 'toolbox_buttongroup')
                fprintf('Clicked %s\n', event.NewValue.Tag);
                event.OldValue.ForegroundColor = [0 0 0];
                event.OldValue.CData = self.button_image_light;
                event.NewValue.ForegroundColor = AnalyzerModel.Colors.YlGnBu9;
                event.NewValue.CData = self.button_image_dark;
            end
        end


        function callback_buttonDown(self, object, event)
            if strcmp(object.Tag, 'pushbutton_open')
            end
            if strcmp(object.Tag, 'pushbutton_reset')
                self.build();
            end
        end
    end
    
    % Event Methods
    methods (Access = private)
        function onChangedTimeSeries(self, source, event)
            timeSeries = self.baseModel.timeSeries{self.baseModel.currentDataIndex};
            sampleRate = self.baseModel.metadata{self.baseModel.currentDataIndex,...
                self.baseModel.featureNames('SamplingRate')};
            t = 1 : numel(timeSeries);
            t = t'./sampleRate;
            plot(self.axes_handle.time_axis, t, timeSeries,...
                    'Color',AnalyzerModel.Colors.YlGnBu6);
            self.draw_sparkline_axes();
        end
    end
    
end

