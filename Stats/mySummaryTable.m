function data_table = mySummaryTable(data_all,cell_types)
nCells = numel(cell_types);

% construct data array with NaNs
maxNumEl = max(cellfun(@numel,data_all(:)));
data_all_pad = cellfun(@(x){padarray(x(:),[maxNumEl-numel(x),0],NaN,'post')}, data_all(:)); % Pad each vector with NaN values to equate lengths
data_all_mat = cell2mat(data_all_pad'); 

meanData = mean(data_all_mat,1,"omitnan");

N = sum(~isnan(data_all_mat),1);

SEM = std(data_all_mat,1,"omitnan")./sqrt(N);

% column names for cell types
varNames = cell(nCells,1);
for i = 1:nCells
    switch cell_types{i}
        case {'stellate','Stellate'}
            name = 'Stellate';
        case {'pyramidal','Pyramidal'}
            name = 'Pyramidal';
        case {'fast spiking','FastSpiking'}
            name = 'FastSpiking';
    end
    varNames{i} = name;
end

data_table = array2table([meanData; SEM; N],'VariableNames',varNames,'RowNames',{'Mean','SEM','N'});

end