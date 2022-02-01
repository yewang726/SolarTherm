#! /bin/env python

from __future__ import division
import unittest

import cleantest
from solartherm import simulation
from solartherm import postproc

from math import pi
import os

class TestReference(unittest.TestCase):
	def setUp(self):
		fn = '../examples/Reference_2.mo'
		sim = simulation.Simulator(fn)
		sim.compile_model()
		sim.compile_sim(args=['-s'])
		sim.simulate(start=0, stop='1y', step='5m',solver='dassl', nls='newton')
		self.res = postproc.SimResultElec(sim.res_fn)
		self.perf = self.res.calc_perf()

	def test_sched(self):
		# Note these are set to the values for what is thought to be a working
		# version.  They are not validated against anything or independently
		# calculated.
		print(self.perf)
		self.assertTrue(abs(self.perf[0]- 423508.15)/423508.15<0.01) # epy
		self.assertTrue(abs(self.perf[1]-  149.55)/ 149.55<0.01) # LCOE
		self.assertTrue(abs(self.perf[2]- 48.34)/48.34<0.01) # Capacity factor
		cleantest.clean('Reference_2')




if __name__ == '__main__':
	unittest.main()
