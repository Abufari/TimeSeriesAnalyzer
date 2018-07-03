classdef MainController < handle
    %MAINCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        view;
        model;
        
        listener_handle;
    end
    
    methods
        function self = MainController(baseModel)
            self.model = baseModel;
            self.view = gui.v_TimeSeriesAnalyzer(baseModel);
            
            self.init();
        end
    end
    
    % Initialize Methods
    methods
        function init(self)
            self.model.resetAll();
            self.view.build();
            
            self.initCallbacks();
            self.set_listener();
        end
        function initCallbacks(self)
            self.view.figure_handle.CloseRequestFcn = ...
                @self.closeRequestFcn;
            self.view.buttons_handle.toolbox_button_timesignal.Callback =...
                @self.buttonDownCallback;
            self.view.buttons_handle.toolbox_button_frequencysignal.Callback =...
                @self.buttonDownCallback;
            self.view.buttons_handle.toolbox_button_modalanalysis.Callback =...
                @self.buttonDownCallback;
            self.view.buttons_handle.toolbox_button_tft.Callback =...
                @self.buttonDownCallback;
            self.view.buttons_handle.toolbox_button_features.Callback =...
                @self.buttonDownCallback;
            self.view.buttons_handle.toolbar_open.Callback =...
                @self.buttonDownCallback;
            self.view.buttons_handle.toolbar_append.Callback =...
                @self.buttonDownCallback;
            self.view.buttons_handle.toolbar_reset.Callback = ...
                @self.buttonDownCallback;
        end
                
        function set_listener(self)
            self.listener_handle.timeSeries = event.listener(self.view, 'sparklineAxesChanged',...
                @(source,event) self.onChangedSparklineAxes(source,event));
        end
    end
    
    % Callback Methods
    methods
        
        function closeRequestFcn(self)
        end
        
        
        function buttonDownCallback(self, object, event)
            switch object.Tag
                case 'pushbutton_open'
                    [fileName, pathName, filterIndex] = loadFileDialog(...
                        {'*.txt;*.csv','Text Files'},'Select File...', self.model.fileDialogLastPath,...
                        'MultiSelect','on');
                    if filterIndex == 0
                        return
                    end
                    self.model.fileDialogLastPath = pathName;
                    self.model.load(fullfile(pathName, fileName), filterIndex);
                    activateNewSparklineWidget(self, self.model.lastSparkline)
                case 'pushbutton_append'
                    [fileName, pathName, filterIndex] = loadFileDialog(...
                        {'*.txt;*.csv','Text Files'},'Select File...', self.model.fileDialogLastPath,...
                        'Multiselect','on');
                    if filterIndex == 0
                        return
                    end
                    self.model.fileDialogLastPath = pathName;
                    self.model.append(fullfile(pathName, fileName), filterIndex);
                    activateNewSparklineWidget(self, self.model.lastSparkline)
                case 'pushbutton_reset'
                    self.init();
            end
        end
        
        function onChangedSparklineAxes(self, object, event)
            for i = 1 : numel(self.view.axes_handle.sparkline_axis)
                self.view.axes_handle.sparkline_axis{i}.ButtonDownFcn = ...
                    @self.widgetClickCallback;
            end
        end
        
        function widgetClickCallback(self, object, event)
            newSparklineIndex = object.UserData.index;
            self.activateNewSparklineWidget(newSparklineIndex);
        end
        
        function activateNewSparklineWidget(self, newSparklineIndex)
            lastSparklineIndex = self.model.lastSparkline;
            self.model.currentDataIndex = newSparklineIndex;
            self.view.axes_handle.sparkline_axis{lastSparklineIndex}.Color = [1 1 1];
            self.view.axes_handle.sparkline_axis{newSparklineIndex}.Color = AnalyzerModel.Colors.YlGnBu2;
            self.model.lastSparkline = newSparklineIndex;
            notify(self.model, 'currentTimeSeriesChanged');
        end
    end
    
end

