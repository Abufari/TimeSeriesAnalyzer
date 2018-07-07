function status = save_settings(settings)
try
    save(fullfile(pwd,'settings.mat'), 'settings')
    status = true;
catch
    status = false;
end
end

