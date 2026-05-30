"""
Visualization: Image Size Collapse Under Iteration
====================================================
Demonstrates the Monotone Image Theorem: |im(f^n)| is non-increasing.
Shows how the squaring map's image collapses for different moduli,
revealing the algebraic structure (prime vs composite) through dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Image collapse curves for various moduli
moduli = [7, 10, 12, 15, 20, 30]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
max_n = 10

for N, color in zip(moduli, colors):
    sizes = []
    current = list(range(N))
    sizes.append(len(set(current)))
    for _ in range(max_n):
        current = [(x * x) % N for x in current]
        sizes.append(len(set(current)))

    # Check non-increasing (theorem verification)
    is_monotone = all(sizes[i] >= sizes[i+1] for i in range(len(sizes)-1))
    marker = 'o' if is_monotone else 'x'

    def is_prime(n):
        if n < 2: return False
        for i in range(2, int(n**0.5)+1):
            if n % i == 0: return False
        return True

    label = f'Z/{N}Z'
    if is_prime(N):
        label += ' (prime)'
    axes[0].plot(range(max_n + 1), sizes, f'{marker}-', color=color,
                linewidth=2, markersize=6, label=label)

axes[0].set_title('Image Size Collapse\n|im(f^n)| under x -> x^2',
                   fontsize=14)
axes[0].set_xlabel('Iteration n', fontsize=12)
axes[0].set_ylabel('Image size |im(f^n)|', fontsize=12)
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)

# Right panel: Stabilization point vs number of prime factors
moduli_extended = list(range(2, 60))
stab_points = []
omega_vals = []  # number of distinct prime factors

for N in moduli_extended:
    current = list(range(N))
    prev_size = N
    stab = 0
    for n in range(1, 30):
        current = [(x * x) % N for x in current]
        curr_size = len(set(current))
        if curr_size == prev_size:
            stab = n
            break
        prev_size = curr_size
    stab_points.append(stab)

    # Count distinct prime factors
    omega = 0
    temp = N
    for p in range(2, N + 1):
        if temp <= 1:
            break
        if temp % p == 0:
            omega += 1
            while temp % p == 0:
                temp //= p
    omega_vals.append(omega)

colors_scatter = []
for o in omega_vals:
    if o == 1:
        colors_scatter.append('#3498db')  # prime powers
    elif o == 2:
        colors_scatter.append('#e74c3c')
    else:
        colors_scatter.append('#2ecc71')

axes[1].scatter(moduli_extended, stab_points, c=colors_scatter, s=30, alpha=0.7)
axes[1].set_title('Stabilization Step vs Modulus\nColor: blue=prime power, red=2 factors, green=3+',
                   fontsize=13)
axes[1].set_xlabel('Modulus n', fontsize=12)
axes[1].set_ylabel('Step where image stabilizes', fontsize=12)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('image_collapse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved image_collapse.png")
