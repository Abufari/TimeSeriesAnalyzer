path = fullfile(pwd, 'tools');
addpath(path);
baseModel = AnalyzerModel.BaseModel();
AnalyzerController.MainController(baseModel);

