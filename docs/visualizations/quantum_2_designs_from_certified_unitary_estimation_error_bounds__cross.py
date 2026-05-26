"""
Visualization: Estimation Error Bounds (Cross-Domain Theorem)

This script visualizes the relationship between frame-potential quality
(ε) and estimation error for quadratic observables, demonstrating the
cross-domain theorem: design quality → statistical efficiency.

The plot shows actual estimation errors vs. the theoretical Cauchy-Schwarz
bound for multiple observables and walk lengths.

CRITICAL: Fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


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


# ─── Main visualization ────────────────────────────────────────────

q = 5
group_size = q * (q*q - 1)
s, t = find_certified_pair(q)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

if s is not None:
    # Build group element list
    all_keys = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                for d in range(q):
                    if (a*d-b*c)%q == 1:
                        all_keys.append((a,b,c,d))

    # Create observables
    np.random.seed(42)
    observables = {
        'Trace': {k: ((k[0]+k[3])%q)/q for k in all_keys},
        'Off-diagonal': {k: ((k[0]*k[1])%q)/q for k in all_keys},
        'Random': {k: np.random.randn() for k in all_keys},
    }

    colors_obs = {'Trace': '#e74c3c', 'Off-diagonal': '#3498db', 'Random': '#2ecc71'}
    markers_obs = {'Trace': 'o', 'Off-diagonal': 's', 'Random': '^'}

    max_k = 15
    steps = list(range(max_k + 1))

    for obs_name, obs in observables.items():
        B_sq = sum(v**2 for v in obs.values())
        B = np.sqrt(B_sq)
        true_avg = sum(obs.values()) / len(obs)

        actual_errors = []
        theo_bounds = []
        frame_pots = []

        for k in steps:
            dist = cayley_walk(s, t, q, k)

            est = 0.0
            for key in all_keys:
                tkey = tuple(np.array(key, dtype=int))
                est += dist.get(tkey, 0.0) * obs[key]

            err = abs(est - true_avg)
            actual_errors.append(max(err, 1e-20))

            fp = max(sum(p**2 for p in dist.values()) - 1.0/group_size, 1e-20)
            frame_pots.append(fp)
            theo_bounds.append(B * np.sqrt(group_size) * np.sqrt(fp))

        # Left: actual error vs bound
        ax1.semilogy(steps, actual_errors, '-' + markers_obs[obs_name],
                     color=colors_obs[obs_name], markersize=5, linewidth=2,
                     label=f'{obs_name} (actual)')
        ax1.semilogy(steps, theo_bounds, '--',
                     color=colors_obs[obs_name], alpha=0.5, linewidth=1,
                     label=f'{obs_name} (bound)')

    # Right: frame potential decay
    fp_values = []
    for k in steps:
        dist = cayley_walk(s, t, q, k)
        fp = max(sum(p**2 for p in dist.values()) - 1.0/group_size, 1e-20)
        fp_values.append(fp)

    ax2.semilogy(steps, fp_values, '-o', color='#9b59b6', markersize=6,
                 linewidth=2, label='Frame potential bound ε(k)')
    ax2.axhline(y=0.01, color='red', linestyle=':', alpha=0.5, label='ε = 0.01 threshold')
    ax2.axhline(y=0.001, color='orange', linestyle=':', alpha=0.5, label='ε = 0.001 threshold')

    # Mark where thresholds are crossed
    for thresh, col in [(0.01, 'red'), (0.001, 'orange')]:
        for k_idx in range(len(fp_values)):
            if fp_values[k_idx] <= thresh:
                ax2.axvline(x=k_idx, color=col, alpha=0.3, linestyle='-.')
                break

ax1.set_xlabel('Walk length k', fontsize=13)
ax1.set_ylabel('Estimation error (log scale)', fontsize=13)
ax1.set_title(f'Estimation Error vs. Theoretical Bound\nSL₂(GF({q})), |G|={group_size}',
              fontsize=14)
ax1.legend(fontsize=9, loc='upper right')
ax1.grid(True, alpha=0.3)

ax2.set_xlabel('Walk length k', fontsize=13)
ax2.set_ylabel('Frame potential bound ε (log scale)', fontsize=13)
ax2.set_title(f'Frame Potential Decay\n(ε → 0 ⟹ approximate 2-design)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('estimation_bounds.png', dpi=150, bbox_inches='tight')
print("Saved estimation_bounds.png")
