"""
Quantum Pythagorean Walk — numerical companion.

A self-contained demonstration of the resonance mechanism on the Berggren ternary
tree of primitive Pythagorean triples:

  * the tree structure and its two-sided growth law  (c + 8 <= c' <= 7c),
  * completeness: words <-> primitive triples with odd first leg, 3^n per layer,
  * resonance: words whose hypotenuse is divisible by a target N,
  * collapse: two resonant nodes give a congruence of squares and hence a factor,
  * multiplicity: exactly 1 resonant word for a prime power, exactly 2 for a
    semiprime, 2^{omega(N)-1} in general,
  * the kinematic barrier: any resonant depth n satisfies 3^n >= sqrt(N/5),
  * the interference bound |A(psi)|^2 <= |R| * ||psi||^2 and its rigidity.

Pure standard library (plus `random` and `cmath`).  Run with:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
import random
from itertools import product
from math import gcd
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

Triple = Tuple[int, int, int]

# --------------------------------------------------------------------------- #
# 1.  The Berggren tree                                                        #
# --------------------------------------------------------------------------- #

ROOT: Triple = (3, 4, 5)


def step_a(t: Triple) -> Triple:
    """Berggren branch A."""
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def step_b(t: Triple) -> Triple:
    """Berggren branch B."""
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def step_c(t: Triple) -> Triple:
    """Berggren branch C."""
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


BRANCHES = (step_a, step_b, step_c)


def walk(word: Sequence[int]) -> Triple:
    """Node reached from the root by the coin history `word` (read right to left)."""
    t = ROOT
    for i in reversed(list(word)):
        t = BRANCHES[i](t)
    return t


def is_ppt(t: Triple) -> bool:
    """Is `t` a primitive Pythagorean triple with positive entries?"""
    a, b, c = t
    return a > 0 and b > 0 and c > 0 and a * a + b * b == c * c and gcd(a, b) == 1


# --------------------------------------------------------------------------- #
# 2.  Enumerating the tree up to a hypotenuse bound                            #
# --------------------------------------------------------------------------- #


def enumerate_tree(bound: int) -> Dict[Triple, List[int]]:
    """All nodes with hypotenuse <= `bound`, together with one word reaching each.

    Correct because every branch strictly increases the hypotenuse, so the search
    may be pruned as soon as the bound is exceeded.  Cost is linear in the number
    of nodes returned.
    """
    found: Dict[Triple, List[int]] = {ROOT: []}
    frontier: List[Tuple[Triple, List[int]]] = [(ROOT, [])]
    while frontier:
        new_frontier: List[Tuple[Triple, List[int]]] = []
        for node, word in frontier:
            for i, br in enumerate(BRANCHES):
                child = br(node)
                if child[2] <= bound:
                    child_word = [i] + word
                    found[child] = child_word
                    new_frontier.append((child, child_word))
        frontier = new_frontier
    return found


def resonant_words(N: int) -> List[Tuple[List[int], Triple]]:
    """All words whose node has hypotenuse exactly `N`, sorted by word length."""
    out = [(w, t) for t, w in enumerate_tree(N).items() if t[2] == N]
    out.sort(key=lambda pair: (len(pair[0]), pair[0]))
    return out


# --------------------------------------------------------------------------- #
# 3.  Collapse: a resonant pair yields a factor                                #
# --------------------------------------------------------------------------- #


def interference_gcd(t1: Triple, t2: Triple, N: int) -> int:
    """gcd(a1*a2 - b1*b2, N): the factor produced by an interfering resonant pair."""
    a1, b1, _ = t1
    a2, b2, _ = t2
    return gcd(a1 * a2 - b1 * b2, N)


def collapse(N: int) -> Optional[Tuple[List[int], List[int], int]]:
    """Try to split `N` by interference of two resonant nodes of hypotenuse `N`."""
    res = resonant_words(N)
    for i in range(len(res)):
        for j in range(i + 1, len(res)):
            g = interference_gcd(res[i][1], res[j][1], N)
            if 1 < g < N:
                return res[i][0], res[j][0], g
    return None


def omega(n: int) -> int:
    """Number of distinct prime factors of `n`."""
    count, m, p = 0, n, 2
    while p * p <= m:
        if m % p == 0:
            count += 1
            while m % p == 0:
                m //= p
        p += 1
    return count + (1 if m > 1 else 0)


# --------------------------------------------------------------------------- #
# 4.  The barrier and the interference bound                                   #
# --------------------------------------------------------------------------- #


def resonance_set(N: int, n: int) -> List[Tuple[int, ...]]:
    """Depth-n coin histories whose endpoint has hypotenuse divisible by N."""
    return [w for w in product(range(3), repeat=n) if walk(w)[2] % N == 0]


def resonance_amplitude(psi: Dict[Tuple[int, ...], complex],
                        support: Iterable[Tuple[int, ...]]) -> complex:
    """Coherent amplitude A(psi) = sum over the resonance set."""
    return sum(psi[w] for w in support)


def total_intensity(psi: Dict[Tuple[int, ...], complex]) -> float:
    return sum(abs(z) ** 2 for z in psi.values())


# --------------------------------------------------------------------------- #
# 5.  Demonstrations                                                           #
# --------------------------------------------------------------------------- #


def demo_tree() -> None:
    print("=" * 72)
    print("1.  The Berggren tree: structure, growth, completeness")
    print("=" * 72)
    print(f"root = {ROOT}")
    for word in ([0], [1], [2], [0, 2], [2, 2, 2], [1, 0, 0, 0, 0]):
        t = walk(word)
        print(f"  word {str(word):<16} -> {str(t):<20} primitive: {is_ppt(t)}")

    print("\n  growth law  c + 8 <= c' <= 7c  on all nodes with c <= 2000:")
    ok_low = ok_high = True
    for t in enumerate_tree(2000):
        for br in BRANCHES:
            child = br(t)
            ok_low &= child[2] >= t[2] + 8
            ok_high &= child[2] <= 7 * t[2]
    print(f"    lower bound (+8 per step)      : {ok_low}")
    print(f"    upper bound (factor 7 per step): {ok_high}")

    print("\n  layer sizes (all words of length n give distinct triples):")
    for n in range(6):
        layer = {walk(w) for w in product(range(3), repeat=n)}
        print(f"    n = {n}:  |layer| = {len(layer):>4}   3^n = {3 ** n:>4}")

    print("\n  slow branch A^n(root) = (2n+3, 2n^2+6n+4, 2n^2+6n+5):")
    t = ROOT
    for n in range(6):
        assert t == (2 * n + 3, 2 * n ** 2 + 6 * n + 4, 2 * n ** 2 + 6 * n + 5)
        print(f"    n = {n}:  {t}")
        t = step_a(t)

    print("\n  completeness check: every primitive triple with odd first leg and")
    print("  hypotenuse <= 500 is reached by exactly one word.")
    reached = enumerate_tree(500)
    brute = set()
    for m in range(2, 30):
        for k in range(1, m):
            if (m - k) % 2 == 1 and gcd(m, k) == 1:
                a, b, c = m * m - k * k, 2 * m * k, m * m + k * k
                if c <= 500:
                    brute.add((a, b, c) if a % 2 == 1 else (b, a, c))
    print(f"    triples found by the walk : {len(reached)}")
    print(f"    triples found by Euclid   : {len(brute)}")
    print(f"    identical sets            : {set(reached) == brute}")


def demo_resonance_and_collapse() -> None:
    print()
    print("=" * 72)
    print("2.  Resonance and collapse: interference returns a factor")
    print("=" * 72)
    for N in (65, 325, 625, 1105, 4225, 32045):
        res = resonant_words(N)
        print(f"\n  N = {N}   (omega = {omega(N)}, predicted multiplicity "
              f"2^(omega-1) = {2 ** (omega(N) - 1)})")
        for w, t in res:
            print(f"    word {str(w):<20} node {t}")
        print(f"    number of resonant words : {len(res)}")
        out = collapse(N)
        if out is None:
            print("    only one resonant word: no interference pair, nothing to split")
        else:
            w1, w2, g = out
            t1, t2 = walk(w1), walk(w2)
            a1, b1, _ = t1
            a2, b2, _ = t2
            print(f"    congruence of squares    : ({a1 * a2})^2 = ({b1 * b2})^2 mod {N}"
                  f"   [check: {(a1 * a2) ** 2 % N == (b1 * b2) ** 2 % N}]")
            print(f"    gcd(a1a2 - b1b2, N)      = {g}    -> {N} = {g} * {N // g}")


def demo_multiplicity() -> None:
    print()
    print("=" * 72)
    print("3.  Resonance multiplicity is an arithmetic invariant")
    print("=" * 72)
    print("   N        omega(N)   #resonant words   2^(omega-1)   verdict")
    targets = [5, 13, 17, 25, 29, 65, 85, 125, 145, 169, 289, 325, 425, 1105, 4225]
    for N in targets:
        res = resonant_words(N)
        pred = 2 ** (omega(N) - 1)
        verdict = "prime power" if len(res) == 1 else "composite, splits"
        flag = "ok" if len(res) == pred else "MISMATCH"
        print(f"  {N:>6}     {omega(N):>3}          {len(res):>4}"
              f"             {pred:>4}       {verdict} ({flag})")
    print("\n  Unique resonance <=> prime power; multiplicity 2 <=> semiprime.")


def demo_barrier() -> None:
    print()
    print("=" * 72)
    print("4.  The kinematic barrier: 3^n >= sqrt(N/5) at any resonant depth")
    print("=" * 72)
    print("   N        min resonant depth n   3^n        sqrt(N/5)   log_7(N/5)")
    for N in (65, 325, 1105, 4225, 32045):
        res = resonant_words(N)
        n = min(len(w) for w, _ in res)
        print(f"  {N:>8}         {n:>3}          {3 ** n:>10}   "
              f"{math.sqrt(N / 5):>10.1f}   {math.log(N / 5, 7):>8.2f}")
    print("\n  The depth-n layer already holds 3^n >= sqrt(N/5) branches, i.e. the")
    print("  search space at the first resonant depth is exponential in log N.")
    print("  Even a quadratic (Grover-type) speed-up over one layer costs N^(1/4).")


def demo_interference_bound() -> None:
    print()
    print("=" * 72)
    print("5.  The coin-independent interference bound and its rigidity")
    print("=" * 72)
    N, n = 65, 6
    R = resonance_set(N, n)
    histories = list(product(range(3), repeat=n))
    print(f"  N = {N}, depth n = {n}: |R| = {len(R)} resonant histories out of {3 ** n}")

    random.seed(2024)
    worst = 0.0
    for _ in range(5000):
        psi = {w: complex(random.gauss(0, 1), random.gauss(0, 1)) for w in histories}
        norm = math.sqrt(total_intensity(psi))
        psi = {w: z / norm for w, z in psi.items()}
        gain = abs(resonance_amplitude(psi, R)) ** 2
        worst = max(worst, gain)
    print(f"  best gain over 5000 random normalised states : {worst:.6f}")
    print(f"  proved upper bound |R|                        : {len(R)}")

    # The indicator state saturates the bound.
    amp = 1 / math.sqrt(len(R)) if R else 0.0
    ind = {w: complex(amp, 0.0) if w in set(R) else 0j for w in histories}
    print(f"  gain of the resonance-indicator state          : "
          f"{abs(resonance_amplitude(ind, R)) ** 2:.6f}")

    # A phase-perturbed indicator strictly loses.
    perturbed = dict(ind)
    if R:
        perturbed[R[0]] = ind[R[0]] * cmath.exp(1j * 0.4)
    print(f"  gain after rotating one resonant amplitude     : "
          f"{abs(resonance_amplitude(perturbed, R)) ** 2:.6f}")
    print("\n  Equality holds exactly for scalar multiples of the resonance")
    print("  indicator: preparing the optimal state already requires knowing R.")


def demo_shallow_vanishing() -> None:
    print()
    print("=" * 72)
    print("6.  Below the critical depth every state has zero resonance amplitude")
    print("=" * 72)
    N = 1105
    for n in range(0, 5):
        empty = (5 * 7 ** n < N)
        R = resonance_set(N, n)
        print(f"  n = {n}:  5*7^n = {5 * 7 ** n:>7}   "
              f"critical-depth test says empty: {str(empty):<5}   |R| = {len(R)}")
    print("\n  No coin - uniform, biased, adaptive or entangling - can create")
    print("  amplitude on an empty set: the obstruction is kinematic.")


def main() -> None:
    demo_tree()
    demo_resonance_and_collapse()
    demo_multiplicity()
    demo_barrier()
    demo_interference_bound()
    demo_shallow_vanishing()
    print()
    print("=" * 72)
    print("Summary: the arithmetic always cooperates (every admissible non-prime-")
    print("power target splits exactly), the search space never does (the first")
    print("resonant layer already has sqrt(N/5) branches).")
    print("=" * 72)


if __name__ == "__main__":
    main()
