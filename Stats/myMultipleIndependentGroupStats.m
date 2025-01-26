function stats = myMultipleIndependentGroupStats(allData,rowLabels,colLabels,saveFilename,savenum)
% compare between independent groups (rowLabels)

nRows = numel(rowLabels);

stats.data_table = myDataTable(allData,rowLabels);
stats.summary = mySummaryTable(allData,rowLabels); % calculate mean, SEM and N 
stats.sw = mySWstats(allData,rowLabels,colLabels);
stats.levene = myVarTest(allData,rowLabels,colLabels);

if nRows > 2
    stats.anova = myAnovaStats(allData,rowLabels);
    stats.kw = myKruskalWallisStats(allData,rowLabels);
else % nRows == 2, only 2 groups 
    stats.t2 = myUnPairedTtestStats(allData,cell_types);
    stats.rs = myUnPairedRankSumStats(allData,cell_types);
end

if savenum
    writetable(stats.data_table,saveFilename,'Sheet','Data','WriteMode','overwritesheet');  % save data table
    writetable(stats.summary,saveFilename,'Sheet','Summary','WriteMode','overwritesheet','WriteRowNames',true);  % save summary stats table
    writetable(stats.sw.results,saveFilename,'Sheet','Shapiro-Wilk','WriteMode','overwritesheet');  % save sw stats table
    writetable(stats.levene.results,saveFilename,'Sheet','Levene','WriteMode','overwritesheet');  % save levene stats table
    if nRows > 2
        writetable(stats.anova.results,saveFilename,'Sheet','ANOVA-Tukey','WriteMode','overwritesheet');  % save anova stats table
        writetable(stats.anova.tbl,saveFilename,'Sheet','ANOVA','WriteMode','overwritesheet');  % save anova stats table
        writetable(stats.kw.results,saveFilename,'Sheet','Kruskal-Wallis-Dunn-Sidak','WriteMode','overwritesheet');  % save kruskal-wallis stats table
        writetable(stats.kw.tbl,saveFilename,'Sheet','Kruskal-Wallis','WriteMode','overwritesheet');  % save kruskal-wallis stats table
    else
        writetable(stats.t2.results,saveFilename,'Sheet','Independent T-test','WriteMode','overwritesheet');  % save independent t-test stats table
        writetable(stats.rs.results,saveFilename,'Sheet','Rank Sum test','WriteMode','overwritesheet');  % save rank sum test stats table
    end
end


end