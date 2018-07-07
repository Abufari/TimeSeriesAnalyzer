function settings = load_settings()
try
    loaded_file = load(fullfile(pwd, 'settings.mat'));
    settings = loaded_file.settings;
catch
    settings = [];
end
end

