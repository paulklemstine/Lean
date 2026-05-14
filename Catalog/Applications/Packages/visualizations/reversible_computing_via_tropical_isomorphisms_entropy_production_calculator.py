from algorithms import EntropyCalculator
import numpy as np

calc = EntropyCalculator()
f_bij = np.array([2, 0, 3, 1])
f_nonbij = np.array([0, 0, 1, 1])
print(f"Bijective: loss={calc.uniform_entropy_loss(f_bij)}")
print(f"Non-bij: loss={calc.uniform_entropy_loss(f_nonbij)}")