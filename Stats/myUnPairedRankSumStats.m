function rs = myUnPairedRankSumStats(data_all,cell_types)

cell_types = reshape(cell_types,[],1); % column vector

nCells = numel(cell_types); % number of comparisons

% rs.p = zeros(nCells,1); % ranksum
rs.p = cell(nCells,1); % p-value
rs.w = rs.p; % ranksum of first sample if sample sizes are unequal

for i = 1:nCells
    [rs.p{i},~,stats] = ranksum(data_all{i,1},data_all{i,2},'method','exact','tail','both');
    rs.w{i} = stats.ranksum;
end

rs.results = cell2table([cell_types rs.w rs.p],"VariableNames",{'Cell Types','W','P-value'});

% rs.results = array2table(rs.p); % set up table
% rs.results = addvars(rs.results,cell_types,'Before',1);
% rs.results.Properties.VariableNames = {'Cell Types','P-value'};

end