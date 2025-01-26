function IDs = removeIDs(IDs,info)

        N = numel(IDs);

        remove_flag = false(N,1);

        for i = 1:N

            fileID = IDs{i};
            fileID_index = find_index(info,'ID',fileID);
    
            cell_info = info(fileID_index);
    
            % same cell num for dnqx before and after 
            cell_num = {};
            switch cell_info.cell_type
                case 'stellate'
                    switch cell_info.experiment
                        case 'inhibition'
                            cell_num = {'17'};
                    end
                case 'pyramidal'
                    switch cell_info.experiment
                        case 'inhibition'
                            cell_num = {'50'};
                        case 'excitation'
                            cell_num = {'50'};
                    end
                case 'fast spiking'
                    switch cell_info.experiment
                        case 'inhibition'
                            cell_num = {'34','40','41'};
                        case 'excitation'
                            cell_num = {'6','33','41'};
                    end
            end
    
            if any( ismember(cell_num,cell_info.cell_num) )
                remove_flag(i) = 1;
            end

        end

        IDs(remove_flag) = [];

end