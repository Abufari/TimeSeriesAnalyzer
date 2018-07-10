path = fullfile(pwd, 'tools');
addpath(path);
path = fullfile(pwd, 'test');
addpath(path);
baseModel = AnalyzerModel.BaseModel();
AnalyzerController.MainController(baseModel);

