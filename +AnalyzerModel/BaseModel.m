classdef BaseModel < handle
    
    properties (SetObservable = true)
        n_timeSeries = 0;
        timeSeries = cell(1,10)
        currentDataIndex = 0
        frequencySeries
        
        metadata = cell(10,10);
        featureMatrix = nan(10,10);
        featureNames = containers.Map({'Filename', 'SamplingRate'},...
            {1, 2});
    end
    
    properties
        fileDialogLastPath = pwd;
        hdf5path = fullfile(pwd, '+AnalyzerModel','ModalAnalysisModel.h5');
        time_series_data
        hdf5_file_id
        dataset_id
    end
    
    properties (SetAccess = private)
    end
    
    events
        timeSeriesChanged
        frequencySeriesChanged
        errorOccurred
    end
    
    methods
        function self = BaseModel()
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
    end
    
    % Load and save
    methods (Access = private)
        function reset_data(self)
            self.timeSeries = cell(1,1);
            self.n_timeSeries = 0;
            self.currentDataIndex = 0;
        end
        
        function load_textfile(self, filename)
            self.reset_data();
            [data, metadata] = load_kistler_txt(filename);
            self.n_timeSeries = 1;
            self.timeSeries{self.n_timeSeries} = data;
            self.currentDataIndex = self.n_timeSeries;
            
            self.write_features_and_metadata(metadata);
            notify(self, 'timeSeriesChanged');
        end
        
        
        function write_features_and_metadata(self, metadata)
            self.metadata{self.currentDataIndex, self.featureNames('Filename')} = ...
                metadata.filename;
            self.metadata{self.currentDataIndex, self.featureNames('SamplingRate')} = ...
                metadata.sampling_rate;
        end
        
        function append_textfile(self, filename)
            [data, metadata] = load_kistler_txt(filename);
            self.n_timeSeries = self.n_timeSeries + 1;
            self.timeSeries{self.n_timeSeries} = data;
            self.currentDataIndex = self.n_timeSeries;
            
            self.write_features_and_metadata(metadata);
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

