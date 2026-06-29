"""
Divisibility Bridges --- numerical demonstrations.

Self-contained Python demonstrations of the three formally verified results:

  1. Fibonacci divisibility equivalence  (fib_dvd_iff):
         for m >= 3,  F_m | F_n  <=>  m | n.
  2. Sharp divisibility pigeonhole       (divisibility_pigeonhole):
         any (n+1)-subset of [1, 2n] contains a divisibility pair,
         extracted constructively via the odd-part coloring.
  3. Finite Garden-of-Eden / descent     (finite_garden_of_eden_descent,
                                           exists_garden_of_eden_iff_not_surjective):
         monotone descending maps on a finite poset stabilize within |P| steps;
         non-surjective maps possess Garden-of-Eden states.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Core arithmetic helpers (inlined, no external dependencies)
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number with F_0 = 0, F_1 = 1, F_2 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def odd_part(x: int) -> int:
    """oddPart(x) = x / 2^{v_2(x)}: divide out every factor of two."""
    if x == 0:
        return 0
    while x % 2 == 0:
        x //= 2
    return x


def two_adic_val(x: int) -> int:
    """v_2(x): the exponent of 2 in the factorization of x."""
    v = 0
    while x % 2 == 0 and x > 0:
        x //= 2
        v += 1
    return v


# --------------------------------------------------------------------------- #
# Demo 1: Fibonacci divisibility equivalence  (Theorem fib_dvd_iff)
# --------------------------------------------------------------------------- #
def demo_fibonacci_divisibility_equivalence(max_m: int = 12, max_n: int = 60) -> None:
    """Verify  F_m | F_n  <=>  m | n  for all 3 <= m <= max_m, m <= n <= max_n."""
    print("=" * 70)
    print("DEMO 1: Fibonacci divisibility equivalence (fib_dvd_iff)")
    print("        For m >= 3:  F_m | F_n  <=>  m | n")
    print("=" * 70)

    failures = 0
    for m in range(3, max_m + 1):
        Fm = fib(m)
        for n in range(m, max_n + 1):
            Fn = fib(n)
            value_side = (Fn % Fm == 0)   # F_m | F_n
            index_side = (n % m == 0)     # m | n
            if value_side != index_side:
                failures += 1
                print(f"  COUNTEREXAMPLE m={m}, n={n}")

    print(f"  Checked all pairs 3<=m<={max_m}, m<=n<={max_n}: "
          f"{'ALL CONSISTENT' if failures == 0 else f'{failures} FAILURES'}")

    # Concrete illustration: divisors of 12 vs. Fibonacci divisors of F_12.
    n = 12
    Fn = fib(n)
    fib_divisor_indices = [m for m in range(3, n + 1) if Fn % fib(m) == 0]
    index_divisors = [m for m in range(3, n + 1) if n % m == 0]
    print(f"\n  F_{n} = {Fn}")
    print(f"  indices m in [3,{n}] with F_m | F_{n}: {fib_divisor_indices}")
    print(f"  indices m in [3,{n}] with m | {n}     : {index_divisors}")
    print(f"  match: {fib_divisor_indices == index_divisors}")

    # Show the m=1,2 degeneracy that forces the m>=3 hypothesis.
    print(f"\n  Degenerate low indices: F_1={fib(1)}, F_2={fib(2)} divide every F_n,")
    print(f"  so the equivalence genuinely requires m >= 3.")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: Constructive divisibility pigeonhole  (Theorem divisibility_pigeonhole)
# --------------------------------------------------------------------------- #
def find_divisibility_pair(subset: List[int]) -> Optional[Tuple[int, int]]:
    """Return (a, b) in `subset` with a != b and a | b, via the odd-part coloring.

    Guaranteed to succeed when |subset| = n+1 and subset subseteq [1, 2n].
    """
    seen: Dict[int, int] = {}  # odd part -> a representative element
    for x in subset:
        q = odd_part(x)
        if q in seen:
            y = seen[q]
            a, b = (y, x) if two_adic_val(y) <= two_adic_val(x) else (x, y)
            return (a, b)  # a | b because they share the odd part q
        seen[q] = x
    return None


def demo_divisibility_pigeonhole(n: int = 6) -> None:
    """Exhaustively confirm that every (n+1)-subset of [1, 2n] has a divisibility
    pair, and that the extremal n-subset {n+1, ..., 2n} has none (sharpness)."""
    print("=" * 70)
    print("DEMO 2: Sharp divisibility pigeonhole (divisibility_pigeonhole)")
    print(f"        Every (n+1)-subset of [1, 2n] has a divisibility pair (n={n})")
    print("=" * 70)

    universe = list(range(1, 2 * n + 1))
    total = 0
    found_all = True
    for subset in combinations(universe, n + 1):
        total += 1
        pair = find_divisibility_pair(list(subset))
        if pair is None:
            found_all = False
            print(f"  COUNTEREXAMPLE: no divisibility pair in {subset}")
    print(f"  Tested all C(2n, n+1) = {total} subsets of size {n+1}.")
    print(f"  Divisibility pair found in EVERY subset: {found_all}")

    # Sample witnesses.
    print("\n  Sample witnesses (a | b) from a few subsets:")
    shown = 0
    for subset in combinations(universe, n + 1):
        pair = find_divisibility_pair(list(subset))
        if pair:
            a, b = pair
            print(f"    subset {subset}:  {a} | {b}")
            shown += 1
        if shown >= 4:
            break

    # Sharpness: extremal n-subset {n+1, ..., 2n} has no divisibility pair.
    extremal = list(range(n + 1, 2 * n + 1))
    has_pair = any(b % a == 0 for a, b in combinations(extremal, 2))
    print(f"\n  Sharpness check: extremal {n}-subset {tuple(extremal)}")
    print(f"    contains a divisibility pair: {has_pair}  (expected False)")
    print(f"    => the threshold n+1 = {n+1} is optimal.")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: Finite Garden-of-Eden / descent stabilization
#         (finite_garden_of_eden_descent, exists_garden_of_eden_iff_not_surjective)
# --------------------------------------------------------------------------- #
def is_garden_of_eden(F: Callable[[int], int], domain: List[int], y: int) -> bool:
    """y is a Garden of Eden for F if no x in domain maps to y."""
    return all(F(x) != y for x in domain)


def stabilize(F: Callable[[int], int], x: int, N: int) -> Tuple[int, int]:
    """Iterate F from x until a fixed point; returns (steps, fixed_point).

    For a monotone descending map on a poset of size N, terminates within N steps.
    """
    cur = x
    for n in range(N + 1):
        nxt = F(cur)
        if nxt == cur:
            return (n, cur)
        cur = nxt
    raise RuntimeError("did not stabilize within N steps (violates the theorem)")


def demo_garden_of_eden_descent(N: int = 8) -> None:
    """Demonstrate descent stabilization within |P| steps and the Garden-of-Eden
    dichotomy on the finite linearly ordered poset P = {0, 1, ..., N-1}."""
    print("=" * 70)
    print("DEMO 3: Finite descent + Garden of Eden")
    print("        (finite_garden_of_eden_descent,")
    print("         exists_garden_of_eden_iff_not_surjective)")
    print("=" * 70)

    domain = list(range(N))

    # A monotone, descending map on the chain 0 < 1 < ... < N-1:
    #   F(x) = max(x - 1, 0).  Then F(x) <= x and F is monotone.
    def F(x: int) -> int:
        return max(x - 1, 0)

    print(f"  Poset P = {domain}  (|P| = {N})")
    print(f"  Map F(x) = max(x-1, 0):  monotone and descending (F(x) <= x).")
    print("\n  Orbit stabilization (must finish within |P| =", N, "steps):")
    worst = 0
    for x in domain:
        steps, fp = stabilize(F, x, N)
        worst = max(worst, steps)
        print(f"    start {x}: reached fixed point {fp} in {steps} steps")
    print(f"  Worst-case steps observed: {worst}  (<= |P| = {N}:"
          f" {worst <= N})")

    # Garden-of-Eden dichotomy.
    image = sorted({F(x) for x in domain})
    surjective = (image == domain)
    goe_states = [y for y in domain if is_garden_of_eden(F, domain, y)]
    print(f"\n  Image of F: {image}")
    print(f"  F surjective on P: {surjective}")
    print(f"  Garden-of-Eden states (no preimage): {goe_states}")
    print(f"  exists GoE  <=>  not surjective:"
          f" {(len(goe_states) > 0) == (not surjective)}  (theorem holds)")

    # Contrast with a bijection (the identity): surjective => no Garden of Eden,
    # and (finite Moore-Myhill shadow) surjective => injective.
    def G(x: int) -> int:
        return x  # identity: monotone, descending (G(x) <= x), and bijective

    g_image = sorted({G(x) for x in domain})
    g_surj = (g_image == domain)
    g_goe = [y for y in domain if is_garden_of_eden(G, domain, y)]
    g_inj = (len({G(x) for x in domain}) == len(domain))
    print(f"\n  Identity map G(x)=x:  surjective={g_surj}, "
          f"GoE states={g_goe}, injective={g_inj}")
    print(f"  Finite Moore-Myhill shadow (surjective => injective):"
          f" {(not g_surj) or g_inj}")
    print()


# --------------------------------------------------------------------------- #
def main() -> None:
    demo_fibonacci_divisibility_equivalence()
    demo_divisibility_pigeonhole()
    demo_garden_of_eden_descent()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()


"""
Visualization: odd-part divisibility chains on [1, 2n] and the pigeonhole.

Renders [1, 2n] partitioned into the n chains  q * 2^k  (q odd), the structure
that powers `divisibility_pigeonhole`. Each chain is a column; choosing n+1
numbers must repeat a column (a divisibility pair). Requires matplotlib.
"""

from __future__ import annotations

from typing import Dict, List

import matplotlib.pyplot as plt


def odd_part(x: int) -> int:
    while x % 2 == 0:
        x //= 2
    return x


def make_figure(n: int = 8, out_path: str = "divisibility_chains.png") -> None:
    chains: Dict[int, List[int]] = {}
    for x in range(1, 2 * n + 1):
        chains.setdefault(odd_part(x), []).append(x)

    odds = sorted(chains)  # exactly n of them: 1, 3, ..., 2n-1
    fig, ax = plt.subplots(figsize=(1.1 * len(odds) + 2, 6))

    for col, q in enumerate(odds):
        members = chains[q]
        for row, val in enumerate(members):
            ax.scatter(col, row, s=900, color="#3b6db5", zorder=2)
            ax.text(col, row, str(val), ha="center", va="center",
                    color="white", fontsize=11, fontweight="bold", zorder=3)
        ys = list(range(len(members)))
        ax.plot([col] * len(members), ys, color="#9bb8e0", lw=2, zorder=1)

    ax.set_xticks(range(len(odds)))
    ax.set_xticklabels([f"odd part {q}" for q in odds], rotation=30, ha="right")
    ax.set_yticks([])
    ax.set_title(f"[1, {2*n}] split into {len(odds)} divisibility chains\n"
                 f"(any {n+1} numbers must repeat a column => a divisibility pair)")
    ax.set_xlim(-0.7, len(odds) - 0.3)
    ax.margins(y=0.15)
    fig.tight_layout()
    fig.savefig(out_path, dpi=130)
    print(f"wrote {out_path}")


if __name__ == "__main__":
    make_figure()
