classdef ModalAnalysisModel < handle
    
    properties (SetObservable = true)
        currentTimeData
        currentFrequencyData
    end
    
    properties (SetAccess = private)
        baseModel
    end
    
    events
        timeDataChanged
        frequencyDataChanged
    end
    
    methods
        function obj = ModelAnalysisModel(obj)
            obj.baseModel = BaseModel();
        end
    end
    
end

