"""
Visualization: Pythagorean Synchronization Spectrum
=====================================================
For each Pythagorean triple (a, b, c), shows the synchronization pattern
of a² and b² across primes. The Pythagorean Prime Synchronization theorem
guarantees that primes dividing c produce zero residues — these appear
as "holes" in the spectrum.
"""

import numpy as np
import matplotlib.pyplot as plt

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5)+1):
        if n % i == 0: return False
    return True

primes = [p for p in range(2, 60) if is_prime(p)]

triples = [
    (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
    (20, 21, 29), (9, 40, 41), (12, 35, 37), (11, 60, 61)
]

fig, axes = plt.subplots(2, 4, figsize=(18, 8))
axes = axes.flatten()

for idx, (a, b, c) in enumerate(triples):
    ax = axes[idx]

    residues = []
    colors = []
    for p in primes:
        r = (a**2 + b**2) % p
        residues.append(r)
        if c % p == 0:
            colors.append('#e74c3c')  # Hypotenuse prime — must be 0
        elif r == 0:
            colors.append('#f39c12')  # Zero but not hypotenuse prime
        else:
            colors.append('#3498db')

    ax.bar(range(len(primes)), residues, color=colors, width=0.8)
    ax.set_title(f'({a}, {b}, {c})', fontsize=12, fontweight='bold')
    ax.set_xticks(range(0, len(primes), 3))
    ax.set_xticklabels([str(primes[i]) for i in range(0, len(primes), 3)],
                        fontsize=7)
    ax.set_ylabel('a^2+b^2 mod p', fontsize=9)

    # Mark hypotenuse primes
    hyp_primes = [p for p in primes if c % p == 0]
    if hyp_primes:
        hyp_str = ','.join(str(p) for p in hyp_primes)
        ax.set_xlabel(f'p (red = divides {c})', fontsize=8)

fig.suptitle('Pythagorean Prime Synchronization Spectrum\n'
             'a^2+b^2 mod p for primes $p$ — '
             'red bars at primes dividing hypotenuse (must be 0)',
             fontsize=15, fontweight='bold')

plt.tight_layout()
plt.savefig('pythagorean_sync.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved pythagorean_sync.png")
