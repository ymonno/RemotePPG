function setupIBIestimation()

p = mfilename('fullpath');
[installDirec,] = fileparts(p);
addpath(genpath(installDirec))

% install FastICA
disp('Installing FastICA...')
urlFastICA = 'http://research.ics.aalto.fi/ica/fastica/code/FastICA_2.5.zip';
filenameFastICA = '.';
unzip(urlFastICA,filenameFastICA)

% install facial landmark detection
disp('Installing find_face_landmarks...')
urlFind_dace_landmark = 'http://github.com/YuvalNirkin/find_face_landmarks/releases/download/1.2/find_face_landmarks-1.2-x64-vc14-release.zip';
filenameFind_face_landmark = 'find_face_landmark';
websave(filenameFind_face_landmark, urlFind_dace_landmark);
unzip(strcat(filenameFind_face_landmark,'.zip'),filenameFind_face_landmark)

addpath(genpath(installDirec))
pathDll = fullfile(filenameFind_face_landmark,'find_face_landmarks-1.2-x64-vc14-release','bin');

list = dir(pathDll);
for i = 3:length(list)
    movefile(fullfile(pathDll,list(i).name),fullfile(filenameFind_face_landmark,'find_face_landmarks-1.2-x64-vc14-release','interfaces','matlab'));
end

urlShape_predictor = 'http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2';
filenameShape_predictor = 'shape_predictor_68_face_landmarks.dat.bz2';
websave(filenameShape_predictor, urlShape_predictor);
disp('Note: Please decompress shape_predictor_68_face_landmarks.dat.bz2 by yourself!!')

end
