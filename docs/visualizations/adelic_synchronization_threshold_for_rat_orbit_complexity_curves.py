"""
Visualization 2: Orbit Complexity Growth Curves

Shows how the orbit prefix set cardinality (number of distinct orbit values
up to depth N) grows with N for different parameters c mod a fixed prime p.

Exceptional parameters exhibit early saturation (complexity collapse),
while generic parameters show continued growth — the "phase transition"
in orbit complexity that our theorems predict.
"""

import matplotlib.pyplot as plt
import numpy as np


def quad_map_mod(x, c, p):
    return (x * x + c) % p

def orbit_prefix_card(c, p, N):
    """Count distinct values in orbit up to depth N."""
    values = set()
    x = 0
    values.add(x)
    for _ in range(N):
        x = quad_map_mod(x, c, p)
        values.add(x)
    return len(values)


p = 97  # A moderately large prime
max_depth = 80
depths = list(range(1, max_depth + 1))

params_exceptional = [(0, "c = 0 (fixed)"), (-1, "c = −1 (period 2)"),
                       (-2, "c = −2 (preperiod 1)")]
params_generic = [(1, "c = 1"), (3, "c = 3"), (7, "c = 7"),
                  (13, "c = 13"), (42, "c = 42")]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle(f"Orbit Prefix Complexity Growth (mod p = {p})",
             fontsize=14, fontweight='bold')

# Panel 1: Exceptional parameters
for c, label in params_exceptional:
    complexities = [orbit_prefix_card(c, p, d) for d in depths]
    ax1.plot(depths, complexities, 'o-', markersize=2, linewidth=2, label=label)

ax1.axhline(y=p, color='gray', linestyle='--', alpha=0.5, label=f'p = {p}')
ax1.set_xlabel("Observation depth N", fontsize=12)
ax1.set_ylabel("Distinct orbit values", fontsize=12)
ax1.set_title("Exceptional Parameters\n(Early saturation = complexity collapse)", fontsize=11)
ax1.legend(fontsize=9)
ax1.set_ylim(0, max_depth)
ax1.grid(alpha=0.3)

# Panel 2: Generic parameters
for c, label in params_generic:
    complexities = [orbit_prefix_card(c, p, d) for d in depths]
    ax2.plot(depths, complexities, 'o-', markersize=2, linewidth=2, label=label)

ax2.axhline(y=p, color='gray', linestyle='--', alpha=0.5, label=f'p = {p}')
ax2.set_xlabel("Observation depth N", fontsize=12)
ax2.set_ylabel("Distinct orbit values", fontsize=12)
ax2.set_title("Generic Parameters\n(Continued growth before eventual saturation)", fontsize=11)
ax2.legend(fontsize=9)
ax2.set_ylim(0, max_depth)
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig("complexity_curves.png", dpi=150, bbox_inches='tight')
print("Saved complexity_curves.png")
