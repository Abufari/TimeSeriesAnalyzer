classdef MainController < handle
    %MAINCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        view
        model
    end
    
    methods
        function self = MainController()
            self.model = AnalyzerModel.BaseModel();
            self.view = gui.v_TimeSeriesAnalyzer();
            self.view.build();
            
            self.initCallbacks();
        end
    end
    
    % Callbacks
    methods
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
            self.view.buttons_handle.toolbar_reset.Callback = ...
                @self.buttonDownCallback;
        end
        
        
        function buttonDownCallback(self, object, event)
            switch object.Tag
                case 'pushbutton_open'
                    
                case 'pushbutton_reset'
                    self.view.build();
            end
        end
    end
    
end

