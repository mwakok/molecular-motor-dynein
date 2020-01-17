function Output = fBundles(Data, Results, Config)

% Initialize parameters
nSeeds = size(Data,1); 
width = Config.width;

% Output vector
Output = zeros(nSeeds,1);
I_sum = [];

% Calculate microtubule lattice intensities
for n = 1 : nSeeds
    
     [row,~] = size(Data{n,3});
     c = ceil(row/2);
     MTend = round(Results.MTend(n,1:2));
     if MTend(1) > 0 && MTend(2) < size(Data{n,3},2)
        I = mean(Data{n,3}(c-width:c+width,MTend(1):MTend(2)));
        I_sum = [I_sum; I'];
     end
end    

% Fit the intensity distribution to a Gaussian to obtain the mu and
% std
[N, edges] = histcounts(I_sum,250);
yData = (N/sum(N))';
xData = cumsum(diff(edges))';
ft = fittype('gauss1');
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
fitresult = fit( xData, yData, ft, opts );

% Calculate cutoff intensity
cutoff_intensity = fitresult.b1 + 4*fitresult.c1;         

for n = 1 : nSeeds
   
    [row,~] = size(Data{n,3});
    c = ceil(row/2);
    MTend = round(Results.MTend(n,1:2));
    if MTend(1) > 0 && MTend(2) < size(Data{n,3},2)
        I = mean(Data{n,3}(c-width:c+width,MTend(1):MTend(2)));
            if sum(I > cutoff_intensity) ~= 0
                Output(n,1) = 1;
            end            
    else       
        Output(n,1) = 1;
    end
end


end