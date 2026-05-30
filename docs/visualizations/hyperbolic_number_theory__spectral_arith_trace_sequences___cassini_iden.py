"""
Visualization 1: Trace Sequences and the Cassini Identity

Shows how trace sequences traceSeq(t, n) behave for different trace values t:
- Elliptic (|t| < 2): periodic oscillation
- Parabolic (|t| = 2): linear growth
- Hyperbolic (|t| > 2): exponential growth

The Cassini identity traceSeq(t,n+2)·traceSeq(t,n) - traceSeq(t,n+1)² = t²-4
is verified visually: the Cassini difference is constant for each t.
"""

import numpy as np
import matplotlib.pyplot as plt

def trace_seq(t, n):
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Elliptic trace sequences (periodic)
ax = axes[0, 0]
n_vals = np.arange(0, 25)
for t in [-1, 0, 1]:
    vals = [trace_seq(t, n) for n in n_vals]
    ax.plot(n_vals, vals, 'o-', label=f't = {t}', markersize=4)
ax.set_xlabel('Power n', fontsize=12)
ax.set_ylabel('traceSeq(t, n)', fontsize=12)
ax.set_title('Elliptic Regime (|t| < 2): Periodic', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='k', linewidth=0.5)

# Panel 2: Hyperbolic trace sequences (exponential growth)
ax = axes[0, 1]
n_vals = np.arange(0, 12)
for t in [3, 4, 5]:
    vals = [trace_seq(t, n) for n in n_vals]
    ax.semilogy(n_vals, vals, 's-', label=f't = {t}', markersize=5)
ax.set_xlabel('Power n', fontsize=12)
ax.set_ylabel('traceSeq(t, n)  [log scale]', fontsize=12)
ax.set_title('Hyperbolic Regime (|t| > 2): Exponential Growth', fontsize=13)
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Cassini identity verification
ax = axes[1, 0]
n_vals = np.arange(0, 15)
for t in [0, 1, 3, 5, 7]:
    cassini_vals = [
        trace_seq(t, n+2) * trace_seq(t, n) - trace_seq(t, n+1)**2
        for n in n_vals
    ]
    disc = t**2 - 4
    ax.plot(n_vals, cassini_vals, 'o', label=f't={t}, Δ={disc}', markersize=6)
    ax.axhline(y=disc, linestyle='--', alpha=0.5)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('traceSeq(t,n+2)·traceSeq(t,n) − traceSeq(t,n+1)²', fontsize=11)
ax.set_title('Cassini Identity: Constant = Δ = t² − 4', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Growth rate convergence to eigenvalue
ax = axes[1, 1]
n_vals = np.arange(1, 20)
for t in [3, 4, 5, 7]:
    import math
    eigenvalue = (t + math.sqrt(t**2 - 4)) / 2
    ratios = [trace_seq(t, n+1) / trace_seq(t, n) for n in n_vals]
    ax.plot(n_vals, ratios, 'D-', label=f't={t}, λ₊={eigenvalue:.3f}', markersize=4)
    ax.axhline(y=eigenvalue, linestyle=':', alpha=0.4)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('traceSeq(t, n+1) / traceSeq(t, n)', fontsize=11)
ax.set_title('Growth Rate → Dominant Eigenvalue λ₊', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Trace Sequences in Hyperbolic Number Theory', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_trace_sequences.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_trace_sequences.png")
