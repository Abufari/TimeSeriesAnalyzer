classdef ModalAnalysisModelTest < matlab.unittest.TestCase
    
    properties
        model
        timeSeriesData
        timeSeriesMetadata
    end
    
    methods (TestClassSetup)
        function createModelAndData(testCase)
            testCase.model = AnalyzerModel.ModalAnalysisModel();
            testCase.timeSeriesData = [1 2 3 5 6 4 3 7 2]';
            testCase.timeSeriesMetadata = struct(...
                'Filename','TestCaseNo1',...
                'Length',9,...
                'SamplingRate',10,...
                'ToT',143.24642356);
            
%             testCase.addTeardown();
        end
    end
    
    methods (TestMethodSetup)
        function initiateModel(testCase)
%             i = testCase.model.addNewTimeSeries(testCase.timeSeriesData);
%             metadata = testCase.timeSeriesMetadata;
%             testCase.model.addTimeSeriesMetadata(i, metadata);
        end
    end
    
    methods (Test)
        function addTimeSeriesAndMetadata(testCase)
            i = testCase.model.addNewTimeSeries(testCase.timeSeriesData);
            metadata = testCase.timeSeriesMetadata;
            testCase.model.addTimeSeriesMetadata(i, metadata);
            
            testCase.assertEqual(testCase.model.currentDataIndex, 1);
            
            secondTime = [3 2 1];
            metadata = struct('Filename','TestCaseNo2','Length',3);
            i = testCase.model.addNewTimeSeries(secondTime);
            testCase.model.addTimeSeriesMetadata(i, metadata);
            testCase.verifyEqual(testCase.model.currentDataIndex, 2);
        end
        
        function testGetMetadataIndex(testCase)
            index = testCase.model.getMetadataIndex('Filename');
            testCase.verifyEqual(index, 1);
            index = testCase.model.getMetadataIndex('SamplingRate');
            testCase.verifyEqual(index, 3);
            
            try
                index = testCase.model.getMetadataIndex('NoRealKey');
            catch ME
                testCase.verifyEqual(ME.identifier, 'MATLAB:Containers:Map:NoKey');
                index = [];
            end
            testCase.verifyEmpty(index);
        end
        
        function testInit_metadataIndexing(testCase)
            testCase.model.metadata_definition = {...
                'Filename',...
                'Length',...
                'SamplingRate',...
                'Date',...
                'Channel',...
                'Keywords',...
                'ToT'};
            testCase.model.init_metadataIndexing();
        end
        
        function testInit_featureIndexing(testCase)
            testCase.model.feature_definition = {...
                'Length',...
                'Mean',...
                'Max',...
                'AddedForThisTest'};
            testCase.model.init_featureIndexing();
        end
        
        function testGetFilenameIndex(testCase)
            index = testCase.model.getFilenameIndex('TestCaseNo1');
            testCase.verifyEqual(index, 1);
            
            try
                index = testCase.model.getFilenameIndex('NoRealKey');
            catch ME
                testCase.verifyEqual(ME.identifier, 'MATLAB:Containers:Map:NoKey');
                index = [];
            end
            testCase.verifyEmpty(index);
        end
        
        function testGetFeatureIndex(testCase)
            
            index = testCase.model.getFeatureIndex('Length');
            testCase.verifyEqual(index, 1);
            index = testCase.model.getFeatureIndex('Max');
            testCase.verifyEqual(index, 3);
            index = testCase.model.getFeatureIndex('AddedForThisTest');
            testCase.verifyEqual(index, 4);
            
            try
                index = testCase.model.getFeatureIndex('NoRealKey');
            catch ME
                testCase.verifyEqual(ME.identifier, 'MATLAB:Containers:Map:NoKey');
                index = [];
            end
            testCase.verifyEmpty(index);
        end
        
        function testGetCurrentTimeData(testCase)
            data = testCase.model.currentTimeData;
            testCase.verifyEqual(data, [3 2 1]);
            old_index = testCase.model.currentDataIndex;
            
            testCase.model.currentDataIndex = 1;
            data = testCase.model.currentTimeData();
            testCase.verifyEqual(data, testCase.timeSeriesData);
            testCase.model.currentDataIndex = old_index;
        end
        
        function test_currentmetadata(testCase)
            index = testCase.model.currentDataIndex;
            column = testCase.model.getMetadataIndex('SamplingRate');
            fs = testCase.model.timeSeriesMetaData{index,column};
            testCase.verifyEmpty(fs);
            
            row = testCase.model.getFilenameIndex('TestCaseNo1');
            column = testCase.model.getMetadataIndex('ToT');
            tot = testCase.model.timeSeriesMetaData{row, column};
            testCase.verifyLessThan(abs(tot-143.24642356), 1e-5);
        end
        
        function test_getFeatureLength(testCase)
            column = testCase.model.getFeatureIndex('Length');
            length = testCase.model.featureMatrix(1:testCase.model.length_timeSeries,column);
            testCase.verifyEqual(length, [9; 3]);
        end
        
        function test_getFeatureMean(testCase)
            column = testCase.model.getFeatureIndex('Mean');
            length = testCase.model.featureMatrix(1:testCase.model.length_timeSeries,column);
            testCase.verifyLessThan(abs(length - [3.6667; 3]), 1e-5);
        end
        
        function test_getFeatureMax(testCase)
            column = testCase.model.getFeatureIndex('Max');
            length = testCase.model.featureMatrix(1:testCase.model.length_timeSeries,column);
            testCase.verifyEqual(length, [7; 3]);
        end
    end
    
end

