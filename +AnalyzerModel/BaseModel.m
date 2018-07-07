classdef BaseModel < handle
    
    properties (SetObservable = true)
        n_timeSeries = 0;
        timeSeries = cell(1,10)
        currentDataIndex = 0
        frequencySeries
        
        metadata = cell(10,10);
        featureMatrix = nan(10,10);
        metadataNames = {'Filename',...
                         'Length',...
                         'SamplingRate'};
        featureIndices
    end
    
    properties
        fileDialogLastPath = pwd;
        hdf5path = fullfile(pwd, '+AnalyzerModel','ModalAnalysisModel.h5');
        time_series_data
        hdf5_file_id
        dataset_id
        
        % view related
        lastSparkline = 1
        startupPosition = [-1600 156 1418 815]
    end
    
    properties (SetAccess = private)
    end
    
    events
        timeSeriesChanged
        frequencySeriesChanged
        currentTimeSeriesChanged
        errorOccurred
    end
    
    methods
        function self = BaseModel()
            self.init();
            self.recalculate_featureindices();
        end
    end
    
    % API
    methods (Access = public)
        function load(self, filename, fileType)
            if fileType == 1
                self.load_textfile(filename);
            end
        end
        
        function append(self, filename, fileType)
            if fileType == 1
                self.append_textfile(filename)
            end
        end
        
        function save(self)
            self.save_time_series_data_to_hdf5();
        end
        
        function setFileDialogLastPath(self, newPath)
            self.fileDialogLastPath = newPath;
        end
        
        function resetAll(self)
            self.reset_data();
        end
        
        function init(self)
            settings = load_settings();
            try
                self.startupPosition = settings('startupPosition');
            catch
            end
        end
        
        function closeFcn(self)
            settings = containers.Map();
            settings('startupPosition') = self.startupPosition;
            status = save_settings(settings);
            if ~status
                fprintf('Saving baseModel settings unsuccessful.');
            end
        end
        
        
    end
    
    % Load and save
    methods (Access = private)
        
        function reset_data(self)
            self.timeSeries = cell(1,1);
            self.n_timeSeries = 0;
            self.currentDataIndex = 0;
        end

        function recalculate_featureindices(self)
            self.featureIndices = containers.Map(...
                self.metadataNames, 1:numel(self.metadataNames));
        end
        
        function load_textfile(self, filename)
            self.reset_data();
            if ~iscell(filename)
                filename = {filename};
            end
            for i = 1 : numel(filename)
                [data, metadata] = load_kistler_txt(filename{i});
                self.n_timeSeries = i;
                self.timeSeries{self.n_timeSeries} = data;
                self.currentDataIndex = self.n_timeSeries;

                self.write_features_and_metadata(metadata);
            end
            self.lastSparkline = self.n_timeSeries;
            notify(self, 'timeSeriesChanged');
        end
        
        
        function write_features_and_metadata(self, metadata)
            self.metadata{self.currentDataIndex, self.featureIndices('Filename')} = ...
                metadata.filename;
            self.metadata{self.currentDataIndex, self.featureIndices('Length')} = ...
                metadata.length;
            self.metadata{self.currentDataIndex, self.featureIndices('SamplingRate')} = ...
                metadata.sampling_rate;
        end
        
        function append_textfile(self, filename)
            if ~iscell(filename)
                filename = {filename};
            end
            for i = 1 : numel(filename)
                [data, metadata] = load_kistler_txt(filename{i});
                self.n_timeSeries = self.n_timeSeries + 1;
                self.timeSeries{self.n_timeSeries} = data;
                self.currentDataIndex = self.n_timeSeries;
                
                self.write_features_and_metadata(metadata);
            end
            self.lastSparkline = self.n_timeSeries;
            notify(self, 'timeSeriesChanged');
        end
        
        function open_hdf5(self)
            self.hdf5_file_id = H5F.open(self.hdf5path, 'H5F_ACC_RDWR','H5P_DEFAULT');
        end
        
        function open_dataset(self, path)
            self.dataset_id = H5D.open(file_id, path);
        end
        
        function close_dataset(self, dataset_id)
            H5D.close(dataset_id);
        end
        
        function close_hdf5(self, file_id)
            H5F.close(file_id);
        end
        
        function extend_dataset(self, dataset_id, dims)
            H5D.set_extent(dataset_id, dims);
        end
        
        function save_time_series_data_to_hdf5(self)
            try
                self.open_hdf5();
                self.open_dataset('/Data/TimeSeries');
                H5D.write(self.dataset_id, 'H5ML_DEFAULT','H5S_ALL', 'H5S_ALL', self.time_series_data);
                self.close_dataset(self.dataset_id);
                self.close_hdf5(self.hdf5_file_id);
            catch ME
                disp(ME);
                H5D.close(self.dataset_id);
                H5F.close(file_id);
            end
        end
    end
    
end

