classdef RealTermHandleClass < handle

    properties (Access = public)
        
        % Properties
        ComPort = 'Nan';
        BaudRate = 9600;
        
        Hrealterm;                                               
        FilePointer=0;                                                   
        
        BufferSize=1;
        
    end

    methods
        % Class constructor
        function thisRealTerm = RealTermHandleClass(varargin)          
            for i = 1:2:nargin
                if  strcmp(varargin{i}, 'ComPort'), thisRealTerm.ComPort = varargin{i+1};
                elseif  strcmp(varargin{i}, 'BaudRate'), thisRealTerm.BaudRate = varargin{i+1};
                else error('Invalid argument');
                end
            end
        end

        % Writes string to the Com Port
        function void = writetocomport(thisRealTerm, stringValue)
            invoke(thisRealTerm.Hrealterm, 'putstring', stringValue); % Send the charValue to the Com Port
        end

        % Get data function
        function data = getdata(thisRealTerm)
            data = capturedata(thisRealTerm);
            data = parsedata(thisRealTerm,data);
        end

        % Convert data into an array
        function parsedData = parsedata(thisRealTerm,data)
            parsedData = split(data',newline);
            parsedData = str2double(parsedData(2:end-1));
        end

        % Get data from buffer
        function serialData = capturedata(thisRealTerm)
            % Reads data from the serial buffer, frames and parses these data.                    
            [serialData, ~] = readdatabuffer(thisRealTerm, inf);  % Read all available serial data from the com port
            
        end 

        % Create and initialize real term server
        function isInitialised = initialiserealterm(thisRealTerm)
            % Initialises Realterm buffer.
            thisRealTerm.Hrealterm = actxserver('realterm.realtermintf');   % Start Realterm as a server
            thisRealTerm.Hrealterm.baud = thisRealTerm.BaudRate;
            thisRealTerm.Hrealterm.TimerPeriod = 10000;                     % Set time-out to 10 seconds       
            thisRealTerm.Hrealterm.Port = thisRealTerm.ComPort;              % Assign the Shimmer Com Port number to the realterm server
            thisRealTerm.Hrealterm.caption = strcat('Matlab Shimmer Realterm Server COM',thisRealTerm.ComPort);   % Assign a title to the realterm server window
            thisRealTerm.Hrealterm.windowstate = 1;                         % Minimise realterm server window
            realtermBufferDirectory = strcat(pwd,'\realtermBuffer');       % Define directory for realtermBuffer
            
            if ~(exist(realtermBufferDirectory,'dir'))                     % if realtermBuffer directory does not exist then create it
                mkdir(realtermBufferDirectory);
            end
            
            thisRealTerm.Hrealterm.CaptureFile=strcat(realtermBufferDirectory,'\matlab_data_COM',thisRealTerm.ComPort,'.dat');    % define realterm buffer file name
            disp(thisRealTerm.Hrealterm.CaptureFile)
            isInitialised = true;
        end 

        % Open comPort
        function isOpen = opencomport(thisRealTerm)
            % Open COM Port.
            initialiserealterm(thisRealTerm);                               % Define and open realterm server
            try
                thisRealTerm.Hrealterm.PortOpen = true;                     % Open the COM Port
            catch
                fprintf(strcat('Warning: opencomport - Unable to open Com Port ',thisRealTerm.ComPort,'.\n'));
            end
            
            if(thisRealTerm.Hrealterm.PortOpen~=0)                          % TRUE if the COM Port opened OK
                invoke(thisRealTerm.Hrealterm,'startcapture');              % Enable realtime buffer
                thisRealTerm.FilePointer = 0;                               % Set FilePointer to start of file
                isOpen=1;
            else
                disconnect(thisRealTerm);                                   % TRUE if COM Port didnt open close realterm server
                isOpen=0;
            end
        end % opencomport

        function isCleared = clearreaddatabuffer(thisRealTerm)
            % The buffer isnt really cleared, all available data is read
            [~, isCleared] = readdatabuffer(thisRealTerm, inf);   % so that file pointer is set to end of file           
        end 
                
        function isOpen = closecomport(thisRealTerm)
            % Close COM Port.
            thisRealTerm.Hrealterm.PortOpen=0;                            % Close the COM Port
            
            if(thisRealTerm.Hrealterm.PortOpen~=0)                        % TRUE if the COM Port is still open
                isOpen=1;
                fprintf(strcat('Warning: closecomport - Unable to close COM',thisRealTerm.ComPort,'.\n'));
            else
                isOpen=0;
                closerealterm(thisRealTerm);
            end
        end % function closecomport
                
        function isClosed = closerealterm(thisRealTerm)
            % Close the Realterm server.
            invoke(thisRealTerm.Hrealterm,'stopcapture');
            isClosed = true;
            try                                                           % Try to close realterm server
                invoke(thisRealTerm.Hrealterm,'close'); delete(thisRealTerm.Hrealterm);
            catch
                isClosed = false;
                fprintf(strcat('Warning: closerealterm - Unable to close realterm for COM',thisRealTerm.ComPort,'.'))
            end
            
        end 
        
        function [bufferedData, didFileOpen] = readdatabuffer(thisRealTerm, nValues)
            % Reads data from the Realterm data buffer.
            bufferedData=[];
            
            fileId = fopen(thisRealTerm.Hrealterm.CaptureFile, 'r');        % Open file with read only permission
            if (fileId ~= -1)                                              % TRUE if file was opened successfully
                didFileOpen = true;                                        % Set isFileOpen to 1 to indicate that the file was opened
                fseek(fileId,thisRealTerm.FilePointer,'bof');               % Set file pointer to value stored from previous fread
                bufferedData=fread(fileId, nValues, '*char');             % Read data from the realterm data buffer
                thisRealTerm.FilePointer = thisRealTerm.FilePointer + length(bufferedData);  % Update FilePointer value to position of last value read
                fclose(fileId);
            else
                didFileOpen = false;                                             % Set isFileOpen to 0 to indicate that the file failed to open
                fprintf(strcat('Warning: readdatabuffer - Cannot open realterm capture file for COM',thisRealTerm.ComPort,'.\n'));
            end
            
        end 
    end
end