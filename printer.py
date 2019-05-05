"""
Embedded Python Blocks:

Each time this file is saved, GRC will instantiate the first class it finds
to get ports and parameters of your block. The arguments to __init__  will
be the parameters. All of them are required to have default values!
"""

import math
import numpy as np
from gnuradio import gr


class blk(gr.sync_block):  # other base classes are basic_block, decim_block, interp_block
    """Embedded Python Block example - a simple multiply const"""

    def __init__(self, bw_ratio=1.0):  # only default arguments here
        """arguments to this function show up as parameters in GRC"""
        gr.sync_block.__init__(
            self,
            name='SNR decibels',   # will show up in GRC
            in_sig=[np.float32,np.float32,np.float32],
            out_sig=[]
        )
        # if an attribute with the same name as a parameter is found,
        # a callback is registered (properties work, too).
        self.bw_ratio_bel = math.log10(bw_ratio)

    def work(self, input_items, output_items):
        """example: multiply with constant"""
    
        # Signal voltage in bels
        signal_bel = math.log10(input_items[1])
        # Noise voltage in bel
        noise_bel = math.log10(input_items[2])
        # SNR is (signal/noise + bandwidth)**2 * scaling constant but in log scale.
        snr = 10*(2*(signal_bel - noise_bel) + self.bw_ratio_bel)
        # Just print
        print(input_items[0][0], snr)
        return 1
