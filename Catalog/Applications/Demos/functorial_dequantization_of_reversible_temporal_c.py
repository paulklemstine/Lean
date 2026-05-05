#!/usr/bin/env python3
"""
Tropical Feedback Fixed Points: Interactive Demo

Demonstrates the core theorem: guarded feedback fixed points exist
if and only if every closed walk in the weighted dependency digraph
has nonpositive total weight (tropical spectral radius ≤ 0).

This corresponds to the formally verified theorems in TropicalFeedback.lean.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Optional, Tuple, List


def feedback_op(W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical feedback operator: Φ_W(x)(i) = max(0, max_j(W[i,j] + x[j]))"""
    n = W.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = max(0, max(W[i, j] + x[j] for j in range(n)))
    return result


def kleene_iterate(W: np.ndarray, steps: int) -> np.ndarray:
    """Kleene iteration: feedbackOp^[k](0)"""
    n = W.shape[0]
    x = np.zeros(n)
    for _ in range(steps):
        x = feedback_op(W, x)
    return x


def _enum_closed_walks(n: int, k: int) -> List[List[int]]:
    """Enumerate all closed walks of length k in complete digraph on n vertices."""
    walks = []
    for start in range(n):
        _build_walks(n, k, start, start, [start], walks)
    return walks


def _build_walks(n, k, start, current, path, results):
    if len(path) == k + 1:
        if current == start:
            results.append(list(path))
        return
    for next_v in range(n):
        path.append(next_v)
        _build_walks(n, k, start, next_v, path, results)
        path.pop()


def check_all_cycles_nonpos(W: np.ndarray) -> Tuple[bool, Optional[List[int]]]:
    """Check if all closed walk weights are ≤ 0."""
    n = W.shape[0]
    for k in range(1, n + 1):
        for walk in _enum_closed_walks(n, k):
            weight = sum(W[walk[t], walk[t+1]] for t in range(k))
            if weight > 1e-10:
                return False, walk
    return True, None


def find_fixed_point(W: np.ndarray, max_iter: int = 1000, tol: float = 1e-12):
    """Find fixed point by Kleene iteration."""
    n = W.shape[0]
    x = np.zeros(n)
    for k in range(max_iter):
        x_new = feedback_op(W, x)
        if np.max(np.abs(x_new - x)) < tol:
            return x_new, k + 1
        x = x_new
    return None, max_iter


# Demo 1: Basic feedback operator
print("=" * 60)
print("DEMO 1: Basic Feedback Operator")
print("=" * 60)

W = np.array([[-1.0, 2.0], [-3.0, -1.0]])
print(f"\nW =\n{W}")
print(f"Self-loops: W[0,0]={W[0,0]}, W[1,1]={W[1,1]}")
print(f"2-cycle: W[0,1]+W[1,0] = {W[0,1]+W[1,0]}")

nonpos, _ = check_all_cycles_nonpos(W)
print(f"All closed walk weights ≤ 0? {nonpos}")

fp, iters = find_fixed_point(W)
if fp is not None:
    print(f"Fixed point: x = {fp} (in {iters} iters)")
    print(f"Verification: Φ(x) = {feedback_op(W, fp)}")

print("\n--- Positive cycle (no fixed point) ---")
W2 = np.array([[-0.5, 2.0], [2.0, -0.5]])
print(f"W =\n{W2}")
print(f"2-cycle: {W2[0,1]+W2[1,0]}")
nonpos2, wit2 = check_all_cycles_nonpos(W2)
print(f"All cycles ≤ 0? {nonpos2}")
fp2, _ = find_fixed_point(W2, max_iter=50)
print(f"Fixed point: {'DIVERGES' if fp2 is None else fp2}")

# Demo 2: Kleene convergence
print("\n" + "=" * 60)
print("DEMO 2: Kleene Iteration Convergence")
print("=" * 60)

W3 = np.array([[-2.0, 1.0, 0.0], [-3.0, -2.0, 1.0], [-4.0, -3.0, -2.0]])
print(f"\nW (3×3) =\n{W3}")
n = W3.shape[0]

iterates = [np.zeros(n)]
for k in range(1, 2*n+2):
    iterates.append(kleene_iterate(W3, k))

print("\nKleene iterates:")
for k, x in enumerate(iterates):
    stab = " ← STABLE" if k >= 2 and np.allclose(x, iterates[k-1]) else ""
    print(f"  x^{k} = {x}{stab}")

fig, ax = plt.subplots(figsize=(8, 5))
for i in range(n):
    vals = [iterates[k][i] for k in range(len(iterates))]
    ax.plot(range(len(iterates)), vals, 'o-', label=f'x[{i}]', markersize=6)
ax.axvline(x=n, color='red', ls='--', alpha=0.5, label=f'k=n={n}')
ax.set_xlabel('Iteration k'); ax.set_ylabel('Value')
ax.set_title('Kleene Iteration Convergence (stabilizes at step n)')
ax.legend(); ax.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('kleene_convergence.png', dpi=150)
print("\nSaved kleene_convergence.png")

# Demo 3: Phase diagram
print("\n" + "=" * 60)
print("DEMO 3: Phase Diagram")
print("=" * 60)

gs = 80
w01r = np.linspace(-3, 3, gs)
w10r = np.linspace(-3, 3, gs)
emap = np.zeros((gs, gs))
umap = np.zeros((gs, gs))

for i, w01 in enumerate(w01r):
    for j, w10 in enumerate(w10r):
        cyc2 = w01 + w10
        if cyc2 <= 1e-10:
            emap[j, i] = 1
            if cyc2 < -1e-10:
                umap[j, i] = 1

fig, (a1, a2) = plt.subplots(1, 2, figsize=(14, 6))
a1.contourf(w01r, w10r, emap, levels=[-0.5,0.5,1.5], colors=['#ff6b6b','#51cf66'], alpha=0.7)
a1.contour(w01r, w10r, emap, levels=[0.5], colors='black')
a1.plot([-3,3],[3,-3],'k--',lw=2,label='w₀₁+w₁₀=0')
a1.set_xlabel('W[0,1]'); a1.set_ylabel('W[1,0]')
a1.set_title('Existence (Green=yes)')
a1.legend(); a1.set_aspect('equal')

a2.contourf(w01r, w10r, umap, levels=[-0.5,0.5,1.5], colors=['#ffd43b','#228be6'], alpha=0.7)
a2.contour(w01r, w10r, umap, levels=[0.5], colors='black')
a2.plot([-3,3],[3,-3],'k--',lw=2,label='w₀₁+w₁₀=0')
a2.set_xlabel('W[0,1]'); a2.set_ylabel('W[1,0]')
a2.set_title('Uniqueness (Blue=unique)')
a2.legend(); a2.set_aspect('equal')

plt.suptitle('2×2 Tropical Feedback Phase Diagram (W[i,i]=-1)', fontsize=14, y=1.02)
plt.tight_layout(); plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved phase_diagram.png")

# Demo 4: Dequantization
print("\n" + "=" * 60)
print("DEMO 4: Maslov Dequantization")
print("=" * 60)

A = np.array([[2.0, 0.5], [0.3, 1.5]])
B = np.array([[1.0, 0.8], [0.6, 2.0]])
AB = A @ B
logA, logB, logAB = np.log(A), np.log(B), np.log(AB)

trop = np.zeros_like(logAB)
for i in range(2):
    for j in range(2):
        trop[i,j] = max(logA[i,l]+logB[l,j] for l in range(2))

print(f"A={A.tolist()}, B={B.tolist()}")
print(f"log(A·B)=\n{np.round(logAB,4)}")
print(f"trop(logA,logB)=\n{np.round(trop,4)}")
print("trop ≤ log(A·B)?", np.all(trop <= logAB + 1e-10))

# Demo 5: Guardedness checker
print("\n" + "=" * 60)
print("DEMO 5: Guardedness Checker")
print("=" * 60)

cases = [
    ("Acyclic", np.array([[-1,.5,0],[0,-1,.5],[0,0,-1]])),
    ("Balanced", np.array([[-.5,1],[-1,-.5]])),
    ("Positive cycle", np.array([[0,2],[2,0]])),
    ("Critical", np.array([[0,1],[-1,0]])),
]

for name, W in cases:
    nonpos, wit = check_all_cycles_nonpos(W)
    fp, it = find_fixed_point(W, max_iter=100)
    status = "GUARDED ✓" if nonpos else "NOT GUARDED ✗"
    print(f"\n{name}: {status}")
    if fp is not None:
        print(f"  Fixed point: {np.round(fp,4)} ({it} iters)")
    else:
        print(f"  No fixed point")

print("\n" + "=" * 60)
print("All demos complete!")
print("=" * 60)
