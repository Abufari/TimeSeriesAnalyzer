classdef ModalAnalysisModel < handle
    
    properties (SetObservable = true)
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
        timeSeriesMetaDataHead = struct(...
            'Name',{},...
            'Keywords',{})
        featureStruct = struct(...
            'Name',{},...
            'CodeString',{},...
            'Keywords',{});

        timeSeriesFilenameRowMap
        timeSeriesFeatureColumnMap
    end
        
    events
        timeDataChanged
        frequencyDataChanged
    end
    
    methods
        function self = ModelAnalysisModel(self)
            self.init();
        end
        
        function init(self)
            self.populate_metadata();
            self.populate_featureMatrix();
            self.recalculate_metadata_map();
        end
    end
    
    % Getter
    methods
        function metadata = getMetaData(rows_, columns_)
            rows = get_meta_data(rows_, 'row');
            columns = get_meta_data(columns_, 'column');
            metadata = self.timeSeriesMetaData(rows, columns);
        end
    end

    methods (Access = private)
        function populate_metadata(self)
            metadata = {...
                'Filename',...
                'Length',...
                'SamplingRate',...
                'Date',...
                'Channel',...
                'Keywords',...
                'ToT'};
            for i = 1 : length(metadata)
                self.timeSeriesMetaData(i) = struct(...
                    'Name',metadata{i},...
                    'Keywords',{});
            end
        end
        
        function populate_featureMatrix(self)
            features = {...
                'Length',...
                'Mean',...
                'Max'};
            for i = 1 : length(features)
                self.featureMatrix(i) = struct(...
                    'CodeString',{},...
                    'Name',features{i},...
                    'Keywords',{});
            end
        end
        
        function recalculate_metadata_map(self)
            self.timeSeriesFilenameRowMap = containers.Map;
            for i = 1 : length(self.timeSeriesMetaDataHead)
                self.timeSeriesFilenameRowMap(self.timeSeriesMetaDataHead(i).Filename) = i;
            end
            
            for i = 1 : length(self.featureStruct)
                self.timeSeriesFeatureColumnMap(self.featureStruct(i).Name) = i;
            end
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

