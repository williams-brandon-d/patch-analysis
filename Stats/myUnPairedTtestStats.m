function t2 = myUnPairedTtestStats(data_all,cell_types)

cell_types = reshape(cell_types,[],1); % column vector

nCells = numel(cell_types);

% t2.p = zeros(nCells,1); % ttest
t2.p = cell(nCells,1); % ttest
t2.tstat = t2.p; % ttest
t2.df = t2.p; % ttest

for i = 1:nCells
    [~,t2.p{i},~,stats] = ttest2(data_all{i,1}, data_all{i,2},'tail','both','Vartype','equal');
    t2.tstat{i} = stats.tstat;
    t2.df{i} = stats.df;
end

t2.results = cell2table([cell_types t2.tstat t2.df t2.p],"VariableNames",{'Cell Types','T','df','P-value'});

% t2.results = array2table(t2.p); % set up table 
% t2.results = addvars(t2.results,cell_types,'Before',1);
% t2.results.Properties.VariableNames = {'Cell Types','P-value'};

end