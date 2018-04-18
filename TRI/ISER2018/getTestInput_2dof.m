function [ Psysid_V, Ptest_V ] = getTestInput_2dof( testPoints, params, filename )
%getTestInput_2dof - creates the control input files for sysid and testing
%on the 2dof system
%   varargin is the name of the folder the csv's are to be saved in

Psysid_Pa = calcPressureSysidPoints(params);    % sysid control pressure [Pa]
Psysid_V = Pa2V(Psysid_Pa, params);     % sysid control pressure [V]
Psysid_V = [zeros(size(Psysid_V(:,1))), Psysid_V];  % add column of zeros since only using valves 2-4

Ptest_Pa = calcPressureTestPoints(testPoints, params);  % test control pressure [Pa]
Ptest_V = Pa2V(Ptest_Pa, params);       % test control pressure [V]
Ptest_V = [zeros(size(Ptest_V(:,1))), Ptest_V];  % add column of zeros since only using valves 2-4


%% save these pressures as .csv files

% check for optional argument, if given, save params as .mat file with that name
if exist('filename','var')
    current_folder = cd;
    dir = strcat(current_folder, '\testPoints\', varargin);
    mkdir(char(dir));
    
    saveas1 = strcat(dir, '\sysid.csv');
    csvwrite(char(saveas1), Psysid_V, 0, 0);
    
    saveas2 = strcat(dir, '\test.csv');
    csvwrite(char(saveas2), Ptest_V, 0, 0);
end

end
