% ------------------------------------------------------------------------ 
% Convert simulated results into microscopy data
%
%
%
% Maurits Kok
% 09-07-2018
% ------------------------------------------------------------------------

%% Create Gaussian convolution of each timepoint of a single MT profile
% Select a MT
MT=1;

% Setup size FOV
PixelSize = 0.160; % in um
steps = size(Results{MT}{1,2},1);
step_size = 24; % dynein step size in nm
L = (size(Results{MT}{1,2},2) * step_size) / 1000;

dX = 5;
FOV_X = L + 2*(dX*PixelSize); % in um
FOV_Y = 21*PixelSize; % in um

% Select data
Gauss = cell(1,steps);
FWHM = 0.70; % in um
sigma = FWHM/2.355; % in um

Intensity = 100 + 100.*rand(sum(Results{MT}{1,2}(:)),1); %a.u.
  
gsize = [FOV_X FOV_Y];
[R,C] = ndgrid(0:PixelSize:gsize(1), 0:PixelSize:gsize(2));

h = waitbar(0,'Calculating Gaussian profiles...');

for n = 1 : steps
    
    [~,ind2] = find(Results{MT}{1,2}(n,:) == 1);
    Gauss{n} = zeros(size(R,1),size(R,2));
    
    for k = 1 : length(ind2)
        xc = (ind2(k)*step_size)/1000 + (dX*PixelSize);
        yc = FOV_Y/2;
        exponent = ((R-xc).^2 + (C-yc).^2)./(2*sigma);
        val = Intensity(1).*(exp(-exponent));   
        Intensity(1,:) = [];
        Gauss{n} = Gauss{n} + val;

    end

    waitbar(n/steps);

end
Gauss{n} = Gauss{n}';
close(h);

% contour(R,C,Gauss{1300});
% pbaspect([1 1 1]);
%% Add Gaussian white noise to images

SN = 7; % Signal-to-Noise



%% Save simulated images as .tiff stack
SaveFolder = strcat(pwd, '\', date);
if exist('SaveFolder') ~= 7 && exist('SaveFolder') ~= 1    
    SaveFolder = strcat(pwd, '\', date,'\1');     
    mkdir(SaveFolder);
elseif exist('SaveFolder') ~= 1
    SaveFolder = strcat(pwd, '\', date,'\',(num2str(size(dir(SaveFolder),1)-2)));
else
    SaveFolder = strcat(SaveFolder,'\',(num2str(size(dir(SaveFolder),1)-2)));       
end

file = strcat(SaveFolder, '\Simulation.tif');
h = waitbar(0,'Saving .tif stack...');
for i = 1 : length(Gauss)
   if i == 1
      imwrite(uint16(Gauss{i}'),file,'tiff','Compression','none','WriteMode','overwrite');
   else
      imwrite(uint16(Gauss{i}'),file,'tiff','Compression','none','WriteMode','append')
   end
   
   waitbar(i/length(Gauss));
end
close(h);




