#!/usr/bin/env python3
"""
Visualization: Distributivity Potential Landscape

Visualizes how the distributivity potential (termination measure) decreases
during rewriting. Shows the potential landscape for terms of varying complexity,
demonstrating that every rewrite step strictly decreases the measure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ─── Inline: Minimal expression types ───

class Expr:
    pass

class Var(Expr):
    def __init__(self, name, sort):
        self.name = name
        self.sort = sort

class BinOp(Expr):
    def __init__(self, op, left, right):
        self.op = op
        self.left = left
        self.right = right

def dp(t):
    """Distributivity potential."""
    if isinstance(t, Var):
        return 3
    op = t.op
    dl, dr = dp(t.left), dp(t.right)
    if op in ('scalAdd', 'vecAdd', 'matAdd'):
        return dl + dr + 1
    elif op == 'scalMul':
        return dl * dr
    elif op in ('smulVec', 'smulMat'):
        return dl * dr + 1
    elif op in ('mulVec', 'dot'):
        return dl * dr
    return 3

def size(t):
    if isinstance(t, Var):
        return 1
    return 1 + size(t.left) + size(t.right)

# ─── Generate sample rewrite traces ───

def make_trace(name, steps):
    """steps = list of (dp, label) pairs."""
    return name, steps

a = Var("a", "scal")
v = Var("v", "vec")
w = Var("w", "vec")
A = Var("A", "mat")
B = Var("B", "mat")

traces = []

# Trace 1: mulVec A (vecAdd v w) → vecAdd (mulVec A v) (mulVec A w)
t1 = BinOp('mulVec', A, BinOp('vecAdd', v, w))
t1_nf = BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', A, w))
traces.append(("A·(v⊕w)", [(dp(t1), "start"), (dp(t1_nf), "R1")]))

# Trace 2: mulVec (matAdd A B) (vecAdd v w) - two paths
t2 = BinOp('mulVec', BinOp('matAdd', A, B), BinOp('vecAdd', v, w))
# Path A: R1 first
t2_r1 = BinOp('vecAdd',
    BinOp('mulVec', BinOp('matAdd', A, B), v),
    BinOp('mulVec', BinOp('matAdd', A, B), w))
t2_r1_r2a = BinOp('vecAdd',
    BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', B, v)),
    BinOp('mulVec', BinOp('matAdd', A, B), w))
t2_r1_r2b = BinOp('vecAdd',
    BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', B, v)),
    BinOp('vecAdd', BinOp('mulVec', A, w), BinOp('mulVec', B, w)))
traces.append(("(A⊞B)·(v⊕w) path1", [
    (dp(t2), "start"),
    (dp(t2_r1), "R1"),
    (dp(t2_r1_r2a), "R2"),
    (dp(t2_r1_r2b), "R2")
]))
# Path B: R2 first
t2_r2 = BinOp('vecAdd',
    BinOp('mulVec', A, BinOp('vecAdd', v, w)),
    BinOp('mulVec', B, BinOp('vecAdd', v, w)))
t2_r2_r1a = BinOp('vecAdd',
    BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', A, w)),
    BinOp('mulVec', B, BinOp('vecAdd', v, w)))
t2_r2_r1b = BinOp('vecAdd',
    BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', A, w)),
    BinOp('vecAdd', BinOp('mulVec', B, v), BinOp('mulVec', B, w)))
traces.append(("(A⊞B)·(v⊕w) path2", [
    (dp(t2), "start"),
    (dp(t2_r2), "R2"),
    (dp(t2_r2_r1a), "R1"),
    (dp(t2_r2_r1b), "R1")
]))

# Trace 3: Scalar extraction
t3 = BinOp('mulVec', BinOp('smulMat', a, A), BinOp('vecAdd', v, w))
t3_r1 = BinOp('vecAdd',
    BinOp('mulVec', BinOp('smulMat', a, A), v),
    BinOp('mulVec', BinOp('smulMat', a, A), w))
t3_r1_r3 = BinOp('vecAdd',
    BinOp('smulVec', a, BinOp('mulVec', A, v)),
    BinOp('mulVec', BinOp('smulMat', a, A), w))
traces.append(("(a⊙A)·(v⊕w)", [
    (dp(t3), "start"),
    (dp(t3_r1), "R1"),
    (dp(t3_r1_r3), "R3")
]))

# ─── Plot ───

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Rewrite traces
ax = axes[0]
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
for i, (name, steps) in enumerate(traces):
    x = list(range(len(steps)))
    y = [s[0] for s in steps]
    ax.plot(x, y, 'o-', color=colors[i % len(colors)], label=name,
            linewidth=2, markersize=8)
    for j, (val, label) in enumerate(steps):
        ax.annotate(label, (j, val), textcoords="offset points",
                   xytext=(0, 10), ha='center', fontsize=7)

ax.set_xlabel("Rewrite Step", fontsize=12)
ax.set_ylabel("Distributivity Potential", fontsize=12)
ax.set_title("Strictly Decreasing Potential During Rewriting", fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Right: dp vs size scatter
ax2 = axes[1]
sizes = []
dps = []
# Generate many terms
for _ in range(200):
    depth = np.random.randint(1, 6)
    t = Var("x", "vec")
    for _ in range(depth):
        op = np.random.choice(['vecAdd', 'mulVec', 'smulVec', 'dot'])
        other = Var(np.random.choice(["v", "w", "u"]),
                   "vec" if op != 'mulVec' else "mat")
        if op == 'smulVec':
            other = Var("a", "scal")
            t = BinOp(op, other, t)
        else:
            t = BinOp(op, other if np.random.random() < 0.5 else t,
                      t if np.random.random() < 0.5 else other)
    sizes.append(size(t))
    dps.append(dp(t))

ax2.scatter(sizes, dps, alpha=0.5, c='#2196F3', s=20)
# Plot 3^n bound
x_bound = np.linspace(1, max(sizes), 100)
ax2.plot(x_bound, 3**x_bound, 'r--', alpha=0.7, label='3^n upper bound')
ax2.set_xlabel("Expression Size n", fontsize=12)
ax2.set_ylabel("Distributivity Potential dp(t)", fontsize=12)
ax2.set_title("dp(t) ≤ 3^size(t)", fontsize=13)
ax2.set_yscale('log')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_potential.png', dpi=150, bbox_inches='tight')
print("Saved viz_potential.png")
