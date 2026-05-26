"""
Visualization: Normalized Free Energy Convergence

Plots the normalized parabolic free energy F^par_{n,q}(beta) = (1/n) * log(Pi)
as a function of n for different values of q, showing convergence behavior.
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

def compositions(n):
    if n == 0: return [[]]
    result = []
    for k in range(1, n+1):
        for rest in compositions(n-k):
            result.append([k] + rest)
    return result

def parabolic_pressure(q, beta, n):
    return sum(q_multinomial(q, c)**(-beta) for c in compositions(n))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Free energy vs n for different q
ax = axes[0]
nmax = 8
for q in [2, 3, 5, 7]:
    ns = list(range(1, nmax+1))
    Fs = [math.log(parabolic_pressure(q, 1.0, n)) / n for n in ns]
    ax.plot(ns, Fs, 'o-', label=f'q = {q}', markersize=6)

ax.set_xlabel('n', fontsize=13)
ax.set_ylabel('F(n, q, β=1)', fontsize=13)
ax.set_title('Normalized Free Energy vs n', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Right: Free energy vs beta for fixed q=2, different n
ax = axes[1]
betas = np.linspace(0.01, 3.0, 30)
for n in [2, 4, 6, 8]:
    Fs = [math.log(parabolic_pressure(2, b, n)) / n for b in betas]
    ax.plot(betas, Fs, '-', label=f'n = {n}', linewidth=2)

ax.set_xlabel('β', fontsize=13)
ax.set_ylabel('F(n, q=2, β)', fontsize=13)
ax.set_title('Free Energy vs β (q=2)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('free_energy_convergence.png', dpi=150, bbox_inches='tight')
print("Saved free_energy_convergence.png")
