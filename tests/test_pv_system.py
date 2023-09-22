#! /bin/env python

from __future__ import division
import unittest

import cleantest
from solartherm import simulation
import DyMat

from math import pi
import os

class Test(unittest.TestCase):
	def setUp(self):
		fn = '../examples/PV_system.mo'
		sim = simulation.Simulator(fn)
		sim.compile_model()
		sim.compile_sim(args=['-s'])
		sim.simulate(start=0, stop='1y', step='1h', tolerance = '1e-06', solver='dassl', nls='newton')
		self.res_fn = sim.res_fn


	def test_sched(self):

		# the comparison values were checked with the SAM Detailed PV model
		res = DyMat.DyMatFile(self.res_fn)
		E_pv=res.data('E_pv')[-1] # J
		N_inverter=res.data('PVArray.N_inv')[-1]
		N_series=res.data('PVArray.N_series')[-1]
		N_modules=res.data('PVArray.N_module')[-1]		
		ele_PV=res.data('ele_s')[-1] # pv panel elevation angle (fixed track)							

		self.assertTrue(abs(E_pv - 1.3e14)/1.3e14<0.01) # epy J
		self.assertTrue(N_inverter==32) 
		self.assertTrue(N_series==11) 
		self.assertTrue(N_modules==48163) 
		self.assertTrue(ele_PV==40) 		

		cleantest.clean('PV_system')




if __name__ == '__main__':
	unittest.main()
