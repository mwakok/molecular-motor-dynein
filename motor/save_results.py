import pickle

def save_results(RESULTS, foldername, simPa):       
    filename = foldername + '\\' + 'SIM_DYNEIN_' + str(simPa.type) + '_' + str(simPa.concentration) + '.data'
    
    with open(filename, 'wb') as filehandle:
        pickle.dump(RESULTS, filehandle)    