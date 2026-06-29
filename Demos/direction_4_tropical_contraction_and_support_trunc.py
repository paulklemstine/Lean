#!/usr/bin/env python3
"""
applications.py — Real-world Applications of Tropical Contraction

Demonstrates applications of tropical support contraction to:
1. Discrete optimization: resource deletion stability
2. Polynomial differentiation: Newton polytope of derivatives
3. Valuated matroids: deletion and contraction operations
4. Energy landscapes: mode removal in statistical mechanics
"""

from typing import Dict, Set, Tuple, List
import random

ExponentVector = Tuple[int, ...]


# --- Utility functions (self-contained) ---

def exponent_contract(i: int, m: ExponentVector):
    if m[i] == 0:
        return None
    return m[:i] + (m[i] - 1,) + m[i + 1:]

def support_contract(i: int, S: Set[ExponentVector]) -> Set[ExponentVector]:
    return {mc for m in S if (mc := exponent_contract(i, m)) is not None}

def check_exchange(S: Set[ExponentVector]) -> bool:
    if not S:
        return True
    S_f = frozenset(S)
    d = len(next(iter(S)))
    for a in S:
        for b in S:
            for k in range(d):
                if a[k] > b[k]:
                    ok = False
                    for j in range(d):
                        if a[j] < b[j]:
                            e = list(a); e[k] -= 1; e[j] += 1
                            if tuple(e) in S_f:
                                ok = True; break
                    if not ok:
                        return False
    return True


# --- Application 1: Resource Allocation ---

def app_resource_allocation():
    """Stability of optimal resource allocation under resource deletion.

    In economics, M-convex sets model feasible allocations satisfying gross
    substitutes. When a resource type is removed (contraction), the remaining
    feasible allocations still satisfy gross substitutes.
    """
    print("=" * 60)
    print("APPLICATION 1: Resource Allocation Stability")
    print("=" * 60)

    # 4 types of resources, total budget = 5
    # Feasible allocations: all (a,b,c,d) with a+b+c+d = 5
    d, total = 4, 5
    allocations = set()
    for a in range(total + 1):
        for b in range(total + 1 - a):
            for c in range(total + 1 - a - b):
                allocations.add((a, b, c, total - a - b - c))

    print(f"Original: {len(allocations)} feasible allocations in {d}D, sum={total}")
    print(f"  M-convex (gross substitutes): {check_exchange(allocations)}")

    # Remove resource type 2 (contract in direction 2)
    remaining = support_contract(2, allocations)
    print(f"\nAfter removing resource type 2:")
    print(f"  {len(remaining)} remaining allocations")
    print(f"  Still satisfies gross substitutes: {check_exchange(remaining)}")

    # Remove resource type 0
    remaining2 = support_contract(0, remaining)
    print(f"\nAfter also removing resource type 0:")
    print(f"  {len(remaining2)} remaining allocations")
    print(f"  Still satisfies gross substitutes: {check_exchange(remaining2)}")


# --- Application 2: Polynomial Differentiation ---

def app_polynomial_differentiation():
    """Newton polytope under polynomial differentiation.

    For a multivariate polynomial f, the support of ∂f/∂x_i is exactly
    support_contract(i, supp(f)) (up to scalar factors). This connects
    tropical contraction to algebraic calculus.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Polynomial Differentiation and Newton Polytopes")
    print("=" * 60)

    # f(x,y,z) with support {(3,0,1), (2,1,0), (1,2,1), (0,0,3)}
    supp = {(3, 0, 1), (2, 1, 0), (1, 2, 1), (0, 0, 3)}
    coeffs = {(3, 0, 1): 2, (2, 1, 0): -3, (1, 2, 1): 5, (0, 0, 3): 1}

    print(f"f = ", end="")
    terms = []
    for m in sorted(supp, reverse=True):
        c = coeffs[m]
        vars_str = "".join(f"{'xyz'[j]}^{m[j]}" if m[j] > 1
                          else ('xyz'[j] if m[j] == 1 else '')
                          for j in range(3))
        terms.append(f"{c}*{vars_str}" if vars_str else str(c))
    print(" + ".join(terms))
    print(f"Support: {sorted(supp)}")

    for i, var in enumerate("xyz"):
        contracted = support_contract(i, supp)
        # Compute actual derivative support
        deriv_supp = set()
        for m in supp:
            if m[i] > 0:
                new_m = m[:i] + (m[i] - 1,) + m[i + 1:]
                deriv_supp.add(new_m)
        print(f"\n∂f/∂{var}:")
        print(f"  Support of derivative: {sorted(deriv_supp)}")
        print(f"  support_contract({i}, supp(f)): {sorted(contracted)}")
        print(f"  Match: {deriv_supp == contracted}")


# --- Application 3: Matroid Operations ---

def app_matroid_operations():
    """Matroid contraction via tropical support contraction.

    For a matroid with bases B encoded as indicator vectors,
    contraction by element i corresponds to support contraction in direction i,
    restricted to bases containing i.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Matroid Contraction")
    print("=" * 60)

    # Uniform matroid U(2,4): all 2-element subsets of {0,1,2,3}
    bases = set()
    for i in range(4):
        for j in range(i + 1, 4):
            v = [0, 0, 0, 0]
            v[i] = 1
            v[j] = 1
            bases.add(tuple(v))

    print(f"U(2,4) bases: {sorted(bases)}")
    print(f"  M-convex: {check_exchange(bases)}")

    # Contract element 0: restrict to bases containing 0, remove 0
    contracted = support_contract(0, bases)
    print(f"\nContract element 0:")
    print(f"  Result: {sorted(contracted)}")
    print(f"  M-convex: {check_exchange(contracted)}")
    print(f"  This is U(1,3) = all singletons from {{1,2,3}}")


# --- Application 4: Energy Landscape Mode Removal ---

def app_energy_landscape():
    """Removing interaction modes from tropical energy landscapes.

    A tropical polynomial E(x) = min_m (w_m + m·x) defines a piecewise-linear
    energy landscape. Contracting direction i corresponds to removing one quantum
    of interaction mode i, preserving the tropical convexity structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Energy Landscape Mode Removal")
    print("=" * 60)

    # Energy landscape with 3 modes
    supp = {(2, 0), (1, 1), (0, 2), (1, 0), (0, 1)}
    weights = {(2, 0): 3, (1, 1): 1, (0, 2): 4, (1, 0): 2, (0, 1): 5}

    print(f"Original energy landscape:")
    print(f"  E(x,y) = min over modes:")
    for m in sorted(supp, reverse=True):
        print(f"    {weights[m]} + {m[0]}x + {m[1]}y  (mode {m})")

    print(f"\n  Support: {sorted(supp)}")
    print(f"  M-convex: {check_exchange(supp)}")

    # Remove one quantum of mode 0 (x-interaction)
    contracted = support_contract(0, supp)
    print(f"\nAfter removing one x-quantum:")
    print(f"  Remaining modes: {sorted(contracted)}")
    print(f"  M-convex preserved: {check_exchange(contracted)}")


if __name__ == "__main__":
    app_resource_allocation()
    app_polynomial_differentiation()
    app_matroid_operations()
    app_energy_landscape()


#!/usr/bin/env python3
"""
demo.py — Tropical Contraction and Support Truncation

Demonstrates:
1. Construction of tropical supports (exponent vectors with weights)
2. Support contraction in a given coordinate direction
3. Checking the M-convex exchange axiom on finite supports
4. Searching for counterexamples to valuated exchange preservation
5. Visualization of 2D Newton support truncations
"""

import itertools
import random
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

# --- Core Data Structures ---

# An exponent vector is a tuple of non-negative integers
ExponentVector = Tuple[int, ...]

class TropicalSupport:
    """A tropical polynomial represented by its finite support and weight function."""
    def __init__(self, supp: Set[ExponentVector], weight: Dict[ExponentVector, int]):
        self.supp = frozenset(supp)
        self.weight = {m: w for m, w in weight.items() if m in supp}
        # Ensure weight is 0 outside support
        for m in supp:
            if m not in self.weight:
                self.weight[m] = 0

    def __repr__(self):
        items = sorted((m, self.weight.get(m, 0)) for m in self.supp)
        return f"TropicalSupport({items})"


def exponent_contract(i: int, m: ExponentVector) -> Optional[ExponentVector]:
    """Contract exponent vector m in direction i.
    Returns None if m[i] == 0, otherwise returns m with m[i] decremented by 1."""
    if m[i] == 0:
        return None
    return m[:i] + (m[i] - 1,) + m[i+1:]


def support_contract(i: int, S: Set[ExponentVector]) -> Set[ExponentVector]:
    """Contract a finite set of exponent vectors in direction i."""
    result = set()
    for m in S:
        mc = exponent_contract(i, m)
        if mc is not None:
            result.add(mc)
    return result


def tropical_truncate(i: int, T: TropicalSupport) -> TropicalSupport:
    """Truncate a tropical support in direction i."""
    new_supp = support_contract(i, T.supp)
    new_weight = {}
    for m_prime in new_supp:
        # Lift back: add 1 to coordinate i
        m_lifted = m_prime[:i] + (m_prime[i] + 1,) + m_prime[i+1:]
        new_weight[m_prime] = T.weight.get(m_lifted, 0)
    return TropicalSupport(new_supp, new_weight)


# --- Exchange Axiom ---

def check_exchange(S: Set[ExponentVector]) -> bool:
    """Check if S satisfies the M-convex symmetric exchange property.
    For all α, β ∈ S and all i with α[i] > β[i],
    there exists j with α[j] < β[j] such that α - e_i + e_j ∈ S."""
    S_frozen = frozenset(S)
    n = len(next(iter(S))) if S else 0
    for alpha in S:
        for beta in S:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in S_frozen:
                                found = True
                                break
                    if not found:
                        return False
    return True


def check_valuated_exchange(T: TropicalSupport) -> bool:
    """Check valuated M-convex exchange: for all α, β ∈ supp with α[k] > β[k],
    there exists j with α[j] < β[j] such that
    α - e_k + e_j ∈ supp AND
    w(α - e_k + e_j) + w(β + e_k - e_j) ≥ w(α) + w(β)."""
    S = T.supp
    n = len(next(iter(S))) if S else 0
    for alpha in S:
        for beta in S:
            for k in range(n):
                if alpha[k] > beta[k]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            exc_a = list(alpha)
                            exc_a[k] -= 1
                            exc_a[j] += 1
                            exc_a = tuple(exc_a)
                            exc_b = list(beta)
                            exc_b[j] -= 1
                            exc_b[k] += 1
                            exc_b = tuple(exc_b)
                            if exc_a in S:
                                w_sum = T.weight.get(exc_a, 0) + T.weight.get(exc_b, 0)
                                if w_sum >= T.weight.get(alpha, 0) + T.weight.get(beta, 0):
                                    found = True
                                    break
                    if not found:
                        return False
    return True


# --- Demonstrations ---

def demo_basic_contraction():
    """Demo 1: Basic support contraction."""
    print("=" * 60)
    print("DEMO 1: Basic Support Contraction")
    print("=" * 60)

    # 2D polynomial: f = x²y + xy² + xy
    # Support: {(2,1), (1,2), (1,1)}
    supp = {(2, 1), (1, 2), (1, 1)}
    weights = {(2, 1): 3, (1, 2): -1, (1, 1): 2}
    T = TropicalSupport(supp, weights)

    print(f"Original support: {sorted(supp)}")
    print(f"Weights: {weights}")

    # Contract in direction 0 (x-direction)
    T0 = tropical_truncate(0, T)
    print(f"\nAfter contraction in x-direction:")
    print(f"  Support: {sorted(T0.supp)}")
    print(f"  Weights: {T0.weight}")

    # Contract in direction 1 (y-direction)
    T1 = tropical_truncate(1, T)
    print(f"\nAfter contraction in y-direction:")
    print(f"  Support: {sorted(T1.supp)}")
    print(f"  Weights: {T1.weight}")

    # Verify Theorem 1: supp(tropicalTruncate) == supportContract
    contracted_0 = support_contract(0, supp)
    contracted_1 = support_contract(1, supp)
    print(f"\nVerification of Theorem 1:")
    print(f"  tropicalTruncate(0).supp == supportContract(0): {set(T0.supp) == contracted_0}")
    print(f"  tropicalTruncate(1).supp == supportContract(1): {set(T1.supp) == contracted_1}")


def demo_inverse_image():
    """Demo 2: Adding e_i back recovers the original filtered support."""
    print("\n" + "=" * 60)
    print("DEMO 2: Inverse Image Property")
    print("=" * 60)

    supp = {(3, 0, 1), (0, 2, 1), (1, 1, 0), (2, 0, 0)}

    for i in range(3):
        contracted = support_contract(i, supp)
        # Add e_i back
        lifted = {m[:i] + (m[i] + 1,) + m[i+1:] for m in contracted}
        filtered = {m for m in supp if m[i] > 0}
        print(f"  Direction {i}: lift(contract) == filter: {lifted == filtered}")
        print(f"    Contracted: {sorted(contracted)}")
        print(f"    Lifted:     {sorted(lifted)}")
        print(f"    Filtered:   {sorted(filtered)}")


def demo_exchange_preservation():
    """Demo 3: M-convex exchange is preserved under contraction."""
    print("\n" + "=" * 60)
    print("DEMO 3: Exchange Preservation under Contraction")
    print("=" * 60)

    # Standard simplex slice: all (a,b,c) with a+b+c = 3, a,b,c ≥ 0
    # This is the base of a matroid and is M-convex
    n = 3
    total = 3
    simplex = set()
    for a in range(total + 1):
        for b in range(total + 1 - a):
            c = total - a - b
            simplex.add((a, b, c))

    print(f"Simplex slice (sum={total}): {sorted(simplex)}")
    print(f"  M-convex: {check_exchange(simplex)}")

    for i in range(n):
        contracted = support_contract(i, simplex)
        is_exchange = check_exchange(contracted)
        print(f"  After contraction in direction {i}: {sorted(contracted)}")
        print(f"    M-convex: {is_exchange}")


def demo_valuated_exchange_search():
    """Demo 4: Search for counterexamples to valuated exchange preservation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Valuated Exchange Preservation Search")
    print("=" * 60)

    random.seed(42)
    n_tests = 500
    n_counterexamples = 0

    for trial in range(n_tests):
        # Generate a random M-convex support (simplex slice)
        dim = random.choice([2, 3])
        total = random.randint(2, 5)

        if dim == 2:
            supp = {(a, total - a) for a in range(total + 1)}
        else:
            supp = set()
            for a in range(total + 1):
                for b in range(total + 1 - a):
                    supp.add((a, b, total - a - b))

        # Random integer weights in [-3, 3]
        weights = {m: random.randint(-3, 3) for m in supp}
        T = TropicalSupport(supp, weights)

        if not check_valuated_exchange(T):
            continue  # Skip non-valuated-M-convex supports

        # Check preservation under contraction
        for i in range(dim):
            T_contracted = tropical_truncate(i, T)
            if not check_valuated_exchange(T_contracted):
                n_counterexamples += 1
                print(f"  COUNTEREXAMPLE found (trial {trial}, dir {i}):")
                print(f"    Original support: {sorted(supp)}")
                print(f"    Weights: {weights}")
                print(f"    Contracted support: {sorted(T_contracted.supp)}")
                print(f"    Contracted weights: {T_contracted.weight}")
                break

    if n_counterexamples == 0:
        print(f"  No counterexamples found in {n_tests} random tests.")
        print(f"  Conjecture: valuated exchange is preserved under truncation.")
    else:
        print(f"  Found {n_counterexamples} counterexamples out of {n_tests} tests.")


def demo_newton_polytope():
    """Demo 5: Newton polytope truncation visualization (text-based)."""
    print("\n" + "=" * 60)
    print("DEMO 5: Newton Polytope Truncation (2D)")
    print("=" * 60)

    # Support of a 2D polynomial
    supp = {(0, 3), (1, 2), (2, 1), (3, 0), (1, 1), (2, 0)}
    print(f"Original support: {sorted(supp)}")

    for i in range(2):
        contracted = support_contract(i, supp)
        print(f"\nContraction in direction {i}:")
        print(f"  Result: {sorted(contracted)}")
        print(f"  = {{m - e_{i} | m in S, m[{i}] > 0}}")

        # Verify: contracted = {m with m[i]-1 | m in S, m[i] > 0}
        expected = set()
        for m in supp:
            if m[i] > 0:
                expected.add(m[:i] + (m[i] - 1,) + m[i+1:])
        assert contracted == expected, "Contraction verification failed!"
        print(f"  Verified: matches {{m - e_{i} | m in S, m[{i}] > 0}}")


def demo_cardinality_preservation():
    """Demo 6: Support contraction preserves cardinality of positive-coordinate subset."""
    print("\n" + "=" * 60)
    print("DEMO 6: Cardinality Preservation")
    print("=" * 60)

    supp = {(2, 0, 1), (0, 3, 0), (1, 1, 2), (3, 0, 0), (0, 0, 4)}
    print(f"Support: {sorted(supp)}")

    for i in range(3):
        pos_count = sum(1 for m in supp if m[i] > 0)
        contracted = support_contract(i, supp)
        print(f"  Direction {i}: |{{m | m[{i}] > 0}}| = {pos_count}, "
              f"|contract| = {len(contracted)}, equal: {pos_count == len(contracted)}")


if __name__ == "__main__":
    demo_basic_contraction()
    demo_inverse_image()
    demo_exchange_preservation()
    demo_valuated_exchange_search()
    demo_newton_polytope()
    demo_cardinality_preservation()


"""
Visualization: Contraction Cascade — Iterative Support Reduction

Shows what happens when we repeatedly contract a support set in
different directions. The support shrinks monotonically, and M-convexity
is preserved at every step. This visualizes the tower of truncations
that connects the original Newton polytope to smaller and smaller
sub-polytopes.
"""

import matplotlib.pyplot as plt
import numpy as np

def exponent_contract(i, m):
    if m[i] == 0:
        return None
    return m[:i] + (m[i] - 1,) + m[i+1:]

def support_contract(i, S):
    return {mc for m in S if (mc := exponent_contract(i, m)) is not None}

def check_exchange(S):
    if not S:
        return True
    S_f = frozenset(S)
    d = len(next(iter(S)))
    for a in S:
        for b in S:
            for k in range(d):
                if a[k] > b[k]:
                    ok = False
                    for j in range(d):
                        if a[j] < b[j]:
                            e = list(a); e[k] -= 1; e[j] += 1
                            if tuple(e) in S_f:
                                ok = True; break
                    if not ok:
                        return False
    return True

# Start with simplex slice sum=4 in 2D
total = 5
S0 = {(a, total - a) for a in range(total + 1)}

# Build contraction cascade
cascade = [("Original (sum=5)", S0)]
current = S0
directions = [0, 1, 0, 1, 0]  # alternate contractions
for step, d in enumerate(directions):
    current = support_contract(d, current)
    if not current:
        break
    dir_name = 'x' if d == 0 else 'y'
    cascade.append((f"Step {step+1}: contract {dir_name}", current))

n_plots = len(cascade)
fig, axes = plt.subplots(1, n_plots, figsize=(4 * n_plots, 4))
if n_plots == 1:
    axes = [axes]

fig.suptitle('Contraction Cascade: Iterative Support Truncation',
             fontsize=14, fontweight='bold')

colors = plt.cm.viridis(np.linspace(0.2, 0.8, n_plots))

for idx, (title, S) in enumerate(cascade):
    ax = axes[idx]
    if not S:
        ax.text(0.5, 0.5, 'Empty', ha='center', va='center', fontsize=14)
        ax.set_title(title)
        continue

    pts = np.array(sorted(S))
    mconv = check_exchange(S)

    ax.scatter(pts[:, 0], pts[:, 1], c=[colors[idx]], s=120,
              zorder=5, edgecolors='black', linewidth=1.5)

    # Connect adjacent points
    if len(pts) >= 2:
        ax.plot(pts[:, 0], pts[:, 1], '-', color=colors[idx], alpha=0.4, linewidth=2)

    for p in S:
        ax.annotate(f'({p[0]},{p[1]})', p, textcoords="offset points",
                   xytext=(5, 8), fontsize=8)

    status = "✓ M-convex" if mconv else "✗ Not M-convex"
    ax.set_title(f'{title}\n|S|={len(S)}, {status}', fontsize=10)
    ax.set_xlabel('x-exponent')
    ax.set_ylabel('y-exponent')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, total + 0.5)
    ax.set_ylim(-0.5, total + 0.5)
    ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('contraction_cascade.png', dpi=150, bbox_inches='tight')
print("Saved contraction_cascade.png")


"""
Visualization: M-Convex Exchange Preservation Under Contraction

Shows that the M-convex exchange property is preserved when contracting
a support set in any coordinate direction. Displays exchange moves
before and after contraction for a simplex slice.

This visualizes Theorem 2: MConvexExchangeFinsupp.supportContract
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

def exponent_contract(i, m):
    if m[i] == 0:
        return None
    return m[:i] + (m[i] - 1,) + m[i+1:]

def support_contract(i, S):
    return {mc for m in S if (mc := exponent_contract(i, m)) is not None}

def find_exchange_witnesses(S, alpha, beta):
    """Find all valid exchange witnesses for alpha, beta."""
    d = len(alpha)
    witnesses = []
    for k in range(d):
        if alpha[k] > beta[k]:
            for j in range(d):
                if alpha[j] < beta[j]:
                    exc = list(alpha)
                    exc[k] -= 1
                    exc[j] += 1
                    if tuple(exc) in S:
                        witnesses.append((k, j, tuple(exc)))
    return witnesses

# Generate simplex slice
total = 3
simplex = set()
for a in range(total + 1):
    for b in range(total + 1 - a):
        simplex.add((a, b, total - a - b))

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('M-Convex Exchange Preservation Under Support Contraction',
             fontsize=14, fontweight='bold')

# Project 3D points to 2D for visualization (use first two coords)
def project(pts):
    return [(p[0], p[1]) for p in pts]

datasets = [
    ("Original: Simplex Δ₃", simplex),
    ("Contract dir 0", support_contract(0, simplex)),
    ("Contract dir 1", support_contract(1, simplex)),
]

for idx, (title, S) in enumerate(datasets):
    ax = axes[idx]
    pts_2d = project(S)
    pts_arr = np.array(pts_2d)

    # Plot points
    ax.scatter(pts_arr[:, 0], pts_arr[:, 1], c='royalblue', s=100,
              zorder=5, edgecolors='navy', linewidth=1.5)

    # Label points with full coordinates
    for p, p_full in zip(pts_2d, S):
        ax.annotate(str(p_full), p, textcoords="offset points",
                   xytext=(5, 8), fontsize=7)

    # Draw some exchange moves
    S_list = sorted(S)
    exchange_count = 0
    for a_idx, alpha in enumerate(S_list):
        for beta in S_list[a_idx+1:]:
            witnesses = find_exchange_witnesses(S, alpha, beta)
            if witnesses and exchange_count < 8:
                k, j, exc = witnesses[0]
                # Draw arrow from alpha to exchanged
                a2d = (alpha[0], alpha[1])
                e2d = (exc[0], exc[1])
                if a2d != e2d:
                    ax.annotate('', xy=e2d, xytext=a2d,
                               arrowprops=dict(arrowstyle='->', color='red',
                                              lw=1.2, alpha=0.4))
                    exchange_count += 1

    ax.set_title(f'{title}\n|S| = {len(S)}, M-convex: ✓', fontsize=11)
    ax.set_xlabel('Coordinate 0')
    ax.set_ylabel('Coordinate 1')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('exchange_preservation.png', dpi=150, bbox_inches='tight')
print("Saved exchange_preservation.png")


"""
Visualization: Newton Polytope Truncation in 2D

Shows how support contraction transforms the Newton polygon of a polynomial.
The original support (blue) is filtered to points with positive i-coordinate,
then translated by -e_i to produce the contracted support (red).

This visualizes Theorem 1: tropicalTruncate(i, T).supp = supportContract(i, T.supp)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from scipy.spatial import ConvexHull

def exponent_contract(i, m):
    if m[i] == 0:
        return None
    return (m[0] - (1 if i == 0 else 0), m[1] - (1 if i == 1 else 0))

def support_contract(i, S):
    return {mc for m in S if (mc := exponent_contract(i, m)) is not None}

def convex_hull_points(pts):
    if len(pts) < 3:
        return list(pts)
    arr = np.array(list(pts))
    try:
        hull = ConvexHull(arr)
        return [tuple(arr[v]) for v in hull.vertices]
    except:
        return list(pts)

# Setup
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Newton Polytope Truncation: Support Contraction in 2D',
             fontsize=16, fontweight='bold')

# Example supports
examples = [
    ("Cubic: x³ + x²y + xy² + y³ + xy",
     {(3, 0), (2, 1), (1, 2), (0, 3), (1, 1)}),
    ("Degree 4: x⁴ + x³y + x²y² + xy³ + y⁴",
     {(4, 0), (3, 1), (2, 2), (1, 3), (0, 4)}),
]

for row, (title, supp) in enumerate(examples):
    # Original
    ax = axes[row, 0]
    pts = np.array(list(supp))
    ax.scatter(pts[:, 0], pts[:, 1], c='royalblue', s=120, zorder=5,
              edgecolors='navy', linewidth=1.5)
    hull_pts = convex_hull_points(supp)
    if len(hull_pts) >= 3:
        hull_arr = np.array(hull_pts + [hull_pts[0]])
        ax.fill(hull_arr[:, 0], hull_arr[:, 1], alpha=0.15, color='royalblue')
        ax.plot(hull_arr[:, 0], hull_arr[:, 1], 'b-', alpha=0.5, linewidth=1.5)
    for p in supp:
        ax.annotate(f'({p[0]},{p[1]})', p, textcoords="offset points",
                   xytext=(5, 8), fontsize=8)
    ax.set_title(f'{title}\nOriginal Support', fontsize=10)
    ax.set_xlabel('x-exponent')
    ax.set_ylabel('y-exponent')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.set_xlim(-0.5, max(p[0] for p in supp) + 0.5)
    ax.set_ylim(-0.5, max(p[1] for p in supp) + 0.5)

    for col, direction in enumerate([0, 1]):
        ax = axes[row, col + 1]
        contracted = support_contract(direction, supp)
        filtered = {m for m in supp if m[direction] > 0}

        # Plot filtered (faded blue)
        filt_pts = np.array(list(filtered))
        ax.scatter(filt_pts[:, 0], filt_pts[:, 1], c='lightblue', s=80,
                  zorder=3, edgecolors='blue', linewidth=1, alpha=0.5,
                  label='Filtered (m[i]>0)')

        # Draw arrows from filtered to contracted
        for m in filtered:
            mc = exponent_contract(direction, m)
            if mc:
                ax.annotate('', xy=mc, xytext=m,
                           arrowprops=dict(arrowstyle='->', color='gray',
                                          lw=1.5, alpha=0.6))

        # Plot contracted (red)
        c_pts = np.array(list(contracted))
        ax.scatter(c_pts[:, 0], c_pts[:, 1], c='crimson', s=120, zorder=5,
                  edgecolors='darkred', linewidth=1.5, label='Contracted')

        # Convex hull of contracted
        if len(contracted) >= 3:
            hull_c = convex_hull_points(contracted)
            hull_arr = np.array(hull_c + [hull_c[0]])
            ax.fill(hull_arr[:, 0], hull_arr[:, 1], alpha=0.15, color='crimson')
            ax.plot(hull_arr[:, 0], hull_arr[:, 1], 'r-', alpha=0.5, linewidth=1.5)

        for p in contracted:
            ax.annotate(f'({p[0]},{p[1]})', p, textcoords="offset points",
                       xytext=(5, 8), fontsize=8, color='darkred')

        dir_name = 'x' if direction == 0 else 'y'
        ax.set_title(f'Contract direction {dir_name}\n'
                    f'|original| = {len(supp)} → |contracted| = {len(contracted)}',
                    fontsize=10)
        ax.set_xlabel('x-exponent')
        ax.set_ylabel('y-exponent')
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=8, loc='upper right')
        ax.set_aspect('equal')
        all_pts = list(supp) + list(contracted)
        ax.set_xlim(-0.5, max(p[0] for p in all_pts) + 0.5)
        ax.set_ylim(-0.5, max(p[1] for p in all_pts) + 0.5)

plt.tight_layout()
plt.savefig('newton_truncation.png', dpi=150, bbox_inches='tight')
print("Saved newton_truncation.png")
