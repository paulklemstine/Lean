"""
Visualization: Tsallis-2 Entropy Approximation

Shows how the normalized parabolic weight w_q(c)/n^2 converges to
(log q / 2) * H_2(p) as n grows, where H_2(p) = 1 - sum(p_i^2)
is the Tsallis-2 entropy.
"""
import math
import matplotlib.pyplot as plt
import numpy as np

def q_int(q, k):
    return sum(q**i for i in range(k)) if k > 0 else 0

def q_factorial(q, k):
    r = 1
    for i in range(1, k+1): r *= q_int(q, i)
    return r

def q_multinomial(q, c):
    if len(c) <= 1: return 1
    n = sum(c)
    r = q_factorial(q, n)
    for ci in c: r //= q_factorial(q, ci)
    return r

def cross_term(c):
    t, s = 0, sum(c)
    for ci in c: s -= ci; t += ci * s
    return t

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
q = 2

# Left: Scatter plot of w/n^2 vs (log q / 2) * H2(p)
ax = axes[0]
for n in range(2, 8):
    from itertools import combinations_with_replacement
    # Generate some compositions of n
    comps = []
    def gen_comp(n, prefix=[]):
        if n == 0:
            if prefix: comps.append(prefix[:])
            return
        for k in range(1, n+1):
            prefix.append(k)
            gen_comp(n-k, prefix)
            prefix.pop()
    gen_comp(n)

    actuals, approxs = [], []
    for c in comps:
        qm = q_multinomial(q, c)
        if qm <= 0: continue
        w = math.log(qm)
        p = [ci/n for ci in c]
        h2 = 1 - sum(x**2 for x in p)
        actuals.append(w / n**2)
        approxs.append((math.log(q) / 2) * h2)

    ax.scatter(approxs, actuals, s=15, alpha=0.7, label=f'n={n}')

mn, mx = 0, max(max(a for a in [0.01]), 0.5)
ax.plot([0, 0.4], [0, 0.4], 'k--', alpha=0.5, label='y = x')
ax.set_xlabel('(log q / 2) · H₂(p)', fontsize=13)
ax.set_ylabel('w_q(c) / n²', fontsize=13)
ax.set_title('Tsallis-2 Approximation (q=2)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Error decay as function of n
ax = axes[1]
ns_plot = list(range(2, 9))
max_errors = []
mean_errors = []

for n in ns_plot:
    comps = []
    def gen_comp2(n, prefix=[]):
        if n == 0:
            if prefix: comps.append(prefix[:])
            return
        for k in range(1, n+1):
            prefix.append(k)
            gen_comp2(n-k, prefix)
            prefix.pop()
    gen_comp2(n)

    errors = []
    for c in comps:
        qm = q_multinomial(q, c)
        if qm <= 0: continue
        w = math.log(qm)
        p = [ci/n for ci in c]
        h2 = 1 - sum(x**2 for x in p)
        actual = w / n**2
        approx = (math.log(q) / 2) * h2
        errors.append(abs(actual - approx))

    max_errors.append(max(errors))
    mean_errors.append(sum(errors)/len(errors))

ax.plot(ns_plot, max_errors, 'ro-', label='Max error', markersize=6)
ax.plot(ns_plot, mean_errors, 'bs-', label='Mean error', markersize=6)
ax.plot(ns_plot, [math.log(q)/n for n in ns_plot], 'g--', label='log(q)/n', linewidth=2)
ax.set_xlabel('n', fontsize=13)
ax.set_ylabel('|w/n² - (log q/2)·H₂|', fontsize=13)
ax.set_title('Approximation Error Decay (q=2)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tsallis_approximation.png', dpi=150, bbox_inches='tight')
print("Saved tsallis_approximation.png")
