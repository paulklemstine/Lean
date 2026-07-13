"""Isomorphisms of Meaning: When Structures Collide — numerical demonstrations.

This self-contained script illustrates the truth/meaning dichotomy in two
registers:

  1. The symmetric group of a finite set. An equivalence (relabeling) `e`
     induces the "isomorphism of isomorphisms" Phi_e acting by conjugation on
     permutations. We verify it is functorial and that it transports every
     relabeling-invariant quantity (order, sign, support size, cycle type)
     unchanged -- these are the *truths*. We then exhibit two permutations of a
     three-point set agreeing on all of these invariants yet acting on
     different points -- a *meaning* collision.

  2. The divisibility monoid. A strong divisibility sequence satisfies
     gcd(u_m, u_n) = u_{gcd(m,n)}. The Fibonacci sequence and the Mersenne
     sequence 2^n - 1 are both strong divisibility sequences (the *truth*) yet
     are distinct functions taking different values (the *meaning*), and both
     obey the same divisibility implication m | n  ==>  u_m | u_n.

Everything is inlined; run `python demo.py`.
"""

from __future__ import annotations

from itertools import permutations
from math import gcd
from typing import Dict, List, Tuple

# ---------------------------------------------------------------------------
# Permutations as dictionaries  point -> image  on a finite domain.
# ---------------------------------------------------------------------------

Perm = Dict[int, int]


def identity(domain: Tuple[int, ...]) -> Perm:
    """Identity permutation on `domain`."""
    return {x: x for x in domain}


def compose(f: Perm, g: Perm) -> Perm:
    """(f . g)(x) = f(g(x))."""
    return {x: f[g[x]] for x in g}


def inverse(f: Perm) -> Perm:
    """Inverse permutation."""
    return {y: x for x, y in f.items()}


def transposition(domain: Tuple[int, ...], a: int, b: int) -> Perm:
    """The transposition swapping a and b, fixing everything else."""
    p = identity(domain)
    p[a], p[b] = b, a
    return p


def phi(e: Perm, f: Perm) -> Perm:
    """The isomorphism of isomorphisms: Phi_e(f) = e . f . e^{-1}.

    `e` is an equivalence (relabeling) from its domain onto its image;
    `f` is a permutation of the domain of `e`.  The result is a permutation of
    the image of `e`.
    """
    e_inv = inverse(e)
    return {y: e[f[e_inv[y]]] for y in e.values()}


# ---------------------------------------------------------------------------
# The four "truths": relabeling-invariant quantities of a permutation.
# ---------------------------------------------------------------------------

def order(f: Perm) -> int:
    """Least k >= 1 with f^k = identity."""
    dom = tuple(f.keys())
    cur = dict(f)
    k = 1
    ident = identity(dom)
    while cur != ident:
        cur = compose(f, cur)
        k += 1
    return k


def support(f: Perm) -> frozenset:
    """Set of points actually moved by f."""
    return frozenset(x for x in f if f[x] != x)


def sign(f: Perm) -> int:
    """Sign (+1 even, -1 odd) via the parity of the number of inversions of the
    disjoint-cycle structure: sign = (-1)^(n - number_of_cycles)."""
    seen = set()
    cycles = 0
    for start in f:
        if start in seen:
            continue
        cycles += 1
        x = start
        while x not in seen:
            seen.add(x)
            x = f[x]
    n = len(f)
    return 1 if (n - cycles) % 2 == 0 else -1


def cycle_type(f: Perm) -> Tuple[int, ...]:
    """Multiset of lengths of cycles of length >= 2, sorted descending."""
    seen = set()
    lengths: List[int] = []
    for start in f:
        if start in seen:
            continue
        length = 0
        x = start
        while x not in seen:
            seen.add(x)
            x = f[x]
            length += 1
        if length >= 2:
            lengths.append(length)
    return tuple(sorted(lengths, reverse=True))


# ---------------------------------------------------------------------------
# Demonstration 1: functoriality of the isomorphism of isomorphisms.
# ---------------------------------------------------------------------------

def demo_functoriality() -> None:
    print("=" * 70)
    print("1. Functoriality of the isomorphism of isomorphisms")
    print("   Phi_{e'.e}(f) = Phi_{e'}(Phi_e(f))")
    print("=" * 70)
    dom = (0, 1, 2, 3)
    # e relabels {0,1,2,3} -> {10,11,12,13}; e' relabels those -> {20,21,22,23}
    e: Perm = {0: 10, 1: 11, 2: 12, 3: 13}
    ep: Perm = {10: 20, 11: 22, 12: 21, 13: 23}  # a nontrivial relabeling
    ee = {x: ep[e[x]] for x in e}  # e' . e
    ok = True
    for f in all_perms(dom):
        lhs = phi(ee, f)
        rhs = phi(ep, phi(e, f))
        if lhs != rhs:
            ok = False
    print(f"   Checked all {len(list(all_perms(dom)))} permutations of {dom}.")
    print(f"   Functoriality holds for every one: {ok}")
    print()


def all_perms(domain: Tuple[int, ...]) -> List[Perm]:
    return [dict(zip(domain, img)) for img in permutations(domain)]


# ---------------------------------------------------------------------------
# Demonstration 2: truths are transported unchanged.
# ---------------------------------------------------------------------------

def demo_truth_transport() -> None:
    print("=" * 70)
    print("2. Truth is preserved: Phi_e leaves order, sign, cycle type, and")
    print("   support size unchanged (support itself is relabeled).")
    print("=" * 70)
    dom = (0, 1, 2, 3)
    e: Perm = {0: "a", 1: "b", 2: "c", 3: "d"}  # relabel to letters
    print(f"   Relabeling e = {e}")
    all_ok = True
    for f in all_perms(dom):
        pf = phi(e, f)
        checks = [
            order(pf) == order(f),
            sign(pf) == sign(f),
            cycle_type(pf) == cycle_type(f),
            len(support(pf)) == len(support(f)),
            support(pf) == frozenset(e[x] for x in support(f)),  # supp relabeled
        ]
        all_ok = all_ok and all(checks)
    print(f"   Every permutation's truths survive relabeling: {all_ok}")
    # Show one example in detail.
    f = transposition(dom, 0, 1)
    pf = phi(e, f)
    print(f"   Example  f = (0 1):  order={order(f)}, sign={sign(f)}, "
          f"cycle_type={cycle_type(f)}, support={set(support(f))}")
    print(f"   Phi_e(f)         :  order={order(pf)}, sign={sign(pf)}, "
          f"cycle_type={cycle_type(pf)}, support={set(support(pf))}")
    print("   -> all invariants equal; only the concrete support was relabeled.")
    print()


# ---------------------------------------------------------------------------
# Demonstration 3: the three-point collision.
# ---------------------------------------------------------------------------

def demo_collision() -> None:
    print("=" * 70)
    print("3. Meaning collision on three points {0,1,2}:")
    print("   (0 1) and (1 2) agree on EVERY invariant yet differ.")
    print("=" * 70)
    dom = (0, 1, 2)
    f = transposition(dom, 0, 1)
    g = transposition(dom, 1, 2)
    print(f"   f = (0 1):  cycle_type={cycle_type(f)}, order={order(f)}, "
          f"sign={sign(f)}, support={set(support(f))}")
    print(f"   g = (1 2):  cycle_type={cycle_type(g)}, order={order(g)}, "
          f"sign={sign(g)}, support={set(support(g))}")
    same_invariants = (
        cycle_type(f) == cycle_type(g)
        and order(f) == order(g)
        and sign(f) == sign(g)
    )
    print(f"   Same cycle type, order, sign : {same_invariants}")
    print(f"   But f != g                   : {f != g}")
    print(f"   And supports differ          : {support(f) != support(g)}")
    print("   -> No structural invariant separates them; only the labels do.")
    print()


# ---------------------------------------------------------------------------
# Demonstration 4: colliding strong divisibility sequences.
# ---------------------------------------------------------------------------

def fib(n: int) -> int:
    """Fibonacci with fib(0)=0, fib(1)=1, fib(2)=1, ..."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(n: int) -> int:
    """The Mersenne sequence u_n = 2^n - 1."""
    return 2 ** n - 1


def is_strong_divisibility(u, upto: int = 20) -> bool:
    """Check gcd(u_m, u_n) = u_{gcd(m,n)} for 1 <= m, n <= upto."""
    for m in range(1, upto + 1):
        for n in range(1, upto + 1):
            if gcd(u(m), u(n)) != u(gcd(m, n)):
                return False
    return True


def demo_arithmetic_collision() -> None:
    print("=" * 70)
    print("4. Arithmetic collision: Fibonacci vs Mersenne 2^n - 1.")
    print("   Same structural law (strong divisibility), different values.")
    print("=" * 70)
    print(f"   Fibonacci is a strong divisibility sequence : "
          f"{is_strong_divisibility(fib)}")
    print(f"   Mersenne  is a strong divisibility sequence : "
          f"{is_strong_divisibility(mersenne)}")
    print(f"   fib(3) = {fib(3)},  2^3 - 1 = {mersenne(3)}  ->  functions differ")
    print()
    print("   Shared divisibility law  m | n  =>  u_m | u_n :")
    header = f"   {'m|n':>7} | {'fib(m)|fib(n)':>15} | {'(2^m-1)|(2^n-1)':>17}"
    print(header)
    print("   " + "-" * (len(header) - 3))
    for m, n in [(3, 6), (4, 8), (5, 10), (6, 12)]:
        fib_ok = fib(n) % fib(m) == 0
        mer_ok = mersenne(n) % mersenne(m) == 0
        print(f"   {f'{m}|{n}':>7} | {str(fib_ok):>15} | {str(mer_ok):>17}")
    print()


def main() -> None:
    demo_functoriality()
    demo_truth_transport()
    demo_collision()
    demo_arithmetic_collision()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
