#!/usr/bin/env python3
"""
Non-Well-Founded Proofs: Demonstration Script

Demonstrates the key concepts from the convergence domain theory:
- Consistency metric computation
- Well-founded kernel extraction
- Proof compression ratios
- Convergence domain iteration
- Tropical proof height algebra
"""

from dataclasses import dataclass
from typing import Optional, Union
from enum import Enum


class TreeType(Enum):
    AXIOM = "axiom"
    MP = "modus_ponens"
    SELF_REF = "self_ref"
    BOT = "bot"


@dataclass
class NWFTree:
    """Non-well-founded proof tree."""
    type: TreeType
    prop: Optional[int] = None  # proposition id
    premise: Optional[int] = None  # for MP
    left: Optional['NWFTree'] = None
    right: Optional['NWFTree'] = None
    inner: Optional['NWFTree'] = None

    def __repr__(self):
        if self.type == TreeType.AXIOM:
            return f"ax({self.prop})"
        elif self.type == TreeType.MP:
            return f"mp({self.left}, {self.right}, {self.premise}→{self.prop})"
        elif self.type == TreeType.SELF_REF:
            return f"selfRef({self.prop}, {self.inner})"
        elif self.type == TreeType.BOT:
            return "⊥"
        return "?"


def ax(p: int) -> NWFTree:
    return NWFTree(TreeType.AXIOM, prop=p)

def mp(f: NWFTree, a: NWFTree, p: int, q: int) -> NWFTree:
    return NWFTree(TreeType.MP, prop=q, premise=p, left=f, right=a)

def self_ref(p: int, inner: NWFTree) -> NWFTree:
    return NWFTree(TreeType.SELF_REF, prop=p, inner=inner)

def bot() -> NWFTree:
    return NWFTree(TreeType.BOT)


def consistency_metric(t: NWFTree) -> float:
    """Compute the consistency metric of a proof tree."""
    if t.type == TreeType.AXIOM:
        return 0.0
    elif t.type == TreeType.MP:
        return max(consistency_metric(t.left), consistency_metric(t.right))
    elif t.type == TreeType.SELF_REF:
        return (1 + consistency_metric(t.inner)) / 2
    elif t.type == TreeType.BOT:
        return 1.0
    return 0.0


def depth(t: NWFTree) -> int:
    """Compute the structural depth of a proof tree."""
    if t.type == TreeType.AXIOM:
        return 0
    elif t.type == TreeType.MP:
        return 1 + max(depth(t.left), depth(t.right))
    elif t.type == TreeType.SELF_REF:
        return 1 + depth(t.inner)
    elif t.type == TreeType.BOT:
        return 0
    return 0


def sr_depth(t: NWFTree) -> int:
    """Compute the self-reference depth."""
    if t.type == TreeType.AXIOM:
        return 0
    elif t.type == TreeType.MP:
        return max(sr_depth(t.left), sr_depth(t.right))
    elif t.type == TreeType.SELF_REF:
        return 1 + sr_depth(t.inner)
    elif t.type == TreeType.BOT:
        return 0
    return 0


def is_valid(t: NWFTree) -> bool:
    """Check validity of a proof tree."""
    if t.type == TreeType.AXIOM:
        return True
    elif t.type == TreeType.MP:
        return (t.left is not None and t.right is not None and
                is_valid(t.left) and is_valid(t.right))
    elif t.type == TreeType.SELF_REF:
        return (t.inner is not None and
                t.inner.prop == t.prop and
                is_valid(t.inner))
    elif t.type == TreeType.BOT:
        return False
    return False


def wf_kernel(t: NWFTree) -> NWFTree:
    """Extract the well-founded kernel."""
    if t.type == TreeType.AXIOM:
        return t
    elif t.type == TreeType.MP:
        return mp(wf_kernel(t.left), wf_kernel(t.right), t.premise, t.prop)
    elif t.type == TreeType.SELF_REF:
        return ax(t.prop)
    elif t.type == TreeType.BOT:
        return t
    return t


def nested_sr(p: int, n: int) -> NWFTree:
    """Construct a nested self-referential proof of depth n."""
    if n == 0:
        return ax(p)
    return self_ref(p, nested_sr(p, n - 1))


def convergence_iteration(f, x0: float, n_steps: int = 20) -> list:
    """Iterate a contractive function and track convergence."""
    trajectory = [x0]
    x = x0
    for _ in range(n_steps):
        x = f(x)
        trajectory.append(x)
    return trajectory


# ============================================================
# DEMONSTRATIONS
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("NON-WELL-FOUNDED PROOFS: DEMONSTRATION")
    print("=" * 60)

    # Demo 1: Identity proof
    print("\n--- Demo 1: Identity Proof (P → P) ---")
    identity = self_ref(0, ax(0))
    print(f"Tree: {identity}")
    print(f"Valid: {is_valid(identity)}")
    print(f"Consistency Metric: {consistency_metric(identity)}")
    print(f"Depth: {depth(identity)}")
    print(f"SR Depth: {sr_depth(identity)}")

    # Demo 2: Liar sentence
    print("\n--- Demo 2: Liar Sentence ---")
    liar = self_ref(0, bot())
    print(f"Tree: {liar}")
    print(f"Valid: {is_valid(liar)}")
    print(f"Consistency Metric: {consistency_metric(liar)}")

    # Demo 3: Nested self-reference and compression
    print("\n--- Demo 3: Proof Compression ---")
    print(f"{'Depth':>6} {'CM':>8} {'Kernel Depth':>13} {'Compression':>12}")
    print("-" * 45)
    for n in range(8):
        t = nested_sr(0, n)
        k = wf_kernel(t)
        cm = consistency_metric(t)
        d = depth(t)
        kd = depth(k)
        ratio = f"{d}:{kd}" if kd > 0 else f"{d}:0 (∞×)"
        print(f"{d:>6} {cm:>8.4f} {kd:>13} {ratio:>12}")

    # Demo 4: Consistency metric convergence
    print("\n--- Demo 4: CM Convergence to Boundary ---")
    print("Nested self-reference approaches CM = 1 but never reaches it:")
    for n in range(10):
        t = nested_sr(0, n)
        cm = consistency_metric(t)
        gap = 1.0 - cm
        print(f"  depth {n:>2}: CM = {cm:.10f}  (gap to 1: {gap:.10f})")

    # Demo 5: Convergence domain iteration
    print("\n--- Demo 5: Contractive Iteration Convergence ---")
    # f(x) = 0.5 * x + 0.3 is contractive with factor 0.5
    f = lambda x: 0.5 * x + 0.3
    fixed_point = 0.6  # solution to x = 0.5x + 0.3
    traj = convergence_iteration(f, 0.0, 15)
    print(f"Deduction operator: f(x) = 0.5x + 0.3")
    print(f"Fixed point: {fixed_point}")
    print(f"Starting from x=0:")
    for i, x in enumerate(traj):
        err = abs(x - fixed_point)
        print(f"  Step {i:>2}: x = {x:.10f}  error = {err:.2e}")

    # Demo 6: Tropical proof height algebra
    print("\n--- Demo 6: Tropical Proof Heights ---")
    INF = float('inf')

    def t_add(a, b):
        return min(a, b)

    def t_mul(a, b):
        if a == INF or b == INF:
            return INF
        return a + b

    print("Tropical add (min): choose shorter proof")
    print(f"  t_add(3, 5) = {t_add(3, 5)}")
    print(f"  t_add(2, ∞) = {t_add(2, INF)}")

    print("Tropical mul (+): compose proofs")
    print(f"  t_mul(3, 5) = {t_mul(3, 5)}")
    print(f"  t_mul(2, ∞) = {t_mul(2, INF)}")

    print("Distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)")
    a, b, c = 2, 3, 5
    lhs = t_mul(a, t_add(b, c))
    rhs = t_add(t_mul(a, b), t_mul(a, c))
    print(f"  {a} ⊗ ({b} ⊕ {c}) = {a} ⊗ {t_add(b,c)} = {lhs}")
    print(f"  ({a} ⊗ {b}) ⊕ ({a} ⊗ {c}) = {t_mul(a,b)} ⊕ {t_mul(a,c)} = {rhs}")
    print(f"  Equal: {lhs == rhs}")

    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Consistency Metric Convergence

Shows how the consistency metric approaches 1 as self-reference depth increases,
and the geometric convergence of contractive iteration.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def consistency_metric_nested(n: int) -> float:
    """CM of nestedSR(p, n)."""
    if n == 0:
        return 0.0
    return (1 + consistency_metric_nested(n - 1)) / 2


def convergence_trajectory(f, x0: float, steps: int) -> list:
    """Track trajectory of contractive iteration."""
    traj = [x0]
    x = x0
    for _ in range(steps):
        x = f(x)
        traj.append(x)
    return traj


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Consistency metric vs depth
    ax1 = axes[0, 0]
    depths = list(range(15))
    cms = [consistency_metric_nested(d) for d in depths]
    ax1.plot(depths, cms, 'bo-', markersize=8, linewidth=2)
    ax1.axhline(y=1.0, color='r', linestyle='--', linewidth=1.5, label='Boundary (CM=1)')
    ax1.axhline(y=0.5, color='g', linestyle=':', linewidth=1, label='Identity proof (CM=1/2)')
    ax1.set_xlabel('Self-Reference Depth', fontsize=12)
    ax1.set_ylabel('Consistency Metric', fontsize=12)
    ax1.set_title('Consistency Metric vs Self-Reference Depth', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.05, 1.1)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Gap to boundary (log scale)
    ax2 = axes[0, 1]
    gaps = [1.0 - cm for cm in cms]
    ax2.semilogy(depths, gaps, 'ro-', markersize=8, linewidth=2)
    ax2.set_xlabel('Self-Reference Depth', fontsize=12)
    ax2.set_ylabel('Gap to Boundary (1 - CM)', fontsize=12)
    ax2.set_title('Exponential Approach to Boundary', fontsize=14)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Contractive iteration convergence
    ax3 = axes[1, 0]
    factors = [0.3, 0.5, 0.7, 0.9]
    for c in factors:
        f = lambda x, c=c: c * x + (1 - c) * 0.6  # fixed point at 0.6
        traj = convergence_trajectory(f, 0.0, 20)
        ax3.plot(range(len(traj)), traj, '-o', markersize=4, linewidth=1.5,
                label=f'c = {c}')
    ax3.axhline(y=0.6, color='k', linestyle='--', linewidth=1, label='Fixed point')
    ax3.set_xlabel('Iteration Step', fontsize=12)
    ax3.set_ylabel('Value', fontsize=12)
    ax3.set_title('Convergence Speed vs Contraction Factor', fontsize=14)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Proof compression ratio
    ax4 = axes[1, 1]
    ns = list(range(1, 20))
    original_depths = ns
    kernel_depths = [0] * len(ns)
    compression = [n for n in ns]  # compression is n:0

    ax4.bar(ns, compression, color='steelblue', alpha=0.7, edgecolor='navy')
    ax4.set_xlabel('Original Proof Depth', fontsize=12)
    ax4.set_ylabel('Depth Eliminated by wfKernel', fontsize=12)
    ax4.set_title('Unbounded Proof Compression', fontsize=14)
    ax4.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/NWFP/consistency_visualization.png',
                dpi=150, bbox_inches='tight')
    print("Saved visualization to consistency_visualization.png")


if __name__ == "__main__":
    main()
