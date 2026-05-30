"""
Visualization 2: Trace Growth and Chebyshev Connection
=======================================================
Shows how the trace of SL₂(ℝ) powers follows the Chebyshev
recurrence, demonstrating exponential growth for hyperbolic elements.
This connects hyperbolic dynamics to polynomial algebra.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

# === Inline functions ===

def trace_sequence_chebyshev(t, n_terms):
    """Compute tr(g^k) using Chebyshev recurrence: T_{k+2} = t·T_{k+1} - T_k"""
    traces = [2.0, t]
    for _ in range(n_terms - 2):
        traces.append(t * traces[-1] - traces[-2])
    return traces

def euler_totient(n):
    if n <= 1:
        return n
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result

# === Generate data ===
n_terms = 15

# Different traces
traces_data = {}
for t in [2.0, 2.5, 3.0, 4.0]:
    seq = trace_sequence_chebyshev(t, n_terms)
    traces_data[t] = seq

# Totient sums
ns = list(range(1, 51))
tot_sums = []
cumsum = 0
for n in ns:
    cumsum += euler_totient(n)
    tot_sums.append(cumsum)

# === Plot ===
fig, axes = plt.subplots(1, 2, figsize=(14, 6), facecolor='white')

# Left: Trace growth
ax = axes[0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
for (t, seq), col in zip(traces_data.items(), colors):
    label = f'tr(g) = {t}'
    if t == 2.0:
        ax.plot(range(n_terms), seq, 'o-', color=col, label=label, 
                markersize=4, linewidth=1.5)
    else:
        ax.plot(range(n_terms), [abs(s) for s in seq], 'o-', color=col, 
                label=label, markersize=4, linewidth=1.5)

ax.set_yscale('log')
ax.set_xlabel('Power n', fontsize=12)
ax.set_ylabel('|tr(gⁿ)|', fontsize=12)
ax.set_title('Trace Growth: Chebyshev Recurrence\n'
             r'$\mathrm{tr}(g^{n+2}) = \mathrm{tr}(g) \cdot \mathrm{tr}(g^{n+1}) - \mathrm{tr}(g^n)$',
             fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.5, n_terms - 0.5)

# Right: Totient sum growth
ax = axes[1]
ax.fill_between(ns, tot_sums, alpha=0.3, color='#3498db')
ax.plot(ns, tot_sums, 'o-', color='#2c3e50', markersize=3, linewidth=1.5,
        label=r'$\sum_{k=1}^n \varphi(k)$')
ax.plot(ns, ns, '--', color='#e74c3c', linewidth=1.5, label='n (lower bound)')
ax.plot(ns, [3*n**2/(math.pi**2) for n in ns], ':', color='#2ecc71', 
        linewidth=2, label=r'$3n^2/\pi^2$ (asymptotic)')

ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Totient Sum Growth (Farey Fraction Count)\n'
             'Proved: Σφ(k) ≥ n for all n ≥ 1',
             fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('trace_and_totient.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved trace_and_totient.png")
