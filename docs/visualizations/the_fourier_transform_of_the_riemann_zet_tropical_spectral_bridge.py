"""
Visualization 3: The Tropical-Spectral Bridge

Visualizes the homomorphism property: primeFreq(a*b) = primeFreq(a) + primeFreq(b).
Shows how multiplication in the integer world corresponds to addition in frequency space,
which is the tropical product in the (max, +) semiring.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_freq(n):
    return np.log(n) / (2 * np.pi)


def factorize(n, primes):
    factors = {}
    for p in primes:
        while n % p == 0:
            factors[p] = factors.get(p, 0) + 1
            n //= p
    if n > 1:
        factors[n] = 1
    return factors


primes = sieve_primes(50)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Panel 1: The Homomorphism ---
ax1 = axes[0]
products = [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7), (5, 7),
            (2, 11), (3, 11), (2, 13), (5, 11)]

x_mul = []  # primeFreq(a*b) = primeFreq(a) + primeFreq(b)
y_sum = []

for a, b in products:
    x_mul.append(prime_freq(a * b))
    y_sum.append(prime_freq(a) + prime_freq(b))

# Perfect diagonal means homomorphism holds
ax1.scatter(x_mul, y_sum, s=60, c='#e74c3c', zorder=3, edgecolors='white', linewidths=0.5)
for i, (a, b) in enumerate(products):
    ax1.annotate(f'{a}×{b}', xy=(x_mul[i], y_sum[i]),
                 xytext=(5, 5), textcoords='offset points', fontsize=8)

lim_min = min(min(x_mul), min(y_sum)) * 0.9
lim_max = max(max(x_mul), max(y_sum)) * 1.1
ax1.plot([lim_min, lim_max], [lim_min, lim_max], 'k--', alpha=0.3, linewidth=1)
ax1.set_xlabel('primeFreq(a × b)', fontsize=11)
ax1.set_ylabel('primeFreq(a) + primeFreq(b)', fontsize=11)
ax1.set_title('Tropical Homomorphism\nMultiplication → Addition', fontsize=13, fontweight='bold')
ax1.set_xlim(lim_min, lim_max)
ax1.set_ylim(lim_min, lim_max)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# --- Panel 2: Tropical Decomposition ---
ax2 = axes[1]
# Show how integers decompose into sums of prime frequencies
test_nums = [6, 10, 12, 15, 18, 20, 21, 24, 28, 30, 35, 42]
prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71', 7: '#f39c12',
                11: '#9b59b6', 13: '#1abc9c'}

y_positions = np.arange(len(test_nums))
for yi, n in enumerate(test_nums):
    factors = factorize(n, primes)
    x_start = 0
    for p in sorted(factors.keys()):
        exp = factors[p]
        width = exp * prime_freq(p)
        color = prime_colors.get(p, '#95a5a6')
        ax2.barh(yi, width, left=x_start, height=0.6, color=color, alpha=0.8,
                 edgecolor='white', linewidth=0.5)
        if width > 0.015:
            label = f'{p}{"²" if exp == 2 else "³" if exp == 3 else "" if exp == 1 else f"^{exp}"}'
            ax2.text(x_start + width/2, yi, label, ha='center', va='center',
                     fontsize=8, fontweight='bold', color='white')
        x_start += width

ax2.set_yticks(y_positions)
ax2.set_yticklabels([str(n) for n in test_nums])
ax2.set_xlabel('Frequency ω = log(n)/(2π)', fontsize=11)
ax2.set_ylabel('Integer n', fontsize=11)
ax2.set_title('Tropical Decomposition\nFrequency = Sum of Prime Frequencies', fontsize=13, fontweight='bold')

# Legend
handles = [mpatches.Patch(color=prime_colors[p], label=f'Prime {p}') for p in [2, 3, 5, 7]]
ax2.legend(handles=handles, fontsize=9, loc='lower right')

# --- Panel 3: Log-Ratio Irrationality ---
ax3 = axes[2]
# Show the irrationality of log(p)/log(q) by plotting continued fraction convergents
from fractions import Fraction

def continued_fraction_convergents(x, n_terms=15):
    """Compute convergents of the continued fraction expansion of x."""
    convergents = []
    a = int(x)
    remainder = x - a
    p_prev, p_curr = 1, a
    q_prev, q_curr = 0, 1
    convergents.append((p_curr, q_curr))
    
    for _ in range(n_terms):
        if abs(remainder) < 1e-12:
            break
        x_new = 1.0 / remainder
        a = int(x_new)
        remainder = x_new - a
        p_prev, p_curr = p_curr, a * p_curr + p_prev
        q_prev, q_curr = q_curr, a * q_curr + q_prev
        convergents.append((p_curr, q_curr))
    
    return convergents

pairs = [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7)]
colors_pairs = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']

for (p, q), color in zip(pairs, colors_pairs):
    ratio = np.log(p) / np.log(q)
    convs = continued_fraction_convergents(ratio, 12)
    errors = [abs(ratio - num/den) for num, den in convs]
    ax3.semilogy(range(len(errors)), errors, 'o-', color=color, markersize=5,
                 label=f'log({p})/log({q}) ≈ {ratio:.6f}', linewidth=1.5)

ax3.set_xlabel('Convergent index', fontsize=11)
ax3.set_ylabel('|Approximation error|', fontsize=11)
ax3.set_title('Irrationality of Log-Ratios\n(Never reaches zero)', fontsize=13, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle('The Tropical-Spectral Bridge: Connecting Primes, Frequencies, and Tropical Algebra',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tropical_bridge.png', dpi=150, bbox_inches='tight')
print("Saved tropical_bridge.png")
