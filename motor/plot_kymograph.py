import matplotlib.pyplot as plt
import numpy as np



# Plot kymographs if time-series is present, i.e. frame time > 0



def plot_kymograph(RESULTS, simPa):
    """ 
    Plot kymographs 

    Paramters
    ---------

    Results
    -------

    """
    if simPa.frame_time > 0:
        # Number of plots
        if simPa.scan:
            num_scans = len(simPa.scan_range)
            rows = int(np.ceil(num_scans/3))
            cols = num_scans if num_scans < 3 else 3 
        else:
            rows = cols = 1

        # Setup figure
        fig = plt.figure(constrained_layout=True, figsize=(cols*4 ,rows*4))
        spec = fig.add_gridspec(ncols=cols, nrows=rows)

        fig_num = 0
        for row in range(rows):
            for col in range(cols):         
                if fig_num < len(simPa.scan_range):

                    # Filter specific lattice size
                    filter_length = RESULTS['Length']==simPa.scan_range[fig_num]
                    lattice = RESULTS[filter_length].Lattice           

                    # Prepare data
                    X = np.arange(0, lattice.iloc[0].shape[1])
                    X = X * (simPa.step_size/1000) # change units to um
                    Y = np.arange(0, lattice.iloc[0].shape[0])
                    Y = Y * simPa.frame_time # change units to seconds
                    X, Y = np.meshgrid(X, Y)      
                    Z_mean = np.mean(lattice, axis=0)                      

                    # Plot data
                    ax = fig.add_subplot(spec[row, col])     
                    ax.contourf(np.flip(X), Y, Z_mean, 100, cmap='PRGn')    
                    ax.set_ylim(Y[-1][0],0)  
                    ax.set_xlabel('Microtubule length ($\mu$m)', fontsize=12)
                    ax.set_ylabel('Time (s)', fontsize=12)

                    if simPa.scan:
                        ax.set_title('Length = ' + str(np.round(simPa.scan_range[fig_num]*(simPa.step_size/1000),2)) + ' $\mu$m' , fontsize=14)  
                    else:
                        ax.set_title('Kymograph (N = ' + str(simPa.num_sims) + ')', fontsize=14)

                    fig_num += 1

        # Save plot
        if simPa.record_data:
            filename = foldername + "/" + 'Figure_1'
            plt.savefig(filename+'.eps', format='eps', dpi=1200)
            plt.savefig(filename+'.png', format='png', dpi=300)

        plt.show()