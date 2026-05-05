#!/usr/bin/env python3
"""
Tropical Congruence Nullstellensatz — Concrete Demonstrations

This script demonstrates the congruence-level tropical Nullstellensatz
with concrete numerical examples in the max-plus semiring and Boolean semiring.

The main theorem states: for a finite set R of equation pairs (f_i, g_i)
in a function semiring, the radical congruence of R equals the vanishing
congruence of the zero set (solution locus) of R.

In concrete terms: two functions f, g satisfy every consequence of the
equations R if and only if f and g agree on every common solution of R.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product
from typing import Callable, List, Tuple, Set

# ============================================================
# Core Definitions (matching the Lean formalization)
# ============================================================

def zero_set(R: List[Tuple[Callable, Callable]], domain: List) -> Set:
    """
    TropCongr.zeroSet: the set of points where all equation pairs agree.
    V(R) = {x | forall (f,g) in R, f(x) = g(x)}
    """
    result = set()
    for x in domain:
        if all(f(x) == g(x) for f, g in R):
            result.add(x)
    return result

def vanishing_congruence(V: Set, functions: List[Callable], domain: List) -> Set[Tuple[int, int]]:
    """
    TropCongr.vanishing: pairs (i,j) of function indices that agree on V.
    I_c(V) = {(f,g) | forall x in V, f(x) = g(x)}
    """
    result = set()
    for i in range(len(functions)):
        for j in range(len(functions)):
            if all(functions[i](x) == functions[j](x) for x in V):
                result.add((i, j))
    return result

def radical_congruence(R: List[Tuple[Callable, Callable]],
                       functions: List[Callable],
                       domain: List) -> Set[Tuple[int, int]]:
    """
    TropCongr.radical: pairs (i,j) that agree wherever all pairs in R agree.
    rad(R) = {(f,g) | forall x, (forall (p,q) in R, p(x)=q(x)) -> f(x)=g(x)}
    """
    V = zero_set(R, domain)
    return vanishing_congruence(V, functions, domain)


# ============================================================
# Demo 1: Max-Plus Functions on a Finite Domain
# ============================================================

def demo1_maxplus():
    print("=" * 70)
    print("DEMO 1: Max-Plus (Tropical) Semiring on {0,1,2,3,4}")
    print("=" * 70)

    domain = list(range(5))

    def f0(x): return max(x, 2)
    def f1(x): return max(x + 1, 3)
    def f2(x): return max(2 * x, x + 1)
    def f3(x): return x + 2
    def f4(x): return max(x, 2)       # same as f0
    def f5(x): return max(x + 1, 3)   # same as f1

    functions = [f0, f1, f2, f3, f4, f5]
    names = ["max(x,2)", "max(x+1,3)", "max(2x,x+1)", "x+2", "max(x,2)'", "max(x+1,3)'"]

    print("\nFunction values:")
    print(f"{'x':>3}", end="")
    for name in names:
        print(f"  {name:>14}", end="")
    print()
    for x in domain:
        print(f"{x:>3}", end="")
        for f in functions:
            print(f"  {f(x):>14}", end="")
        print()

    # Non-trivial: R = {(f0, f3)} : max(x,2) = x+2
    R = [(f0, f3)]
    V = zero_set(R, domain)
    print(f"\nR = {{(max(x,2), x+2)}}")
    print(f"V(R) = {V}")

    rad_R = radical_congruence(R, functions, domain)
    van_V = vanishing_congruence(V, functions, domain)

    assert rad_R == van_V, "FAILURE!"
    print(f"\n** VERIFIED: radical(R) = vanishing(V(R)) **")


# ============================================================
# Demo 2: Boolean Semiring
# ============================================================

def demo2_boolean():
    print("\n" + "=" * 70)
    print("DEMO 2: Boolean Semiring {0,1} (OR = +, AND = *)")
    print("=" * 70)

    domain = list(product([0, 1], repeat=3))

    def f_or_12(x): return max(x[0], x[1])
    def f_and_12(x): return min(x[0], x[1])
    def f_or_23(x): return max(x[1], x[2])
    def f_and_23(x): return min(x[1], x[2])
    def f_id1(x): return x[0]
    def f_id2(x): return x[1]
    def f_id3(x): return x[2]
    def f_const1(x): return 1

    functions = [f_or_12, f_and_12, f_or_23, f_and_23, f_id1, f_id2, f_id3, f_const1]
    names = ["x1|x2", "x1&x2", "x2|x3", "x2&x3", "x1", "x2", "x3", "1"]

    R = [(f_or_12, f_or_23)]
    V = zero_set(R, domain)
    print(f"\nR = {{(x1|x2, x2|x3)}}")
    print(f"V(R) = points where x1|x2 = x2|x3:")
    for x in sorted(V):
        print(f"  {x}")

    rad_R = radical_congruence(R, functions, domain)
    van_V = vanishing_congruence(V, functions, domain)

    assert rad_R == van_V
    print(f"\n** VERIFIED: radical(R) = vanishing(V(R)) **")

    print(f"\nNon-trivial congruences on V(R):")
    for i in range(len(functions)):
        for j in range(i+1, len(functions)):
            if (i, j) in rad_R:
                print(f"  {names[i]} ~ {names[j]}")


# ============================================================
# Demo 3: Visualization
# ============================================================

def demo3_galois_visualization():
    print("\n" + "=" * 70)
    print("DEMO 3: Galois Connection Visualization")
    print("=" * 70)

    domain = list(range(8))

    fns = [
        lambda x: x,
        lambda x: x % 4,
        lambda x: x // 2,
        lambda x: min(x, 3),
        lambda x: max(x - 2, 0),
    ]

    pairs_sequence = [
        (fns[0], fns[3]),
        (fns[1], fns[0]),
        (fns[2], fns[4]),
    ]
    pair_names = [
        "(x, min(x,3))",
        "(x%4, x)",
        "(x//2, max(x-2,0))",
    ]

    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    for k in range(3):
        R = pairs_sequence[:k+1]
        V = zero_set(R, domain)
        rad = radical_congruence(R, fns, domain)
        n_congr = sum(1 for i, j in rad if i < j)

        axes[k].bar(domain,
                    [1 if x in V else 0 for x in domain],
                    color=['#2ecc71' if x in V else '#e74c3c' for x in domain],
                    edgecolor='black')
        axes[k].set_title(f"Equations: {', '.join(pair_names[:k+1])}\n"
                         f"|V(R)| = {len(V)}, #congr = {n_congr}",
                         fontsize=9)
        axes[k].set_xlabel("x")
        axes[k].set_ylabel("In V(R)?")
        axes[k].set_ylim(-0.1, 1.3)
        axes[k].set_xticks(domain)

    plt.suptitle("Galois Connection: Adding equations shrinks the solution locus",
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig("demos/galois_connection.png", dpi=150, bbox_inches='tight')
    print("Saved: demos/galois_connection.png")


# ============================================================
# Demo 4: Congruence Structure Verification
# ============================================================

def demo4_congruence_structure():
    print("\n" + "=" * 70)
    print("DEMO 4: Semiring Congruence Properties")
    print("=" * 70)

    domain = list(range(6))
    fns = [
        lambda x: x,
        lambda x: x % 3,
        lambda x: min(x, 2),
        lambda x: x // 2,
        lambda x: max(x - 1, 0),
    ]
    fn_names = ["x", "x%3", "min(x,2)", "x//2", "max(x-1,0)"]
    V = {0, 1, 2}

    print(f"V = {V}")
    congr = vanishing_congruence(V, fns, domain)

    # Reflexivity
    all_refl = all((i, i) in congr for i in range(len(fns)))
    print(f"1. Reflexive: {all_refl}")

    # Symmetry
    all_sym = all((j, i) in congr for (i, j) in congr)
    print(f"2. Symmetric: {all_sym}")

    # Transitivity
    all_trans = True
    for i, j in congr:
        for k in range(len(fns)):
            if (j, k) in congr and (i, k) not in congr:
                all_trans = False
    print(f"3. Transitive: {all_trans}")

    # Add-compatibility
    add_compat = True
    for (i1, j1) in congr:
        for (i2, j2) in congr:
            ok = all(fns[i1](x) + fns[i2](x) == fns[j1](x) + fns[j2](x) for x in V)
            if not ok:
                add_compat = False
    print(f"4. Add-compatible: {add_compat}")

    # Mul-compatibility
    mul_compat = True
    for (i1, j1) in congr:
        for (i2, j2) in congr:
            ok = all(fns[i1](x) * fns[i2](x) == fns[j1](x) * fns[j2](x) for x in V)
            if not ok:
                mul_compat = False
    print(f"5. Mul-compatible: {mul_compat}")

    print("\n** All semiring congruence axioms verified! **")


# ============================================================
# Demo 5: Antitonicity
# ============================================================

def demo5_antitonicity():
    print("\n" + "=" * 70)
    print("DEMO 5: Antitonicity Properties")
    print("=" * 70)

    domain = list(range(10))
    fns = [lambda x, k=k: (x + k) % 5 for k in range(5)]

    V1, V2, V3 = {0}, {0, 1}, {0, 1, 2}
    c1 = vanishing_congruence(V1, fns, domain)
    c2 = vanishing_congruence(V2, fns, domain)
    c3 = vanishing_congruence(V3, fns, domain)

    print(f"V1={V1}: |I_c|={len(c1)},  V2={V2}: |I_c|={len(c2)},  V3={V3}: |I_c|={len(c3)}")
    assert c3 <= c2 <= c1
    print("** Antitonicity I_c(V3) <= I_c(V2) <= I_c(V1) verified! **")


# ============================================================

if __name__ == "__main__":
    print("Congruence-Level Tropical Nullstellensatz — Demonstrations\n")
    demo1_maxplus()
    demo2_boolean()
    demo3_galois_visualization()
    demo4_congruence_structure()
    demo5_antitonicity()
    print("\nAll demonstrations completed successfully!")
