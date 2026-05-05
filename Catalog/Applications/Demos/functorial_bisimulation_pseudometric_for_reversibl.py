#!/usr/bin/env python3
"""
Bisimulation Pseudometric for Deterministic State Machines
==========================================================

Demonstrates the iterative computation of the least bisimulation pseudometric
for deterministic finite-state machines, as formalized in the Lean theorem
`exists_least_bisimulation_metric_finite`.

The key idea: two states are "close" if they produce similar observations
*and* their successors are close — recursively. The least fixed point of
this recursive equation gives the canonical bisimulation distance.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def step_lift(obs_dist, out, nxt, d):
    """
    One-step behavioral lifting operator.

    stepLift(obsDist, out, next, d)(s, t) = max(obsDist(out(s), out(t)), d(next(s), next(t)))

    This is the operator whose least prefixed point is the bisimulation pseudometric.
    """
    n = d.shape[0]
    result = np.zeros((n, n))
    for s in range(n):
        for t in range(n):
            result[s, t] = max(obs_dist[out[s], out[t]], d[nxt[s], nxt[t]])
    return result


def compute_bisim_metric(obs_dist, out, nxt, max_iters=100, tol=1e-12):
    """
    Compute the least bisimulation pseudometric by iterating stepLift from the zero metric.

    This implements the Kleene iteration:
        d_0 = 0
        d_{n+1} = stepLift(obsDist, out, next, d_n)

    The sequence is monotonically increasing (iterStep_monotone) and converges
    to the least prefixed point (exists_least_bisimulation_metric_finite).
    """
    n = len(out)
    d = np.zeros((n, n))
    history = [d.copy()]

    for i in range(max_iters):
        d_new = step_lift(obs_dist, out, nxt, d)
        history.append(d_new.copy())
        if np.max(np.abs(d_new - d)) < tol:
            print(f"  Converged after {i+1} iterations")
            break
        d = d_new
    else:
        print(f"  Did not converge after {max_iters} iterations")

    return d_new, history


def verify_pseudometric_axioms(d, name="d"):
    """Verify that a distance matrix satisfies the Lawvere pseudometric axioms."""
    n = d.shape[0]

    # Reflexivity: d(x, x) = 0
    refl_ok = all(abs(d[i, i]) < 1e-10 for i in range(n))

    # Triangle inequality: d(x, z) <= d(x, y) + d(y, z)
    tri_ok = True
    for x, y, z in product(range(n), repeat=3):
        if d[x, z] > d[x, y] + d[y, z] + 1e-10:
            tri_ok = False
            break

    # Symmetry
    sym_ok = np.allclose(d, d.T)

    print(f"  {name}: reflexive={refl_ok}, triangle={tri_ok}, symmetric={sym_ok}")
    return refl_ok, tri_ok, sym_ok


def verify_prefixed_point(obs_dist, out, nxt, d):
    """Verify that d is a prefixed point: stepLift(d) <= d."""
    lifted = step_lift(obs_dist, out, nxt, d)
    ok = np.all(lifted <= d + 1e-10)
    print(f"  Prefixed point: {ok}")
    return ok


# ==============================================================================
# Example 1: Two-state clock vs. stuck clock
# ==============================================================================
print("=" * 70)
print("Example 1: Ticking clock vs. stuck clock")
print("=" * 70)
print()
print("State 0: ticks (outputs 0, 1, 0, 1, ...)")
print("State 1: stuck (outputs 0, 0, 0, 0, ...)")
print()

# 3 states: 0='tick-even', 1='tick-odd', 2='stuck'
# Outputs: 0 -> 'low', 1 -> 'high', 2 -> 'low'
# Observation alphabet: {0='low', 1='high'}
out1 = np.array([0, 1, 0])    # state -> observation
nxt1 = np.array([1, 0, 2])    # state -> next state

# Observation distance: |obs_a - obs_b|
obs_dist1 = np.array([[0.0, 1.0],
                       [1.0, 0.0]])

d1, hist1 = compute_bisim_metric(obs_dist1, out1, nxt1)
print()
print("Bisimulation distance matrix:")
print(np.round(d1, 4))
print()
verify_pseudometric_axioms(d1, "d1")
verify_prefixed_point(obs_dist1, out1, nxt1, d1)
print()
print("Interpretation:")
print(f"  d(tick-even, stuck) = {d1[0, 2]:.4f}")
print(f"  d(tick-odd, stuck)  = {d1[1, 2]:.4f}")
print(f"  d(tick-even, tick-odd) = {d1[0, 1]:.4f}")
print("  The ticking states differ from stuck by 1.0 (max observable difference)")
print("  The two ticking phases also differ by 1.0 (they output different values now)")

# ==============================================================================
# Example 2: Three-state ring with graded observations
# ==============================================================================
print()
print("=" * 70)
print("Example 2: Ring automaton with graded observations")
print("=" * 70)
print()

# 4 states in a ring: 0 -> 1 -> 2 -> 3 -> 0
# Observations: state i outputs observation i
out2 = np.array([0, 1, 2, 3])
nxt2 = np.array([1, 2, 3, 0])

# Graded observation distance: |i - j| / 3
n_obs = 4
obs_dist2 = np.zeros((n_obs, n_obs))
for i in range(n_obs):
    for j in range(n_obs):
        obs_dist2[i, j] = abs(i - j) / 3.0

d2, hist2 = compute_bisim_metric(obs_dist2, out2, nxt2)
print()
print("Observation distance matrix:")
print(np.round(obs_dist2, 4))
print()
print("Bisimulation distance matrix:")
print(np.round(d2, 4))
print()
verify_pseudometric_axioms(d2, "d2")
verify_prefixed_point(obs_dist2, out2, nxt2, d2)

# ==============================================================================
# Example 3: Convergence visualization
# ==============================================================================
print()
print("=" * 70)
print("Example 3: Convergence of iterative computation")
print("=" * 70)
print()

# Use example 2's history to show monotone convergence
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Plot 1: Convergence of specific distances
ax1 = axes[0]
pairs = [(0, 1), (0, 2), (0, 3), (1, 3)]
for s, t in pairs:
    values = [h[s, t] for h in hist2]
    ax1.plot(values, marker='o', markersize=3, label=f'd({s},{t})')
ax1.set_xlabel('Iteration')
ax1.set_ylabel('Distance')
ax1.set_title('Monotone Convergence of Distances')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Heatmap of final metric
ax2 = axes[1]
im = ax2.imshow(d2, cmap='YlOrRd', vmin=0)
ax2.set_title('Final Bisimulation Metric')
ax2.set_xlabel('State')
ax2.set_ylabel('State')
plt.colorbar(im, ax=ax2)

# Plot 3: Total distance over iterations
ax3 = axes[2]
total_dist = [np.sum(h) for h in hist2]
ax3.plot(total_dist, marker='s', markersize=4, color='darkblue')
ax3.set_xlabel('Iteration')
ax3.set_ylabel('Sum of all distances')
ax3.set_title('Total Distance Growth')
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/convergence_plot.png', dpi=150, bbox_inches='tight')
print("Saved convergence_plot.png")

# ==============================================================================
# Example 4: Nonexpansiveness of sequential composition
# ==============================================================================
print()
print("=" * 70)
print("Example 4: Sequential composition nonexpansiveness")
print("=" * 70)
print()

# Two machines: M1 and M2, connected sequentially
# M1: 3-state machine
out_m1 = np.array([0, 1, 0])
nxt_m1 = np.array([1, 2, 0])
obs_m1 = np.array([[0.0, 0.5], [0.5, 0.0]])

# M2: takes M1's output as input, deterministic transducer
# Maps observation 0 -> 0, observation 1 -> 1 (identity, so nonexpansive with factor 1)
f_map = np.array([0, 1])  # identity on observations
g_map = np.array([0, 1])  # identity on observations

d_m1, _ = compute_bisim_metric(obs_m1, out_m1, nxt_m1)
print("M1 bisimulation distances:")
print(np.round(d_m1, 4))
print()

# The composed system: out_composed(s) = g(f(out_m1(s)))
out_composed = np.array([g_map[f_map[out_m1[s]]] for s in range(3)])
d_composed, _ = compute_bisim_metric(obs_m1, out_composed, nxt_m1)
print("Composed system distances:")
print(np.round(d_composed, 4))
print()
print("Nonexpansiveness check (composed ≤ original):")
print(f"  All entries satisfy d_composed ≤ d_m1: {np.all(d_composed <= d_m1 + 1e-10)}")

# ==============================================================================
# Example 5: Parallel composition with sup-product metric
# ==============================================================================
print()
print("=" * 70)
print("Example 5: Parallel composition with sup-product metric")
print("=" * 70)
print()

# Machine A: 2-state alternator
out_a = np.array([0, 1])
nxt_a = np.array([1, 0])
obs_a = np.array([[0.0, 1.0], [1.0, 0.0]])

# Machine B: 2-state constant
out_b = np.array([0, 0])
nxt_b = np.array([1, 0])
obs_b = np.array([[0.0, 1.0], [1.0, 0.0]])

d_a, _ = compute_bisim_metric(obs_a, out_a, nxt_a)
d_b, _ = compute_bisim_metric(obs_b, out_b, nxt_b)

print("Machine A distances:")
print(np.round(d_a, 4))
print("Machine B distances:")
print(np.round(d_b, 4))

# Product machine: state space is A × B
n_a, n_b = len(out_a), len(out_b)
n_prod = n_a * n_b

# Product observation distance: sup of component distances
n_obs_prod = 4  # pairs (obs_a, obs_b)
obs_prod = np.zeros((n_obs_prod, n_obs_prod))
for i in range(n_obs_prod):
    for j in range(n_obs_prod):
        ia, ib = i // 2, i % 2
        ja, jb = j // 2, j % 2
        obs_prod[i, j] = max(obs_a[ia, ja], obs_b[ib, jb])

out_prod = np.array([out_a[s // n_b] * 2 + out_b[s % n_b] for s in range(n_prod)])
nxt_prod = np.array([nxt_a[s // n_b] * n_b + nxt_b[s % n_b] for s in range(n_prod)])

d_prod, _ = compute_bisim_metric(obs_prod, out_prod, nxt_prod)

print("Product machine distances:")
print(np.round(d_prod, 4))
print()

# Verify nonexpansiveness: d_prod((s1,s2),(t1,t2)) ≤ max(d_a(s1,t1), d_b(s2,t2))
print("Sup-product nonexpansiveness check:")
all_ok = True
for s in range(n_prod):
    for t in range(n_prod):
        sa, sb = s // n_b, s % n_b
        ta, tb = t // n_b, t % n_b
        bound = max(d_a[sa, ta], d_b[sb, tb])
        if d_prod[s, t] > bound + 1e-10:
            all_ok = False
            print(f"  FAIL at ({s},{t}): {d_prod[s,t]:.4f} > {bound:.4f}")
print(f"  All entries satisfy sup-product bound: {all_ok}")


# ==============================================================================
# Example 6: Reversible system (bijective next)
# ==============================================================================
print()
print("=" * 70)
print("Example 6: Reversible (bijective) transition system")
print("=" * 70)
print()

# A reversible 4-state system (permutation)
out_rev = np.array([0, 1, 2, 1])
nxt_rev = np.array([2, 3, 0, 1])  # bijection: (0->2, 1->3, 2->0, 3->1)

obs_rev = np.zeros((3, 3))
for i in range(3):
    for j in range(3):
        obs_rev[i, j] = abs(i - j) / 2.0

d_rev, hist_rev = compute_bisim_metric(obs_rev, out_rev, nxt_rev)
print("Transition (bijection):", nxt_rev)
print("Observations:", out_rev)
print()
print("Bisimulation distance matrix:")
print(np.round(d_rev, 4))
print()

# Check symmetry (expected for reversible systems with symmetric obs distance)
verify_pseudometric_axioms(d_rev, "d_rev")
print()
print("Reversibility induces a symmetric bisimulation metric!")
print("This corresponds to the theorem stepLift_symmetric in the Lean formalization.")

# ==============================================================================
# Summary visualization
# ==============================================================================
fig2, axes2 = plt.subplots(1, 3, figsize=(15, 4))

titles = ['Ticking vs Stuck Clock', 'Ring Automaton', 'Reversible System']
matrices = [d1, d2, d_rev]

for ax, title, mat in zip(axes2, titles, matrices):
    im = ax.imshow(mat, cmap='viridis', vmin=0)
    ax.set_title(title)
    ax.set_xlabel('State')
    ax.set_ylabel('State')
    for i in range(mat.shape[0]):
        for j in range(mat.shape[1]):
            ax.text(j, i, f'{mat[i,j]:.2f}', ha='center', va='center',
                   color='white' if mat[i,j] > mat.max()/2 else 'black', fontsize=8)
    plt.colorbar(im, ax=ax)

plt.suptitle('Bisimulation Pseudometrics for Different Systems', fontsize=14)
plt.tight_layout()
plt.savefig('demos/bisimulation_metrics_gallery.png', dpi=150, bbox_inches='tight')
print()
print("Saved bisimulation_metrics_gallery.png")

print()
print("=" * 70)
print("All examples completed successfully!")
print("=" * 70)
