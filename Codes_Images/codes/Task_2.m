%% Credit Task - 1 CT Reconstruction
% Laminogram
% Read the sinogram
sino = imread('sino_7.tif');
sino = double(sino);

% Determine number of projections from sinogram width
nAngles = size(sino, 2);
fprintf('Number of projections (columns in sinogram): %d\n', nAngles);

% Old Approach, this approach ignored the angles between 179 and 180
% degrees 
% theta = linspace(0, 179, nAngles);

%Current Approach: 0-180(excluding 180) = 448 projection
%That means 0-180(including 180) = 449 projection
%Take 449, then drop the last one, final projections = 448
% Build matching angle vector from 0 to <180 with exactly nAngles entries
theta = linspace(0, 180, nAngles + 1);
theta(end) = [];

% Reconstruct laminogram using unfiltered backprojection
laminogram = iradon(sino, theta, 'linear', 'none');

% Save laminogram to BMP with a clear name
lamino_u8 = im2uint8(mat2gray(laminogram));
imwrite(lamino_u8, 'sino_7_laminogram_unfiltered_backprojection.bmp');

% Display sinogram and laminogram side by side
figure
subplot(1,2,1)
imshow(sino, [], 'InitialMagnification', 'fit')
title('Input Sinogram')

subplot(1,2,2)
imshow(laminogram, [], 'InitialMagnification', 'fit')
title('Laminogram (Unfiltered Backprojection)')

%Filtered Backprojection
laminogram_filtered = iradon(sino, theta, 'linear', 'Ram-Lak');

% Display the filtered laminogram
figure
subplot
imshow(laminogram_filtered, [], 'InitialMagnification', 'fit')
title('Filtered Backprojection')


%% DICOM Metadata

% Read DICOM metadata
info = dicominfo('CT11.dcm');

% Display all metadata in the Command Window
disp(info)

% Extract and display key patient-related metadata
disp('Patient Information')

% Display patient name (handle struct format)
if isfield(info, 'PatientName')
    name = info.PatientName;
    if isstruct(name)
        fullName = '';
        if isfield(name, 'FamilyName')
            fullName = [fullName, name.FamilyName, ' '];
        end
        if isfield(name, 'GivenName')
            fullName = [fullName, name.GivenName];
        end
        disp(['Patient Name: ', strtrim(fullName)]);
    else
        disp(['Patient Name: ', name]);
    end
end

if isfield(info, 'PatientID')
    disp(['Patient ID: ', info.PatientID]);
end
if isfield(info, 'PatientSex')
    disp(['Patient Sex: ', info.PatientSex]);
end
if isfield(info, 'PatientAge')
    disp(['Patient Age: ', info.PatientAge]);
end
if isfield(info, 'PatientBirthDate')
    disp(['Patient Birth Date: ', info.PatientBirthDate]);
end
if isfield(info, 'StudyDate')
    disp(['Study Date: ', info.StudyDate]);
end
if isfield(info, 'Modality')
    disp(['Modality: ', info.Modality]);
end
if isfield(info, 'StudyDescription')
    disp(['Study Description: ', info.StudyDescription]);
end
if isfield(info, 'SeriesDescription')
    disp(['Series Description: ', info.SeriesDescription]);
end
if isfield(info, 'InstitutionName')
    disp(['Institution Name: ', info.InstitutionName]);
end