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
    
    properties
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
            self.populate_metadata();
            self.populate_featureStruct();
            self.recalculate_metadata_map();
            self.preallocate_arrays();
        end
    end
    
    % Getter
    methods

        function index = getMetadataIndex(columnname)
            index = get_meta_data(columnname, 'column');
        end

        function index = getFeatureIndex(featurename)
            index = get_feature_data(featurename);
        end
        
        function metadata = getMetaData(rows_, columns_)
            rows = get_meta_data(rows_, 'row');
            columns = get_meta_data(columns_, 'column');
            metadata = self.timeSeriesMetaData(rows, columns);
        end
        
        function data = get.currentTimeData(self)
            data = self.timeSeriesData{self.currentDataIndex};
        end

        function data = get.currentFrequencyData(self)
            data = calculate_fft(self.currentTimeData);
        end
    end

    % Setter
    methods
        function index = addNewTimeSeries(self, timeSeries)
        end
    end

    methods (Access = private)
        function populate_metadata(self)
            self.timeSeriesMetaDataHead = struct(...
                'Name',{},...
                'Keywords',{});
            metadata = {...
                'Filename',...
                'Length',...
                'SamplingRate',...
                'Date',...
                'Channel',...
                'Keywords',...
                'ToT'};
            self.length_metadata = length(metadata);
            for i = 1 : self.length_metadata
                self.timeSeriesMetaDataHead(i).Name = metadata{i};
            end
        end
        
        function populate_featureStruct(self)
            features = {...
                'Length',...
                'Mean',...
                'Max'};
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
                filename = self.timeSeriesMetaData(i, filenameindex);
                self.timeSeriesFilenameRowMap(filename) = i;
            end
        end
        
        function preallocate_arrays(self)
            self.timeSeriesData = cell(1, self.preallocationNumber);
            self.timeSeriesMetaData = nan(self.preallocationNumber,self.length_metadata);
            self.featureMatrix = nan(self.preallocationNumber, self.length_features);
        end
        
        function index = add_timeSeriesData(self, timeSerie)
            index = self.length_timeSeries + 1;
            self.timeSeriesData{index} = timeSerie;
            self.length_timeSeries = index;
        end

        function index = add_timeSeriesMetadata(self, index, metadata)
            fields = fieldnames(metadata);
            for i = 1 : length(fields)
                index = self.timeSeriesMetadataColumnMap(fields{i});
                self.add_metadata_to_array(index, metadata.(fields{i}))
            end
            self.recalculate_filename_map();
        end
        
        function index = add_metadata_to_array(self, index, value)
            self.timeSeriesMetaData(self.length_timeSeries, index) = value;
        end
        
        function range = get_meta_data(range_, type)
            if isinteger(range_)
                range = range_;
            elseif ischar(range_)
                switch type
                    case 'row'
                        range = self.get_meta_data_rows_by_char(range_);
                    case 'column'
                        range = self.get_meta_data_columns_by_char(range_);
                    otherwise
                        error('passed wrong type. Must be row or column');
                end
            elseif iscell(range_)
                range = 1:length(range_);
                switch type
                    case 'row'
                        for i = 1 : length(range_)
                            range(i) = self.get_meta_data_rows_by_char(range_{i});
                        end
                    case 'column'
                        for i = 1 : length(range_)
                            range(i) = self.get_meta_data_columns_by_char(range_{i});
                        end
                    otherwise
                        error('passed wrong type. Must be row or column');
                end
            end
        end

        function rowline = get_meta_data_rows_by_char(row)
            if strcmp(row, ':')
                rowline = [1 size(self.timeSeriesMetaData, 1)];
            else
                rowline = self.timeSeriesFilenameRowMap(row);
            end
        end

        function columnline = get_meta_data_columns_by_char(column)
            if strcmp(column, ':')
                columnline = [1 size(self.timeSeriesMetaData, 1)];
            else
                columnline = self.timeSeriesMetaDataColumnMap(column);
            end
        end
    end
    
end

