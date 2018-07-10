classdef ModalAnalysisModel < handle
    
    properties (SetObservable = true)
        currentDataIndex
    end
    
    properties (Dependent = true)
        currentTimeData
        currentFrequencyData
    end
    
    properties (SetAccess = private)
        baseModel
    end
    
    properties (Access = public)
        metadata_definition = {...
                'Filename',...
                'Length',...
                'SamplingRate',...
                'Date',...
                'Channel',...
                'Keywords',...
                'ToT'};
        feature_definition = {...
                'Length',...
                'Mean',...
                'Max'};
    end
    
    % Raw data
    properties (SetAccess = private, GetAccess = public)
        timeSeriesData
        timeSeriesMetaData
        featureMatrix
        
        frequencySeriesData
        
        % Structs
        timeSeriesMetaDataHead
        featureStruct = struct(...
            'Name',{},...
            'CodeString',{},...
            'Keywords',{});

        timeSeriesMetadataColumnMap
        timeSeriesFilenameRowMap
        timeSeriesFeatureColumnMap
        
        preallocationNumber = 1000
    end
    
    properties (SetAccess = private)
        length_timeSeries = 0
        length_metadata = 0
        length_features = 0
    end
        
    events
        timeDataChanged
        frequencyDataChanged
    end
    
    methods
        function self = ModalAnalysisModel()
            self.init();
        end
        
        function init(self)
            self.init_metadataIndexing();
            self.init_featureIndexing();
            self.recalculate_metadata_map();
            self.preallocate_arrays();
        end
    end
    
    % Getter
    methods

        function index = getMetadataIndex(self, columnname)
            index = self.get_metadata_index(columnname);
        end
        
        function index = getFilenameIndex(self, filename)
            index = self.get_filename_index(filename);
        end

        function index = getFeatureIndex(self, featurename)
            index = self.get_feature_index(featurename);
        end
        
        function data = get.currentTimeData(self)
            data = self.timeSeriesData{self.currentDataIndex};
        end

        function data = get.currentFrequencyData(self)
            data = calculate_fft(self.currentTimeData);
        end
        
        function init_metadataIndexing(self)
            self.set_metadatahead();
            self.recalculate_metadata_map();
        end
        
        function init_featureIndexing(self)
            self.set_featureStruct();
            self.recalculate_metadata_map();
        end
        
        function calculate_featureVector(self)
            self.
        end
    end

    % Setter
    methods
        function index = addNewTimeSeries(self, timeSerie)
            index = self.add_timeSeriesData(timeSerie);
        end
        
        function addTimeSeriesMetadata(self, index, metadata)
            self.add_timeSeriesMetadata(index, metadata);
        end
    end

    methods (Access = private)
        function set_metadatahead(self)
            self.timeSeriesMetaDataHead = struct(...
                'Name',{},...
                'Keywords',{});
            metadata = self.metadata_definition;
            self.length_metadata = length(metadata);
            for i = 1 : self.length_metadata
                self.timeSeriesMetaDataHead(i).Name = metadata{i};
            end
        end
        
        function set_featureStruct(self)
            features = self.feature_definition;
            self.length_features = length(features);
            for i = 1 : length(features)
                self.featureStruct(i).Name = features{i};
            end
        end
        
        function recalculate_metadata_map(self)
            self.timeSeriesMetadataColumnMap = containers.Map;
            for i = 1 : length(self.timeSeriesMetaDataHead)
                self.timeSeriesMetadataColumnMap(self.timeSeriesMetaDataHead(i).Name) = i;
            end
            
            self.timeSeriesFeatureColumnMap = containers.Map;
            for i = 1 : length(self.featureStruct)
                self.timeSeriesFeatureColumnMap(self.featureStruct(i).Name) = i;
            end
        end

        function recalculate_filename_map(self)
            self.timeSeriesFilenameRowMap = containers.Map;
            for i = 1 : self.length_timeSeries
                filenameindex = self.timeSeriesMetadataColumnMap('Filename');
                filename = self.timeSeriesMetaData{i, filenameindex};
                self.timeSeriesFilenameRowMap(filename) = i;
            end
        end
        
        function preallocate_arrays(self)
            self.timeSeriesData = cell(1, self.preallocationNumber);
            self.timeSeriesMetaData = cell(self.preallocationNumber,self.length_metadata);
            self.featureMatrix = nan(self.preallocationNumber, self.length_features);
        end
        
        function index = add_timeSeriesData(self, timeSerie)
            index = self.length_timeSeries + 1;
            self.timeSeriesData{index} = timeSerie;
            self.length_timeSeries = index;
            self.currentDataIndex = index;
        end

        function add_timeSeriesMetadata(self, index, metadata)
            fields = fieldnames(metadata);
            for i = 1 : length(fields)
                column_index = self.timeSeriesMetadataColumnMap(fields{i});
                value = metadata.(fields{i});
                self.add_metadata_to_array(index, column_index, value);
            end
            self.recalculate_filename_map();
        end
        
        function add_metadata_to_array(self, row_index, column_index, value)
            self.timeSeriesMetaData{row_index, column_index} = value;
        end
        
        function index = get_metadata_index(self, columnname)
            index = self.timeSeriesMetadataColumnMap(columnname);
        end
        
        function index = get_filename_index(self, filename)
            index = self.timeSeriesFilenameRowMap(filename);
        end
        
        function index = get_feature_index(self, featurename)
            index = self.timeSeriesFeatureColumnMap(featurename);
        end
        
    end
    
end

