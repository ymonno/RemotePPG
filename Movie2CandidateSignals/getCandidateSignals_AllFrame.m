%**************************************************************************
% We have referred 'Robust Heart Rate Measurement from Video Using Select
% Random Patches', in ICCV2015 by A. Lam and Y. Kuno to implement the code.
%
% Inputs
%  videoFileName: path to the movie
%  isDisplayFacialLandmark: If you want to see detected landmarks at the
%  first frame, please set to '1'. If you don't, please set to '0'.
%  startTime: start time of the video [sec]
%  endTime: end time of the video [sec]
%
% Outputs
%  bvpCandidates: BVP candidates
%  frameRate: framerate of the movie
%  time: timestamp of BVP [sec]
%
% Last Update: August 13, 2019
%**************************************************************************
function [bvpCandidates,frameRate,time] = getCandidateSignals_AllFrame(videoFileName,isDisplayFacialLandmark,startTime,endTime)

tic
% load frame data
vidObj = VideoReader(videoFileName);
frameRate = vidObj.Framerate;
frames2Use = [round(startTime*frameRate+1):round(endTime*frameRate+1)];

% parameter setting
patchsize = 0.2; % size of face patches
% freqRange = 0.7:0.01:4; % range of possible human heart rates frequency
movingAvePoints = frameRate/5; % number of points for temporal smoothing
numPairs = 500; % number of face patch pairs
numComponents = 2; % number of ICA outputs
n = 2; % the number of ICA input
channel = 2*ones(1,n); % use the green channel in all patches.

% path setting
[direc,name] = fileparts(videoFileName);
addpath(genpath(direc))

%% detect facial landmarks
landmarksName = fullfile(direc,[name '_trackedLandmarks_frames.mat']);

if ~exist(landmarksName,'file')
    disp('Detecting facial landmarks...');
    modelFile = 'shape_predictor_68_face_landmarks.dat';
    % Dlib facial landmark detection
    trackedLandmarks = find_face_landmarks(modelFile,videoFileName,1,1,0);
    
    if isempty(trackedLandmarks(1).faces)
        trackedLandmarks(1).faces =trackedLandmarks(2).faces;
    end
    
    save(landmarksName,'trackedLandmarks');
    disp('Saved facial landmarks')
else
    disp('Loading facial landmarks...');
    S = load(landmarksName);
    trackedLandmarks = S.trackedLandmarks;
    clear S
end
trackedLandmarks = trackedLandmarks(frames2Use);

% load random patch seeds
pointdirec = 'patchFile.mat';
S = load(pointdirec);
points = S.points;
clear S

% bounding box definition based on the facial landmarks on the first frame
% pixels outside the bounding box will be discarded
bboxTopY = trackedLandmarks(1).faces.landmarks(42,2);
bboxBottomY = trackedLandmarks(1).faces.landmarks(59,2);
bboxLeftX = trackedLandmarks(1).faces.landmarks(18,1);
bboxRightX = trackedLandmarks(1).faces.landmarks(27,1);

% patch size definition based on the bounding box size of the first frame
% delta is half width of the patch
delta = double((bboxBottomY - bboxTopY)*patchsize);
yRange = bboxBottomY-bboxTopY-2*delta;
xRange = bboxRightX-bboxLeftX-2*delta;

% initialize variables
traces = zeros(n,length(frames2Use));
time = zeros(1,length(frames2Use));
isReliable = true(1, numPairs);
bvpCandidates = cell(1,numPairs);
vidFrame = cell(1,length(frames2Use));

% read video frame
frameCnt = 0; % initialize frame count
vidObj.CurrentTime = startTime;
while hasFrame(vidObj) && (vidObj.CurrentTime <= endTime)
    frameCnt = frameCnt+1;
    time(frameCnt) = vidObj.CurrentTime;
    vidFrameTemp = readFrame(vidObj);
    vidFrame{1,frameCnt} = vidFrameTemp(bboxTopY:bboxBottomY,bboxLeftX:bboxRightX,:);
    
    % display facial landmarks
    if frameCnt ==1 && isDisplayFacialLandmark ==1
        f = figure;
        imshow(vidFrameTemp);
        hold on
        scatter(trackedLandmarks(1).faces.landmarks(:,1),trackedLandmarks(1).faces.landmarks(:,2),'MarkerEdgeColor','g','MarkerFaceColor','g');
        title('Detected landmarks')
        drawnow
        hold off
    end
end

%% estimate candidate BVP signals via random patch sampling
disp('Estimating candidate BVP signals via ramdom patch sampling...');
for pairCnt = 1:numPairs
    for patchCnt = 1:n
        % x and y indecate the center point of the patches
        y = zeros(1,length(trackedLandmarks));
        x = zeros(1,length(trackedLandmarks));
        % randamly select initial center point of the patches
        y(1,1) = points{pairCnt}{patchCnt}(1)*yRange + double(bboxTopY + delta);
        x(1,1) = points{pairCnt}{patchCnt}(2)*xRange + double(bboxLeftX + delta);
        
        for frameCnt = 2:length(trackedLandmarks)
            if isempty(trackedLandmarks(frameCnt).faces)
                trackedLandmarks(frameCnt).faces.landmarks = trackedLandmarks(frameCnt-1).faces.landmarks;
                % If detecter can't find facial landamrks, copy landmarks
                % of the previous frame
            end
            % center points of the facial patches to track facial movement
            previousLandmarks = trackedLandmarks(frameCnt-1).faces.landmarks(18:36,:);
            presentLandmarks = trackedLandmarks(frameCnt).faces.landmarks(18:36,:);
            transform = computeRigidTransformation(double(previousLandmarks),double(presentLandmarks));
            transformedPts = (transform*[x(:,frameCnt-1) y(:,frameCnt-1) 1]')';
            y(1,frameCnt) = transformedPts(:,2);
            x(1,frameCnt) = transformedPts(:,1);
        end
        % smoothing of patch movement
        movingAvePoints = round(frameRate/5);
        y = moving(y',movingAvePoints)';
        x = moving(x',movingAvePoints)';
        for frameCnt = 1:length(trackedLandmarks)
            % compute average intensity values within the patch
            patchStartY = round(max(y(frameCnt)-double(delta+bboxTopY),1));
            patchEndY = round(min(y(frameCnt)+double(delta-bboxTopY),size(vidFrame{1,1},1)));
            patchStartX = round(max(x(frameCnt)-double(delta+bboxLeftX),1));
            patchEndX = round(min(x(frameCnt)+double(delta-bboxLeftX),size(vidFrame{1,1},2)));
            traces(patchCnt,frameCnt) = mean(mean(double(vidFrame{1,frameCnt}(patchStartY:patchEndY,patchStartX:patchEndX,channel(1,patchCnt)))));
        end
    end
    
    % noise reduction by moving average filter
    traces = moving(traces',movingAvePoints)';
    ica_time_IDX = 0;
    
    % run ICA to separate BVP-derived and noise components
    while size(bvpCandidates{1,pairCnt},1)<numComponents
        [bvpCandidates{1,pairCnt},~,~] = fastica(traces,'numOfIC',numComponents,'verbose','off','stabilization','off');
        % if ICA only provides one component, run ICA again for 10 times
        ica_time_IDX = ica_time_IDX +1;
        % If ICA only provides one component after ten times iteration,
        % the pair of patchs is regarded as not reliable
        if ica_time_IDX ==10
            break
        end
    end
    
    % select BVP-derived component
    if~(size(bvpCandidates{1,pairCnt},1)<numComponents)
        d = zeros(numComponents,1);ChoseSignalIdx = zeros(1,numComponents);
        for patchCnt  = 1:numComponents
            % we heuristically decide which of ICA outputs is BVP
            % we regard BVP is more different from input signals than noise signal.
            L2_norm = sum((traces - repmat(bvpCandidates{1,pairCnt}(patchCnt,:),numComponents,1)).^2,2);
            d(patchCnt) = min(L2_norm);
            
            lambda = 100/((60/frameRate)^2);
            bvpCandidates{1,pairCnt}(patchCnt,:) = detrendingFilter(bvpCandidates{1,pairCnt}(patchCnt,:)',lambda)';
            bvpCandidates{1,pairCnt}(patchCnt,:) = moving(bvpCandidates{1,pairCnt}(patchCnt,:),movingAvePoints);
            [bvpCandidates{1,pairCnt}(patchCnt,:),side(1,patchCnt)] = findSide(bvpCandidates{1,pairCnt}(patchCnt,:),traces,lambda);
        end
        [~,idx] = min(d); % select BVP flag
        ChoseSignalIdx(1,idx) = -1;
        
        bvpCandidates{1,pairCnt}(ChoseSignalIdx(1,:)==-1,:) = [];
        if ChoseSignalIdx==[-1,-1]
            isReliable(1,pairCnt) = false;
        end
    else
        disp(['ICA failed at ',num2str(pairCnt),'the patches...'])
        isReliable(1,pairCnt) = false;
    end
    disp([num2str(pairCnt),'/',num2str(numPairs)])
end
bvpCandidates = bvpCandidates(isReliable);
toc

end

