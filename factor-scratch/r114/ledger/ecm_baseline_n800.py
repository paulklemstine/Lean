"""Honest strongest-baseline measurement at the campaign's frontier instance.

n=800, alpha=0.10 -> |q2| = 80 bits, |p2| = 720 bits, N2 = 800 bits.
Uses PARI factorint(), whose OWN documentation says it includes ECM
("2: avoid first-stage ECM"), i.e. the strongest generic baseline PARI offers.
Runs in background with a hard wall-clock cap.
"""
import time, sys
sys.path.insert(0, '/home/raver1975/sage_mamba/envs/sage/lib/python3.14/site-packages')
from cypari2 import Pari
import sympy

p = Pari()
a = sympy.nextprime(2**120)   # placeholder to prove import works
print("cypari2 + sympy OK", flush=True)
