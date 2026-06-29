"""Visualize the folding-funnel intuition: topological energy vs. compactness.

Generates a scatter/line plot showing that as a chain is contracted toward its
centroid (increasing compactness), its degree-0 total persistence (= extent)
decreases monotonically — the hydrophobic-collapse theorem in picture form.
Saves to 'folding_funnel.png'. Requires matplotlib.
"""
from typing import List
import matplotlib.pyplot as plt

def h0_extent(positions: List[float]) -> float:
    s = sorted(positions)
    return s[-1] - s[0]

base = [0.0, 1.0, 2.5, 4.0, 6.0, 7.5, 9.0]
centroid = sum(base) / len(base)

factors = [1.0 - 0.02 * k for k in range(46)]   # 1.0 down to 0.1
energies = []
for f in factors:
    contracted = [centroid + f * (p - centroid) for p in base]
    energies.append(h0_extent(contracted))

compactness = [1.0 - f for f in factors]

plt.figure(figsize=(7, 5))
plt.plot(compactness, energies, marker="o", color="#1f77b4")
plt.xlabel("compactness  (1 - contraction factor)")
plt.ylabel("topological energy  (H0 total persistence = extent)")
plt.title("Hydrophobic collapse: compaction lowers topological energy")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("folding_funnel.png", dpi=150)
print("saved folding_funnel.png")
