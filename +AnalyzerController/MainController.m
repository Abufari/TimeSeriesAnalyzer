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
        end
    end
    
    % Callbacks
    methods
        function init(self)
            self.model.resetAll();
            self.view.build();
            
            self.initCallbacks();
            self.set_listener();
        end
        function initCallbacks(self)
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
            self.listener_handle.timeSeries = event.listener(self.model, 'timeSeriesChanged',...
                @(source,event) self.onChangedTimeSeries(source,event));
        end
        
        
        function buttonDownCallback(self, object, event)
            switch object.Tag
                case 'pushbutton_open'
                    [fileName, pathName, filterIndex] = loadFileDialog(...
                        {'*.txt;*.csv','Text Files'},'Select File...', self.model.fileDialogLastPath);
                    if filterIndex == 0
                        return
                    end
                    self.model.fileDialogLastPath = pathName;
                    self.model.load(fullfile(pathName, fileName), filterIndex);
                case 'pushbutton_append'
                    [fileName, pathName, filterIndex] = loadFileDialog(...
                        {'*.txt;*.csv','Text Files'},'Select File...', self.model.fileDialogLastPath);
                    if filterIndex == 0
                        return
                    end
                    self.model.fileDialogLastPath = pathName;
                    self.model.append(fullfile(pathName, fileName), filterIndex);
                case 'pushbutton_reset'
                    self.init();
            end
        end
        
        function onChangedTimeSeries(self, object, event)
            for i = 1 : numel(self.view.axes_handle.sparkline_axis)
                self.view.axes_handle.sparkline_axis{i}.ButtonDownFcn = ...
                    @self.widgetClickCallback;
            end
        end
        
        function widgetClickCallback(self, object, event)
            index = object.UserData.index;
            self.model.currentDataIndex = index;
            object.Color = AnalyzerModel.Colors.YlGnBu9;
            notify(self.model, 'timeSeriesChanged');
        end
    end
    
end

