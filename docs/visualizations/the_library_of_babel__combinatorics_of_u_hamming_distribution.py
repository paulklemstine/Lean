import math
import matplotlib.pyplot as plt
import numpy as np

def sphere_size(A, L, k):
    return math.comb(L, k) * (A - 1) ** k

A, L = 4, 16
ks = list(range(L + 1))
sizes = [sphere_size(A, L, k) for k in ks]
total = sum(sizes)
fracs = [s / total for s in sizes]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
ax1.bar(ks, sizes, color='steelblue', alpha=0.8)
ax1.set_yscale('log')
ax1.set_xlabel('Hamming Distance k')
ax1.set_ylabel('Sphere Size (log scale)')
ax1.set_title(f'Hamming Spheres: Library({A},{L})')
mean_k = L * (A-1) / A
ax2.plot(ks, fracs, 'o-', color='crimson', markersize=4)
ax2.axvline(mean_k, color='green', linestyle='--', label=f'Mean={mean_k:.1f}')
ax2.set_xlabel('Hamming Distance k')
ax2.set_ylabel('Fraction')
ax2.set_title('Distance Distribution')
ax2.legend()
plt.tight_layout()
plt.savefig('hamming_dist.png', dpi=150)
plt.show()