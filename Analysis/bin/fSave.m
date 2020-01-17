function fSave(Config, Data, Results)

HomeFolder = Config.PathName;

if Config.Save == true       
  
%     t = datetime;    
%     SaveName = strcat('Dynein_analysis','_',datestr(t),'.mat');

    SaveName = strcat('Dynein_analysis','.mat');
    SaveFolder = strcat(HomeFolder, '\Analysis\');
    SaveFile = strcat(SaveFolder, SaveName);
   
    if ~exist(SaveFolder, 'dir')
       mkdir(SaveFolder) 
    end
    
    save(SaveFile, 'Config', 'Data', 'Results');
    
else
    return
end


end