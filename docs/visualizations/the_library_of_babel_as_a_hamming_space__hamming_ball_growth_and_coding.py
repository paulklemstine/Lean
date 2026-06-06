#!/usr/bin/env python3
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def hamming_ball_volume(A, L, r):
    return sum(math.comb(L, i) * (A-1)**i for i in range(min(r, L)+1))

configs = [(4, 16, 'A=4, L=16'), (2, 20, 'A=2, L=20'), (3, 12, 'A=3, L=12')]
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

ax = axes[0, 0]
for A, L, label in configs:
    radii = list(range(L+1))
    fracs = [hamming_ball_volume(A, L, r) / A**L for r in radii]
    ax.semilogy(radii, fracs, 'o-', markersize=3, label=label)
ax.set_xlabel('Radius r'); ax.set_ylabel('|B(v,r)| / A^L')
ax.set_title('Hamming Ball Coverage'); ax.legend(); ax.grid(True, alpha=0.3)

ax = axes[0, 1]
for A, L, label in configs:
    dists = list(range(1, L, 2))
    bounds = [A**L / hamming_ball_volume(A, L, (d-1)//2) for d in dists]
    ax.semilogy(dists, bounds, 'o-', markersize=3, label=label)
ax.set_xlabel('Min Distance d'); ax.set_ylabel('Max Code Size')
ax.set_title('Sphere-Packing Bound'); ax.legend(); ax.grid(True, alpha=0.3)

ax = axes[1, 0]
A, L = 4, 16
radii = list(range(L+1))
spheres = [math.comb(L, r) * (A-1)**r / A**L for r in radii]
ax.bar(radii, spheres, color='steelblue', alpha=0.7)
mean = L * (A-1) / A
ax.axvline(x=mean, color='red', linestyle='--', label=f'Mean={mean:.1f}')
ax.set_xlabel('Distance r'); ax.set_ylabel('Fraction')
ax.set_title('Distance Distribution'); ax.legend(); ax.grid(True, alpha=0.3)

ax = axes[1, 1]
A, L = 4, 8
D_vals = list(range(1, 200))
fibers = [(A**L + D - 1) // D for D in D_vals]
ax.plot(D_vals, fibers, 'b-', lw=2)
ax.set_xlabel('Catalog Labels D'); ax.set_ylabel('Min Max-Fiber Size')
ax.set_title(f'Catalog Pigeonhole (|Lib|={A**L:,})'); ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_hamming_balls.png', dpi=150, bbox_inches='tight')
print('Saved viz_hamming_balls.png')