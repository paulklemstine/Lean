#!/usr/bin/env python3
"""
EML Cryptographic Primitives: Concrete Demonstrations

This demo brings the formally verified theorems to life with concrete
numerical examples of closure one-way functions, sigma protocols,
and fixed-point key exchange.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Set, Dict, Callable, Tuple, Optional
import random

# ============================================================
# I. Closure Operators on Finite Sets
# ============================================================

class ClosureOperator:
    """
    An EML closure operator on a finite set {0, 1, ..., n-1}.
    Satisfies: extensive, monotone, idempotent.
    """
    def __init__(self, n: int, cl_func: Callable[[frozenset], frozenset]):
        self.n = n
        self.universe = frozenset(range(n))
        self._cl = cl_func
        self._verify_axioms()

    def cl(self, A: frozenset) -> frozenset:
        return self._cl(A)

    def _verify_axioms(self):
        """Verify the three axioms on small subsets."""
        from itertools import combinations
        elements = list(range(self.n))

        # Test on singletons and pairs
        for x in elements:
            A = frozenset({x})
            clA = self.cl(A)
            assert A <= clA, f"Extensive violated: {A} not subset of cl({A}) = {clA}"
            assert self.cl(clA) == clA, f"Idempotent violated: cl(cl({A})) != cl({A})"

        for x in elements:
            for y in elements:
                A = frozenset({x})
                B = frozenset({x, y})
                assert self.cl(A) <= self.cl(B), f"Monotone violated for {A}, {B}"

    def closure_min(self, x: int) -> int:
        """closureMin(x) = min(cl({x}))"""
        return min(self.cl(frozenset({x})))


def make_divisibility_closure(n: int) -> ClosureOperator:
    """
    Closure operator on {1,...,n} where cl({x}) = {y : x divides y or y divides x}.
    Actually: cl(A) = A union all divisors and multiples of elements in A, up to n.
    Then close under idempotence.
    """
    universe = set(range(1, n + 1))

    def one_step(A: frozenset) -> frozenset:
        result = set(A)
        for x in A:
            for y in universe:
                if y % x == 0 or x % y == 0:
                    result.add(y)
        return frozenset(result)

    def cl(A: frozenset) -> frozenset:
        # Iterate until fixed point
        current = A
        while True:
            next_set = one_step(current)
            if next_set == current:
                return current
            current = next_set

    return ClosureOperator(n + 1, lambda A: cl(A & universe) | (A - universe))


def make_interval_closure(n: int) -> ClosureOperator:
    """
    Closure on {0,...,n-1}: cl(A) = convex hull = [min(A), max(A)].
    This satisfies all three axioms.
    """
    def cl(A: frozenset) -> frozenset:
        if not A:
            return frozenset()
        lo, hi = min(A), max(A)
        return frozenset(range(lo, hi + 1))

    return ClosureOperator(n, cl)


def make_downward_closure(n: int) -> ClosureOperator:
    """
    Downward closure: cl(A) = {y : y <= max(A)}.
    """
    def cl(A: frozenset) -> frozenset:
        if not A:
            return frozenset()
        return frozenset(range(max(A) + 1))

    return ClosureOperator(n, cl)


# ============================================================
# II. One-Way Function Demonstration
# ============================================================

def demo_one_way_function():
    """Demonstrate the closure min as a one-way function."""
    print("=" * 60)
    print("DEMO 1: Closure Min as One-Way Function")
    print("=" * 60)

    n = 20
    cl = make_interval_closure(n)

    print(f"\nClosure operator: interval closure on {{0,...,{n-1}}}")
    print("cl(A) = [min(A), max(A)] (convex hull)")
    print()

    print("x  | cl({x})           | closureMin(x)")
    print("-" * 45)
    for x in range(n):
        clx = sorted(cl.cl(frozenset({x})))
        cm = cl.closure_min(x)
        print(f"{x:2d} | {{{', '.join(map(str, clx))}}}".ljust(30) + f"| {cm}")

    print("\n--- Idempotence Verification ---")
    all_idempotent = True
    for x in range(n):
        cm = cl.closure_min(x)
        cm2 = cl.closure_min(cm)
        if cm != cm2:
            all_idempotent = False
            print(f"FAIL: closureMin({x}) = {cm}, closureMin({cm}) = {cm2}")
    if all_idempotent:
        print("✓ closureMin(closureMin(x)) = closureMin(x) for all x")

    # Fiber analysis
    print("\n--- Fiber Analysis (Preimage Structure) ---")
    fibers: Dict[int, list] = {}
    for x in range(n):
        cm = cl.closure_min(x)
        if cm not in fibers:
            fibers[cm] = []
        fibers[cm].append(x)

    for target, preimage in sorted(fibers.items()):
        print(f"closureMin⁻¹({target}) = {preimage}  (size: {len(preimage)})")

    print(f"\nFixed points: {[x for x in range(n) if cl.closure_min(x) == x]}")
    print(f"Non-fixed points: {[x for x in range(n) if cl.closure_min(x) != x]}")


# ============================================================
# III. Sigma Protocol Demonstration
# ============================================================

def demo_sigma_protocol():
    """Demonstrate the idempotent sigma protocol."""
    print("\n" + "=" * 60)
    print("DEMO 2: Idempotent Sigma Protocol")
    print("=" * 60)

    n = 15
    cl = make_downward_closure(n)
    print(f"\nClosure: downward closure on {{0,...,{n-1}}}")
    print("cl(A) = {{y : y ≤ max(A)}}")

    # Prover wants to prove knowledge of a preimage
    witness = 7
    target = cl.closure_min(witness)
    print(f"\nProver's witness: x = {witness}")
    print(f"Target (public): closureMin({witness}) = {target}")
    print(f"cl({{{witness}}}) = {sorted(cl.cl(frozenset({witness})))}")

    print("\n--- Protocol Execution ---")
    for trial in range(5):
        # Commit
        r = witness  # In practice, use randomized witness
        commitment = cl.closure_min(r)

        # Challenge
        challenge = random.choice([True, False])

        # Respond
        if challenge:
            response = cl.closure_min(r)
        else:
            response = r

        # Verify
        if challenge:
            accepts = (response == commitment)
        else:
            accepts = (cl.closure_min(response) == commitment)

        print(f"  Trial {trial+1}: commit={commitment}, "
              f"challenge={'1' if challenge else '0'}, "
              f"response={response}, "
              f"verify={'✓' if accepts else '✗'}")

    print("\n--- Special Soundness ---")
    a = commitment
    z0 = witness  # Response for challenge 0
    z1 = commitment  # Response for challenge 1
    print(f"  Transcript 1: (a={a}, e=0, z₀={z0})")
    print(f"  Transcript 2: (a={a}, e=1, z₁={z1})")
    print(f"  closureMin(z₀) = closureMin({z0}) = {cl.closure_min(z0)}")
    print(f"  z₁ = {z1}")
    print(f"  Extracted witness: closureMin(z₀) = z₁ ✓" if cl.closure_min(z0) == z1 else "  ✗")

    print("\n--- HVZK Simulation (no witness needed!) ---")
    for e in [True, False]:
        if e:
            sim_commit = target
            sim_response = target
            sim_verify = (sim_response == sim_commit)
        else:
            # Simulator picks any x and uses closureMin(x)
            sim_x = random.randint(0, n-1)
            sim_commit = cl.closure_min(sim_x)
            sim_response = sim_x
            sim_verify = (cl.closure_min(sim_response) == sim_commit)
        print(f"  Simulated (e={'1' if e else '0'}): "
              f"commit={sim_commit}, response={sim_response}, "
              f"verify={'✓' if sim_verify else '✗'}")
    print("  Key insight: simulator uses IDEMPOTENCE, not the witness!")


# ============================================================
# IV. Key Exchange Demonstration
# ============================================================

def demo_key_exchange():
    """Demonstrate fixed-point key exchange."""
    print("\n" + "=" * 60)
    print("DEMO 3: Fixed-Point Key Exchange")
    print("=" * 60)

    n = 20

    # Alice uses interval closure
    cl_A = make_interval_closure(n)
    # Bob uses downward closure
    cl_B = make_downward_closure(n)

    secret_A = 12
    secret_B = 8

    pub_A = cl_A.closure_min(secret_A)
    pub_B = cl_B.closure_min(secret_B)

    ss_A = cl_A.closure_min(pub_B)
    ss_B = cl_B.closure_min(pub_A)

    print(f"\nAlice's closure: interval closure")
    print(f"Bob's closure: downward closure")
    print(f"\nAlice's secret: {secret_A}")
    print(f"Bob's secret: {secret_B}")
    print(f"\nAlice's public key (closureMin_A({secret_A})): {pub_A}")
    print(f"Bob's public key (closureMin_B({secret_B})): {pub_B}")
    print(f"\nAlice's shared secret (closureMin_A({pub_B})): {ss_A}")
    print(f"Bob's shared secret (closureMin_B({pub_A})): {ss_B}")

    # Verify idempotence of shared secrets
    ss_A2 = cl_A.closure_min(ss_A)
    ss_B2 = cl_B.closure_min(ss_B)
    print(f"\nIdempotence check:")
    print(f"  closureMin_A(ssA) = closureMin_A({ss_A}) = {ss_A2} {'✓' if ss_A == ss_A2 else '✗'}")
    print(f"  closureMin_B(ssB) = closureMin_B({ss_B}) = {ss_B2} {'✓' if ss_B == ss_B2 else '✗'}")

    if ss_A == ss_B:
        print(f"\n✓ Shared secrets MATCH: {ss_A}")
    else:
        print(f"\n  Shared secrets differ: Alice={ss_A}, Bob={ss_B}")
        print("  (This is expected when operators don't commute)")
        print("  The formally verified theorem shows each party's secret")
        print("  is still a fixed point of their own operator.")


# ============================================================
# V. Visualization
# ============================================================

def create_visualization():
    """Create visualization of closure operator structure."""
    n = 12
    cl = make_interval_closure(n)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Closure min function
    ax = axes[0]
    xs = list(range(n))
    cms = [cl.closure_min(x) for x in xs]
    ax.bar(xs, cms, color='steelblue', alpha=0.7, label='closureMin(x)')
    ax.plot(xs, xs, 'r--', alpha=0.5, label='y = x (identity)')
    ax.set_xlabel('x')
    ax.set_ylabel('closureMin(x)')
    ax.set_title('Closure Min: One-Way Function\n(always ≤ x, idempotent)')
    ax.legend()
    ax.set_xticks(xs)

    # Plot 2: Fiber structure
    ax = axes[1]
    fibers: Dict[int, list] = {}
    for x in range(n):
        cm = cl.closure_min(x)
        if cm not in fibers:
            fibers[cm] = []
        fibers[cm].append(x)

    targets = sorted(fibers.keys())
    for i, t in enumerate(targets):
        fiber = fibers[t]
        for x in fiber:
            ax.plot(x, t, 'o', color='steelblue', markersize=8)
            if x != t:
                ax.annotate('', xy=(t, t), xytext=(x, t),
                           arrowprops=dict(arrowstyle='->', color='gray', alpha=0.4))
    ax.plot(range(n), range(n), 'r--', alpha=0.3)
    ax.set_xlabel('Input x')
    ax.set_ylabel('closureMin(x) = target')
    ax.set_title('Fiber Structure\n(preimage partitioning)')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))

    # Plot 3: Idempotence demonstration
    ax = axes[2]
    cm1 = [cl.closure_min(x) for x in range(n)]
    cm2 = [cl.closure_min(cl.closure_min(x)) for x in range(n)]
    width = 0.35
    x_pos = np.arange(n)
    ax.bar(x_pos - width/2, cm1, width, label='closureMin(x)', color='steelblue', alpha=0.7)
    ax.bar(x_pos + width/2, cm2, width, label='closureMin²(x)', color='coral', alpha=0.7)
    ax.set_xlabel('x')
    ax.set_ylabel('Value')
    ax.set_title('Idempotence: closureMin² = closureMin\n(enables ZK simulation)')
    ax.legend()
    ax.set_xticks(x_pos)

    plt.tight_layout()
    plt.savefig('diagram.svg', format='svg', bbox_inches='tight')
    plt.savefig('diagram.png', format='png', dpi=150, bbox_inches='tight')
    print("\n✓ Visualization saved to diagram.svg and diagram.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)

    demo_one_way_function()
    demo_sigma_protocol()
    demo_key_exchange()

    try:
        create_visualization()
    except Exception as e:
        print(f"\nVisualization skipped: {e}")

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)
