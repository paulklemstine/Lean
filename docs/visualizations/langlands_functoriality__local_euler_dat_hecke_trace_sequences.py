#!/usr/bin/env python3
"""
Visualization: Hecke trace sequences and their recurrence structure.

Plots the Hecke trace t_m = α^m + β^m for various Satake parameters,
illustrating the second-order linear recurrence proven in the Lean formalization.
"""

import numpy as np
import matplotlib.pyplot as plt


def hecke_trace_sequence(alpha, beta, length):
    if length <= 0:
        return []
    s = alpha + beta
    p = alpha * beta
    result = [2.0]
    if length == 1:
        return result
    result.append(s)
    for m in range(2, length):
        result.append(s * result[-1] - p * result[-2])
    return result


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Hecke Trace Sequences $t_m = \\alpha^m + \\beta^m$\n"
             "Governed by recurrence: $t_{m+2} = (\\alpha+\\beta)\\,t_{m+1} - \\alpha\\beta\\,t_m$",
             fontsize=13, fontweight='bold')

length = 15

# Panel 1: Real parameters
ax = axes[0]
params = [(2, 3), (1.5, 0.8), (3, 1), (1.1, 0.9)]
for alpha, beta in params:
    traces = hecke_trace_sequence(alpha, beta, length)
    ax.semilogy(range(length), [abs(t) for t in traces], 'o-',
                label=f"α={alpha}, β={beta}", markersize=4)
ax.set_title("Real Parameters", fontsize=11)
ax.set_xlabel("$m$")
ax.set_ylabel("$|t_m|$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Self-dual (β = 1/α)
ax = axes[1]
for alpha in [1.5, 2.0, 3.0, 5.0]:
    beta = 1.0/alpha
    traces = hecke_trace_sequence(alpha, beta, length)
    ax.plot(range(length), traces, 'o-',
            label=f"α={alpha}, β=1/α", markersize=4)
ax.set_title("Self-Dual: $\\beta = \\alpha^{-1}$", fontsize=11)
ax.set_xlabel("$m$")
ax.set_ylabel("$t_m$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Ratio t_{m+1}/t_m → max(|α|, |β|)
ax = axes[2]
for alpha, beta in [(2, 3), (1.5, 0.8), (3, 1)]:
    traces = hecke_trace_sequence(alpha, beta, 25)
    ratios = [abs(traces[m+1] / traces[m]) if abs(traces[m]) > 1e-10 else 0
              for m in range(len(traces)-1)]
    ax.plot(range(len(ratios)), ratios, 'o-',
            label=f"α={alpha}, β={beta}", markersize=3)
    ax.axhline(max(abs(alpha), abs(beta)), linestyle='--', alpha=0.3)
ax.set_title("Ratio $|t_{m+1}/t_m| \\to \\max(|\\alpha|, |\\beta|)$", fontsize=11)
ax.set_xlabel("$m$")
ax.set_ylabel("$|t_{m+1}/t_m|$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("hecke_traces.png", dpi=150, bbox_inches='tight')
print("Saved hecke_traces.png")
