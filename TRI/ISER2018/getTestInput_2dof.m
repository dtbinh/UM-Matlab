function [Ptest_V, Ptest_Pa] = getTestInput_2dof( testPoints, params, testname, pointsname )
%getTestInput_2dof - creates the control input files for testing on the 2dof system
%   testname is the name of the folder the csv's are to be saved in

Ptest_Pa = calcPressureTestPoints(testPoints, params);  % test control pressure [Pa]

% Make sure all of the input points are feasable before proceeding
proceed = input('Are all of the testPoints feasable? y = 1, 0 = n: ');
if proceed ~= 1
    disp('Try different dimension of test region until all point are feasable.');
    return;
end

Ptest_V = Pa2V(Ptest_Pa, params);       % test control pressure [V]
Ptest_V = [zeros(size(Ptest_V(:,1))), Ptest_V];  % add column of zeros since only using valves 2-4


%% save these pressures as .csv files

% check for optional argument, if given, save csv files with that name
if exist('testname','var')
    current_folder = cd;
    dir = strcat(current_folder, '\testPoints\', testname);
    
    % save csv file of control inputs
    saveas1 = strcat(dir, '\', pointsname, '_test.csv');
    csvwrite(char(saveas1), Ptest_V, 0, 0);
    
    % create blank csv file of test data. Will be filled in by labview
    saveas2 = strcat(dir, '\', pointsname, '_testData.csv');
    csvwrite(char(saveas2), [], 0, 0)

    
%     % save csv file of control inputs
%     saveas1 = strcat(dir, '\test.csv');
%     csvwrite(char(saveas1), Ptest_V, 0, 0);
%     
%     % create blank csv file of test data. Will be filled in by labview
%     saveas2 = strcat(dir, '\testData.csv');
%     csvwrite(char(saveas2), [], 0, 0)
end

end

