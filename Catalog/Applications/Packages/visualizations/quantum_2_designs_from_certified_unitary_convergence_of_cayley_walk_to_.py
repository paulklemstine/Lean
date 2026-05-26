"""
Visualization: Convergence of Cayley Walk to Approximate 2-Design

This script visualizes the exponential decay of deviation energy
(frame-potential surrogate) as the Cayley walk progresses on
SL₂(GF(q)) for q = 3, 5, 7. The plot demonstrates the core theorem:
certified spectral gaps yield exponential convergence to uniformity.

CRITICAL: This script is fully self-contained. All needed functions
are inlined directly.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# ─── Inline infrastructure ──────────────────────────────────────────

def mat_mul_mod(A, B, q):
    return (A @ B) % q

def mat_inv_mod(A, q):
    a, b, c, d = int(A[0,0]), int(A[0,1]), int(A[1,0]), int(A[1,1])
    det = (a*d - b*c) % q
    det_inv = pow(det, q-2, q)
    return np.array([[d*det_inv%q, (-b*det_inv)%q],
                     [(-c*det_inv)%q, a*det_inv%q]], dtype=int) % q

def charpoly_is_irreducible(A, q):
    tr = int((A[0,0]+A[1,1])%q)
    det = int((A[0,0]*A[1,1]-A[0,1]*A[1,0])%q)
    disc = (tr*tr - 4*det) % q
    if disc == 0: return False
    if q == 2: return True
    return pow(disc, (q-1)//2, q) != 1

def find_certified_pair(q):
    irred = []
    all_sl2 = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                for d in range(q):
                    mat = np.array([[a,b],[c,d]], dtype=int)
                    if (a*d-b*c)%q == 1:
                        all_sl2.append(mat)
                        if charpoly_is_irreducible(mat, q):
                            irred.append(mat)
    def check_gen(s, t):
        target = q*(q*q-1)
        gens = [s, mat_inv_mod(s,q), t, mat_inv_mod(t,q)]
        seen = set()
        frontier = [np.eye(2, dtype=int)]
        seen.add(tuple(frontier[0].flatten()))
        while frontier:
            nf = []
            for g in frontier:
                for gen in gens:
                    p = mat_mul_mod(g, gen, q)
                    k = tuple((p%q).flatten())
                    if k not in seen:
                        seen.add(k)
                        nf.append(p)
                        if len(seen) == target: return True
            frontier = nf
        return len(seen) == target
    lim = min(len(irred), 30)
    for s in irred[:lim]:
        for t in irred[:lim]:
            if not np.array_equal(s,t) and check_gen(s,t):
                return s, t
    ol = min(len(all_sl2), 40)
    for s in irred[:lim]:
        for t in all_sl2[:ol]:
            if not np.array_equal(s,t) and check_gen(s,t):
                return s, t
    return None, None

def cayley_walk(s, t, q, k):
    gens = [s, mat_inv_mod(s,q), t, mat_inv_mod(t,q)]
    identity = tuple(np.eye(2, dtype=int).flatten())
    dist = {identity: 1.0}
    for _ in range(k):
        nd = {}
        for elem, prob in dist.items():
            em = np.array(elem, dtype=int).reshape(2,2)
            for gen in gens:
                p = mat_mul_mod(gen, em, q)
                kk = tuple((p%q).flatten())
                nd[kk] = nd.get(kk, 0.0) + prob/len(gens)
        dist = nd
    return dist

def deviation_energy(dist, group_size):
    u = 1.0/group_size
    return sum((p-u)**2 for p in dist.values()) + (group_size - len(dist)) * u**2


# ─── Main visualization ────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

colors = {3: '#e74c3c', 5: '#3498db', 7: '#2ecc71'}
markers = {3: 'o', 5: 's', 7: '^'}

for q in [3, 5, 7]:
    group_size = q * (q*q - 1)
    s, t = find_certified_pair(q)
    if s is None:
        continue

    max_k = min(20, 4 + int(np.log2(group_size + 1)) * 2)
    energies = []
    for k in range(max_k + 1):
        dist = cayley_walk(s, t, q, k)
        e = deviation_energy(dist, group_size)
        energies.append(max(e, 1e-20))

    steps = list(range(len(energies)))

    # Left panel: log-scale energy decay
    ax1.semilogy(steps, energies, '-' + markers[q],
                 color=colors[q], markersize=6,
                 label=f'q={q}, |G|={group_size}', linewidth=2)

    # Estimate spectral bound and plot theoretical line
    ratios = []
    for k in range(2, len(energies)):
        if energies[k-1] > 1e-14:
            ratios.append(np.sqrt(max(energies[k]/energies[k-1], 0)))
    if ratios:
        spec = np.median(ratios)
        theo_line = [energies[0] * spec**(2*k) for k in steps]
        ax1.semilogy(steps, theo_line, '--', color=colors[q], alpha=0.5,
                     linewidth=1, label=f'  λ={spec:.3f} fit')

    # Right panel: spectral ratio per step
    step_ratios = []
    for k in range(1, len(energies)):
        if energies[k-1] > 1e-14:
            step_ratios.append(np.sqrt(max(energies[k]/energies[k-1], 0)))
        else:
            step_ratios.append(0)

    ax2.plot(range(1, len(step_ratios)+1), step_ratios, '-' + markers[q],
             color=colors[q], markersize=5,
             label=f'q={q}', linewidth=2)

# Format left panel
ax1.set_xlabel('Walk length k', fontsize=13)
ax1.set_ylabel('Deviation energy (log scale)', fontsize=13)
ax1.set_title('Exponential Convergence of Cayley Walk\nto Approximate 2-Design', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=1e-18)

# Format right panel
ax2.set_xlabel('Walk step k', fontsize=13)
ax2.set_ylabel('√(E_k/E_{k-1}) ≈ spectral bound λ', fontsize=13)
ax2.set_title('Per-Step Contraction Rate\n(Spectral Bound Estimate)', fontsize=14)
ax2.axhline(y=1, color='red', linestyle=':', alpha=0.5, label='λ = 1 (no gap)')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.2)

plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
print("Saved convergence_plot.png")
