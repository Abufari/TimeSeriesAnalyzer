function [data, metadata] = load_kistler_txt(filename)
metadata = struct();
[~, name, ~] = fileparts(filename);
metadata.filename = name;

buffer = fileread(filename);

pattern = '(?<=Sampling Rate,)\w*(?= Hz)';
match = regexp(buffer, pattern, 'match');
sampling_rate = match{1};

metadata.sampling_rate = sampling_rate;


pattern = '^(.*?)(?=\n\d?.\d*,\d?.\d*)';
match = regexp(buffer, pattern, 'match');
lines_before_data = splitlines(match);
rowoffset = size(lines_before_data,1);
M = csvread(filename, rowoffset);
M_single = cast(M, 'single');
data = M_single(:,2);
end