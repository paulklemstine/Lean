"""
Visualization: Word Reachability Growth Curves

Shows how the fraction of GL₂(𝔽_q) reachable by words of length ≤ L grows
with L for different generator pairs. Expanding pairs show rapid growth
(exponential until saturation), while non-expanding pairs plateau early.
This illustrates the core idea: local word statistics predict global expansion.
"""

import numpy as np
import matplotlib.pyplot as plt


def mod_inv(a, p):
    return pow(a, p - 2, p)

def mat_det_mod(M, p):
    return int(M[0,0]*M[1,1] - M[0,1]*M[1,0]) % p

def mat_mul_mod(A, B, p):
    return np.array(A @ B % p, dtype=int) % p

def mat_inv_mod(M, p):
    a, b, c, d = int(M[0,0]), int(M[0,1]), int(M[1,0]), int(M[1,1])
    det = (a*d - b*c) % p
    if det == 0: return None
    di = mod_inv(det, p)
    return np.array([[d*di%p, (-b*di)%p], [(-c*di)%p, a*di%p]], dtype=int) % p

def mat_to_tuple(M, p):
    return tuple(int(x) % p for x in M.flatten())

def reachability_curve(g, h, p, max_L=15):
    gi, hi = mat_inv_mod(g, p), mat_inv_mod(h, p)
    if gi is None or hi is None: return []
    gens = [g, gi, h, hi]
    identity = np.eye(2, dtype=int)
    target = (p*p - 1)*(p*p - p)
    reachable = {mat_to_tuple(identity, p)}
    frontier = {mat_to_tuple(identity, p): identity}
    fractions = [1.0 / target]
    for _ in range(max_L):
        new_frontier = {}
        for _, mat in frontier.items():
            for gen in gens:
                prod = mat_mul_mod(mat, gen, p)
                key = mat_to_tuple(prod, p)
                if key not in reachable:
                    reachable.add(key)
                    new_frontier[key] = prod
        frontier = new_frontier
        fractions.append(len(reachable) / target)
        if not frontier:
            while len(fractions) <= max_L:
                fractions.append(1.0)
            break
    return fractions


q = 3
n_group = (q*q - 1)*(q*q - q)

# Different generator pairs
pairs = [
    (np.array([[0,1],[1,1]]), np.array([[1,1],[0,2]]), "Certified expander", '#e74c3c', '-'),
    (np.array([[0,1],[2,0]]), np.array([[1,1],[1,2]]), "Strong generator", '#3498db', '-'),
    (np.array([[1,1],[0,1]]), np.array([[1,0],[1,1]]), "Upper+Lower triangular", '#2ecc71', '--'),
    (np.array([[2,0],[0,1]]), np.array([[1,0],[0,2]]), "Diagonal pair", '#9b59b6', ':'),
]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

max_L = 14

for g, h, label, color, ls in pairs:
    curve = reachability_curve(g, h, q, max_L)
    Ls = list(range(len(curve)))
    ax1.plot(Ls, curve, color=color, linestyle=ls, linewidth=2, label=label, marker='o', markersize=4)
    
    # Log scale for growth rate
    log_curve = [max(c, 1e-6) for c in curve]
    ax2.semilogy(Ls, [1 - c for c in log_curve], color=color, linestyle=ls,
                 linewidth=2, label=label, marker='o', markersize=4)

ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Full group')
ax1.set_xlabel('Word length L', fontsize=12)
ax1.set_ylabel('Fraction of GL₂(𝔽₃) reached', fontsize=12)
ax1.set_title('Reachability Growth', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.05, 1.1)

ax2.set_xlabel('Word length L', fontsize=12)
ax2.set_ylabel('Fraction NOT reached (log scale)', fontsize=12)
ax2.set_title('Convergence to Full Group', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.suptitle(f'Word Reachability in GL₂(𝔽₃)  (|G| = {n_group})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('reachability_growth.png', dpi=150, bbox_inches='tight')
print("Saved reachability_growth.png")
