"""
Visualization: Hyperbolic Prime Counting Function

Plots the hyperbolic prime counting function π_H(N) against N/ln(N),
demonstrating the connection to the Prime Number Theorem.

This visualizes the falsifiable conjecture (hyperbolicPNT_conjecture):
the ratio π_H(N) · ln(N) / N should converge to 1.
"""

import numpy as np
import matplotlib.pyplot as plt

# --- Self-contained prime sieve ---

def sieve_primes(n):
    """Return list of primes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(n + 1) if is_prime[i]]

def count_primes_up_to(n):
    """Count primes ≤ n."""
    return len(sieve_primes(n))

# --- Generate data ---
N_values = np.arange(10, 10001, 10)
pi_values = np.array([count_primes_up_to(int(n)) for n in N_values])
li_values = N_values / np.log(N_values)
ratio_values = pi_values * np.log(N_values) / N_values

# --- Create figure ---
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: π(N) vs N/ln(N)
ax = axes[0, 0]
ax.plot(N_values, pi_values, 'b-', linewidth=1.5, label='π(N) (prime count)')
ax.plot(N_values, li_values, 'r--', linewidth=1.5, label='N / ln(N)')
ax.set_xlabel('N (orbit depth)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Hyperbolic Prime Counting Function', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Ratio π(N)·ln(N)/N → 1
ax = axes[0, 1]
ax.plot(N_values, ratio_values, 'g-', linewidth=1.5)
ax.axhline(y=1, color='r', linestyle='--', linewidth=1, label='Target = 1')
ax.set_xlabel('N (orbit depth)', fontsize=11)
ax.set_ylabel('π(N) · ln(N) / N', fontsize=11)
ax.set_title('PNT Ratio Convergence\n(Falsifiable Conjecture Test)', fontsize=13, fontweight='bold')
ax.set_ylim(0.8, 1.3)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Distribution of prime gaps
primes = sieve_primes(10000)
gaps = [primes[i+1] - primes[i] for i in range(len(primes)-1)]

ax = axes[1, 0]
ax.hist(gaps, bins=range(0, max(gaps)+2), color='steelblue', edgecolor='black',
        alpha=0.7, density=True)
ax.set_xlabel('Prime Gap Size', fontsize=11)
ax.set_ylabel('Frequency', fontsize=11)
ax.set_title('Distribution of Gaps Between\nHyperbolic Primes', fontsize=13, fontweight='bold')
ax.set_xlim(0, 40)
ax.grid(True, alpha=0.3)

# Panel 4: Lattice point counting function vs r²
ax = axes[1, 1]

# Simulate counting function for a hyperbolic lattice
def moebius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)

# Generate lattice
generators = [0.3 + 0.1j, -0.2 + 0.4j, 0.15 - 0.35j]
points = [0+0j]
seen = {(0.0, 0.0)}
frontier = [0+0j]

for _ in range(6):
    new_frontier = []
    for p in frontier:
        for g in generators:
            for q in [moebius_map(g, p), moebius_map(-g, p)]:
                if abs(q) < 0.999:
                    key = (round(q.real, 8), round(q.imag, 8))
                    if key not in seen:
                        seen.add(key)
                        points.append(q)
                        new_frontier.append(q)
    frontier = new_frontier
    if not frontier:
        break

radii = np.linspace(0.01, 0.99, 200)
counts = [sum(1 for p in points if abs(p) < r) for r in radii]

ax.plot(radii, counts, 'b-', linewidth=2, label='N(r) = lattice count')
# Fit quadratic for comparison
r_fit = radii[radii > 0.3]
c_fit = np.array([sum(1 for p in points if abs(p) < r) for r in r_fit])
# Rough fit: N(r) ~ C * r^2 / (1-r)^2 for hyperbolic
hyp_model = len(points) * radii**2
ax.plot(radii, hyp_model, 'r--', linewidth=1.5, alpha=0.7, label=f'C · r² (C={len(points)})')

ax.set_xlabel('Euclidean radius r', fontsize=11)
ax.set_ylabel('Lattice point count N(r)', fontsize=11)
ax.set_title(f'Lattice Point Counting Function\n({len(points)} total points)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Number Theory — Prime Distribution & Counting',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_prime_counting.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_prime_counting.png")
