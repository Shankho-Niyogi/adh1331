#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 10 12:26:07 2023

@author: NiyoS
"""


import numpy as np                
import matplotlib.pyplot as plt   
import obspy                     
import os
from obspy.core import read
from obspy import UTCDateTime
from obspy.clients.fdsn import Client
from datetime import datetime, timedelta
import numpy as np
from pathlib import Path

client = Client("IRIS")

plt.style.use('ggplot')
plt.rcParams['figure.figsize'] = 20, 10

pathdir = 'D:\\Kansas_project\\Beam_images\\Events_and_slowness_ranges\\SAC_Data\\20160124_92400_92730_ZA\\'

ext = [".SAC"]
k=1;
for file in os.listdir(pathdir):
    file2 = Path(os.path.join(pathdir, file))
    if file.endswith(tuple(ext)):
        print(os.path.join(pathdir, file))
        if k==1:
            st_list = read((pathdir + file)) 
        if k>1:
            st_list += read((pathdir + file))
        k+=1


starttime = st_list[0].stats.starttime
endtime = st_list[0].stats.endtime
duration = endtime - starttime

freqmin_trace = 1
freqmax_trace = 7

freqmin_spec = 0.5
freqmax_spec = 10


for idx,st_current in enumerate(st_list):
    print(st_list[idx])
    try:
        st2 = st_list.copy()
        sps = int(st2[idx].stats.sampling_rate)
        st2.detrend('linear')
        st2.detrend('demean')
        st2.taper(max_percentage=0.05, type='hann')
        st2.filter('bandpass',freqmin=freqmin_trace, freqmax=freqmax_trace, corners=4, zerophase=True)
        
        # st.detrend('linear')
        # st.detrend('demean')
        # st.taper(max_percentage=0.05, type='hann')
        # st.filter('bandpass',freqmin=freqmin_spec, freqmax=freqmax_spec, corners=4, zerophase=True)
        tr = st_list[idx].copy()
        
        
        fig = plt.figure()
        ax1 = fig.add_axes([0.1, 0.75, 0.7, 0.2]) #[left bottom width height]
        ax2 = fig.add_axes([0.1, 0.1, 0.7, 0.60], sharex=ax1)
        ax3 = fig.add_axes([0.83, 0.1, 0.03, 0.6])
        
        t = np.arange(st2[idx].stats.npts) / st2[idx].stats.sampling_rate
        ax1.plot(t, st2[idx].copy().data, 'k')
        ax1.set_title(str(tr.id) +str(' :Start of Trace: ')+ str(st_list[idx].stats.starttime) + '\n' + 'Bandpass filtering of trace: '+ str(freqmin_trace)+' - '+str(freqmax_trace)+' Hz') # Add a title to the plot
        
        utc_datetime = datetime.strptime(str(st_list[idx].stats.starttime), '%Y-%m-%dT%H:%M:%S.%fZ')
        t_datetime = [utc_datetime + timedelta(seconds=float(x)) for x in t] # Convert the time values to datetime objects
        t_mins_secs = [x.strftime('%M:%S') for x in t_datetime] # Format the datetime objects as strings
        
        x_tick_pos_int = 1 #intervals in minute
        
        ax1.set_xticks(t[::x_tick_pos_int*12000]) # Set the x-tick positions to every minute
        ax1.set_xticklabels(t_mins_secs[::x_tick_pos_int*12000]) # Set the x-tick labels to the formatted strings
        
        tr.spectrogram(wlen=0.05*sps, per_lap=0.90, dbscale=True, log=False, axes=ax2, cmap='jet')
        
        ax2.set_ylim((freqmin_spec,freqmax_spec))
        
        ax2.set_ylabel('Frequency (Hz)', fontsize = 18)
        ax1.set_xticks(t[::x_tick_pos_int*12000]) # Set the x-tick positions to every minute
        ax1.set_xticklabels(t_mins_secs[::x_tick_pos_int*12000]) # Set the x-tick labels to the formatted strings
        ax2.set_xlabel('Time (mm:ss)', fontsize = 18) # Set the x-axis label
        mat_values = ax2.images[0].get_array()
        mean = np.mean(mat_values)
        std = np.std(mat_values)
        vmin = mean - 2 * std
        vmax = mean + 2 * std
        #ax2.collections[0].set_clim(vmin = 0, vmax=80) # Find the quadmesh/pcolormesh created by the spectrogram call, and then change its clims
        ax2.images[0].set_clim(vmin = vmin, vmax=vmax)
        mappable = ax2.images[0]
        cb = plt.colorbar(mappable=mappable, cax=ax3)
        cb.set_label('Power (dB/Hz)')
        
        dayname = pathdir+str(tr.stats.starttime.strftime('%Y'))+str(tr.stats.starttime.strftime('%m'))+str(tr.stats.starttime.strftime('%d'))+str('/')
        if os.path.exists(dayname):
            os.chdir(dayname)
        else:
            os.makedirs(dayname)
            os.chdir(dayname)
        plt.savefig('Spectrogram_ZA_'+st_list[idx].id+'_'+str(tr.stats.starttime.strftime('%Y'))+str(tr.stats.starttime.strftime('%m'))+str(tr.stats.starttime.strftime('%d'))+'T'+str(tr.stats.starttime.strftime('%H'))+str(tr.stats.starttime.strftime('%M'))+str(tr.stats.starttime.strftime('%S'))+'.png', dpi=150, facecolor='w', edgecolor='w')
        plt.close(fig)
    except:
        os.chdir(pathdir)
        pass                              
