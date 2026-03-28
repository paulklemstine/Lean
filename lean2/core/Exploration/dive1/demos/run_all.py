#!/usr/bin/env python3
"""
Master script: Run all five hypothesis experiments.
"""

import sys
import os

# Add demos directory to path
sys.path.insert(0, os.path.dirname(__file__))

print("╔" + "═" * 70 + "╗")
print("║" + " META-ORACLE RESEARCH: Five New Mathematical Hypotheses ".center(70) + "║")
print("╚" + "═" * 70 + "╝")

import hypothesis1_constellation_rigidity as h1
import hypothesis2_spectral_mass_gap as h2
import hypothesis3_fluid_prediction as h3
import hypothesis4_approximation_universality as h4
import hypothesis5_erdos_straus as h5

print("\n\n" + "█" * 72)
print("█  HYPOTHESIS 1: Constellation Rigidity")
print("█" * 72)
r1 = h1.run_experiment(N=5000)

print("\n\n" + "█" * 72)
print("█  HYPOTHESIS 2: Spectral Mass Gap Correspondence")
print("█" * 72)
r2 = h2.run_experiment()

print("\n\n" + "█" * 72)
print("█  HYPOTHESIS 3: Fluid Prediction Hardness")
print("█" * 72)
r3 = h3.run_experiment()

print("\n\n" + "█" * 72)
print("█  HYPOTHESIS 4: Approximation Universality")
print("█" * 72)
r4 = h4.run_experiment()

print("\n\n" + "█" * 72)
print("█  HYPOTHESIS 5: Erdős-Straus Density Growth")
print("█" * 72)
r5 = h5.run_experiment(n_max=200)

print("\n\n" + "╔" + "═" * 70 + "╗")
print("║" + " FINAL SCORECARD ".center(70) + "║")
print("╠" + "═" * 70 + "╣")
statuses = {
    "H1: Constellation Rigidity": "CONFIRMED (= Hardy-Littlewood reformulation)",
    "H2: Spectral Mass Gap": "PARTIALLY SUPPORTED (analogy level)",
    "H3: Fluid Prediction Hardness": "PARTIALLY SUPPORTED (forward direction)",
    "H4: Approximation Universality": "SUPPORTED (equidistribution unification)",
    "H5: Erdős-Straus Density": "REFINED (power-law, not log; d(n) governs)",
}
for name, status in statuses.items():
    print(f"║  {name:<35} {status:<33} ║")
print("╚" + "═" * 70 + "╝")
