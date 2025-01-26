function y = getYparams(dataType,protocol,axisType)

switch axisType

    case 'normal'

        switch dataType
            case 'phase' 
                switch protocol
                    case 'theta'
                        y.min = -pi; y.max = pi; y.dy = pi;
                        y.ticks = y.min:y.dy:y.max;
                        y.tickLabels = {'-π','0','π'};
                        y.labelstring = 'Theta Phase (rad)';
                    case 'pulse'
                        y.min = 0; y.max = 100; y.dy = 50;
                        y.ticks = y.min:y.dy:y.max;
                        y.tickLabels = compose('%d',y.ticks);
                        y.labelstring = 'Time (ms)';
                end
                y.scale = 'linear';
        
            case {'frequency','PSDfrequency'}
                y.min = 0; y.max = 250; y.dy = 50;
                y.ticks = y.min:y.dy:y.max;
                y.tickLabels = compose('%d',y.ticks);
                y.labelstring = 'Frequency (Hz)';
                y.scale = 'linear';
        
            case {'power','PSDpower'}
                switch protocol
                    case 'theta'
                    y.min = -1; y.max = 5; % ymin = 10^-1 for NRSA
                    case 'pulse'
                    y.min = -1; y.max = 5; % ymin = 10^1 for NRSA
                end
    %             y.ticks = logspace(0,4,5);
                y.ticks = y.min:y.max;
                y.tickLabels = compose('%d',y.ticks);
                y.labelstring = 'Log Peak Gamma Power (pA^{2})';
                y.scale = 'linear';
        end

    case 'log'
        switch dataType
            case {'power','PSDpower'}
                switch protocol
                    case 'theta'
                    y.min = 10^-1; y.max = 10^5; % ymin = 10^-1 for NRSA
                    case 'pulse'
                    y.min = 10^-1; y.max = 10^5; % ymin = 10^1 for NRSA
                end
                y.ticks = logspace(-1,5,7);
    %             y.ticks = y.min:y.max;
                y.tickLabels = compose('%d',log10(y.ticks));
                y.labelstring = 'Log Peak Gamma Power (pA^{2})';
                y.scale = 'log';
        end

    case 'difference'

        switch dataType
            case 'phase' 
                switch protocol
                    case 'theta'
                        y.min = -2*pi; y.max = 2*pi; y.dy = 2*pi;
                        y.ticks = y.min:y.dy:y.max;
                        y.tickLabels = {'-2π','0','2π'};
                        y.labelstring = '\Delta Theta Phase (rad)';
                    case 'pulse'
                        y.min = 0; y.max = 100; y.dy = 50;
                        y.ticks = y.min:y.dy:y.max;
                        y.tickLabels = compose('%d',y.ticks);
                        y.labelstring = '\Delta Time (ms)';
                end
                y.scale = 'linear';
        
            case 'frequency'
                y.min = -100; y.max = 100; y.dy = 25;
                y.ticks = y.min:y.dy:y.max;
                y.tickLabels = compose('%d',y.ticks);
                y.labelstring = '\Delta Frequency (Hz)';
                y.scale = 'linear';
        
            case 'power'
                switch protocol
                    case 'theta'
                    y.min = -4; y.max = 2; % ymin = 10^-1 for NRSA
                    case 'pulse'
                    y.min = -4; y.max = 2; % ymin = 10^1 for NRSA
                end
    %             y.ticks = logspace(0,4,5);
                y.ticks = y.min:y.max;
                y.tickLabels = compose('%d',y.ticks);
                y.labelstring = '\Delta Log Peak Gamma Power (pA^{2})';
                y.scale = 'linear';
        end

    case 'normalized'
        y.min = 0;
        y.max = 100;
        y.dy = 25;
        y.ticks = y.min:y.dy:y.max;
        y.tickLabels = compose('%d',y.ticks);
        y.scale = 'linear';   
        switch dataType
            case 'power'
                y.labelstring = 'Peak Gamma Power (norm)';
            case 'frequency'
                y.labelstring = 'Frequency (norm)';
            case 'phase'
                y.labelstring = 'Theta Phase (norm)';
        end

    case 'percentdiff'
        y.min = -100;
        y.max = 100;
        y.dy = 50;
        y.ticks = y.min:y.dy:y.max;
        y.tickLabels = compose('%d',y.ticks);
        y.scale = 'linear';   
        switch dataType
            case 'power'
                y.labelstring = '%\Delta Peak Gamma Power';
            case 'frequency'
                y.labelstring = '%\Delta Frequency';
            case 'phase'
                y.labelstring = '%\Delta Theta Phase';
        end
end