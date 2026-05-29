#!/usr/bin/env python3
"""
Visualization: Trace Transfer Theorem in Action

Illustrates the core arithmetic transfer principle: if tr(A^k) - tr(B^k)
is bounded by a prime p where the mod-p traces agree, then the integer
traces must be equal.

Shows how increasing the prime bound reveals more and more spectral
moment information, visualizing the "arithmetic tomography" metaphor.

WHY THIS MATTERS: This is the mechanism by which cheap finite-field
computation recovers expensive real-number spectral data.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import math


def sieve_primes(bound):
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(bound + 1) if is_prime[i]]


def exact_trace_pow(A, k):
    n = A.shape[0]
    M = np.eye(n, dtype=object)
    base = A.astype(object)
    exp = k
    while exp > 0:
        if exp & 1:
            M = M @ base
        base = base @ base
        exp >>= 1
    return int(np.trace(M))


def mod_p_trace_pow(A, p, k):
    n = A.shape[0]
    result = np.eye(n, dtype=int)
    base = A.copy() % p
    exp = k
    while exp > 0:
        if exp & 1:
            result = result @ base % p
        base = base @ base % p
        exp >>= 1
    return int(np.trace(result)) % p


def cycle_laplacian(n):
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i, i] = 2
        L[i, (i+1) % n] = -1
        L[(i+1) % n, i] = -1
    return L


def complete_laplacian(n):
    return n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)


# Setup
n = 8
A = cycle_laplacian(n)
B = complete_laplacian(n)

max_power = 10
prime_bounds = [3, 5, 7, 11, 13, 17, 23, 29, 37, 47, 59, 71, 83, 97]

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle("Arithmetic Trace Transfer: From Mod-p Data to Integer Equality",
             fontsize=15, fontweight='bold')

# Panel 1: Integer traces of powers
ax1 = axes[0, 0]
powers = range(1, max_power + 1)
traces_A = [exact_trace_pow(A, k) for k in powers]
traces_B = [exact_trace_pow(B, k) for k in powers]
diffs = [abs(a - b) for a, b in zip(traces_A, traces_B)]

ax1.semilogy(powers, [abs(t) + 1 for t in traces_A], 'bo-', label=f'|tr(C_{n}^k)|', markersize=6)
ax1.semilogy(powers, [abs(t) + 1 for t in traces_B], 'rs-', label=f'|tr(K_{n}^k)|', markersize=6)
ax1.semilogy(powers, [d + 1 for d in diffs], 'g^-', label='|difference|', markersize=6)
ax1.set_xlabel("Power k")
ax1.set_ylabel("Magnitude (log scale)")
ax1.set_title("Integer Traces Grow Exponentially")
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Recovery threshold — which primes are large enough?
ax2 = axes[0, 1]
recovery_matrix = np.zeros((len(prime_bounds), max_power))
for i, pb in enumerate(prime_bounds):
    primes = sieve_primes(pb)
    for k_idx, k in enumerate(powers):
        diff = diffs[k_idx]
        # Can we determine equality/inequality from primes up to pb?
        can_determine = any(p > diff for p in primes)
        recovery_matrix[i, k_idx] = 1.0 if can_determine else 0.0

im = ax2.imshow(recovery_matrix, aspect='auto', cmap='RdYlGn',
                interpolation='nearest', vmin=0, vmax=1)
ax2.set_xlabel("Power k")
ax2.set_ylabel("Prime bound P")
ax2.set_xticks(range(max_power))
ax2.set_xticklabels(range(1, max_power + 1))
ax2.set_yticks(range(len(prime_bounds)))
ax2.set_yticklabels(prime_bounds)
ax2.set_title("Moment Recovery:\nGreen = Prime Bound Sufficient")
plt.colorbar(im, ax=ax2, fraction=0.046, pad=0.04)

# Panel 3: Number of recoverable moments vs prime bound
ax3 = axes[1, 0]
recoverable = []
for pb in range(2, 100):
    primes = sieve_primes(pb)
    count = sum(1 for k in range(1, max_power + 1)
                if any(p > diffs[k-1] for p in primes))
    recoverable.append((pb, count))

pbs, counts = zip(*recoverable)
ax3.plot(pbs, counts, 'b-', linewidth=2)
ax3.axhline(y=max_power, color='r', linestyle='--', alpha=0.5, label=f'All {max_power} moments')
ax3.fill_between(pbs, counts, alpha=0.2)
ax3.set_xlabel("Prime bound P")
ax3.set_ylabel("Recoverable moments")
ax3.set_title("Arithmetic Tomography:\nMore Primes → More Spectral Data")
ax3.legend()
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, max_power + 1)

# Panel 4: Mod-p agreement for different primes
ax4 = axes[1, 1]
sample_primes = [2, 3, 5, 7, 11, 13]
k_range = range(1, 7)
bar_width = 0.12

for i, p in enumerate(sample_primes):
    agreements = []
    for k in k_range:
        agree = 1 if mod_p_trace_pow(A, p, k) == mod_p_trace_pow(B, p, k) else 0
        agreements.append(agree)
    x = np.array(list(k_range)) + i * bar_width - len(sample_primes) * bar_width / 2
    colors = ['green' if a else 'red' for a in agreements]
    ax4.bar(x, [1]*len(agreements), bar_width, color=colors, alpha=0.7,
            edgecolor='black', linewidth=0.5)

ax4.set_xlabel("Power k")
ax4.set_title("Mod-p Trace Agreement\n(Green=agree, Red=disagree)")
ax4.set_xticks(list(k_range))

# Custom legend
green_patch = mpatches.Patch(color='green', alpha=0.7, label='Traces agree mod p')
red_patch = mpatches.Patch(color='red', alpha=0.7, label='Traces differ mod p')
ax4.legend(handles=[green_patch, red_patch], fontsize=9)
ax4.set_yticks([])

# Add prime labels
for i, p in enumerate(sample_primes):
    ax4.text(1 + i * bar_width - len(sample_primes) * bar_width / 2,
             1.05, f'p={p}', fontsize=7, ha='center', rotation=45)

plt.tight_layout()
plt.savefig("transfer_theorem.png", dpi=150, bbox_inches='tight')
print("Saved transfer_theorem.png")
