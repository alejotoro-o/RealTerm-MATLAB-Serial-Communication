close all
clear all
clc

comPort = '11';

% Create serial communication object
serialCom = RealTermHandleClass('ComPort',comPort);

% Open comPort
serialCom.opencomport;

% Initialize variables
DELAY_PERIOD = 0.2;
NO_SAMPLES_IN_PLOT = 1000;
numSamples = 0;

plotData = [];

h.figure1 = figure('Name','PLOT');  % Create a handle to figure for plotting data from shimmer
set(h.figure1, 'Position', [600, 150, 800, 600]);

% Create UI control
stopHandle = uicontrol('Style', 'PushButton', ...
                 'String', 'Close', ...
                 'Callback', @closeWindow,...
                 'position',[380 5 80 20]);


while 1      
            
    pause(DELAY_PERIOD); % Pause for this period of time on each iteration to allow data to arrive in the buffer
        
    data = serialCom.getdata();   

    if  ~isempty(data)  % TRUE if new data has arrived
         

        plotData = [plotData; data];
    
        % Number of samples in plot
        numPlotSamples = size(plotData,1);
    
        % Total number of samples
        numSamples = numSamples + size(data,1);
                               
        if numSamples > NO_SAMPLES_IN_PLOT
            plotData = plotData(numPlotSamples-NO_SAMPLES_IN_PLOT+1:end,:);
        end
        sampleNumber = max(numSamples-NO_SAMPLES_IN_PLOT+1,1):numSamples;
    
        % Plot data                                     
        plot(sampleNumber,plotData);
        xlim([sampleNumber(1) sampleNumber(end)]);

    else

        disp("NO DATA")

    end    
    
    % Close comPort and delete figure
    if stopHandle.UserData
        serialCom.closecomport;
        delete(h.figure1);
        break;
    end

end

function closeWindow(stopHandle,eventdata)
    stopHandle.UserData = true;
end