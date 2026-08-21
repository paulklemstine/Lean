"""
The Berggren Causal Set — numerical demonstration.
==================================================

Self-contained numerical exploration of the tree of primitive Pythagorean triples
viewed as a discrete structure on the null cone of 2+1-dimensional Minkowski space.

Every triple (a, b, c) with a^2 + b^2 = c^2 is a null vector of the Lorentz form

    Q(x, y, t) = x^2 + y^2 - t^2 .

Berggren's three integer matrices A, B, C generate all primitive triples from
(3, 4, 5), each exactly once, and each matrix preserves Q exactly, i.e. lies in
O(2,1;Z).

The demo verifies, numerically:

  1. Closure and null-cone membership; the three children of any event.
  2. The Lorentz property  M^T diag(1,1,-1) M = diag(1,1,-1)  and det = +1,-1,+1.
  3. The unique-parent property: one map P, read by its sign pattern, inverts all
     three branches, so every event has a unique address word.
  4. Level sizes are exactly 3^k, and levels are antichains.
  5. Causal intervals are chains with exactly k+1 elements (so the effective
     dimension is 1, not 2+1).
  6. Every pair of distinct events is SPACELIKE separated: Q(u - t) > 0.
     Hence tree edges are never causal relations of Minkowski space.
  7. Exact edge lengths 4(c-b)^2, 4(a-b)^2, 4(c-a)^2.
  8. The Pell spine: uniform step length 4, hypotenuse recurrence
     c_{k+2} = 6 c_{k+1} - c_k, growth rate (1+sqrt 2)^2 = 3 + 2 sqrt 2, and
     celestial directions converging to the irrational point sqrt(2)/2.

Run with:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, sqrt
from typing import Dict, Iterable, List, Tuple

Triple = Tuple[int, int, int]

# --------------------------------------------------------------------------- #
# 1. The three Berggren moves
# --------------------------------------------------------------------------- #

MATRICES: Dict[str, Tuple[Tuple[int, int, int], ...]] = {
    "A": ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    "B": ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    "C": ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}
MOVES: Tuple[str, str, str] = ("A", "B", "C")
ROOT: Triple = (3, 4, 5)


def apply_move(move: str, t: Triple) -> Triple:
    """Apply one Berggren move to a triple."""
    m = MATRICES[move]
    return tuple(sum(m[i][j] * t[j] for j in range(3)) for i in range(3))  # type: ignore[return-value]


def run_word(word: str, t: Triple) -> Triple:
    """Apply a word of moves, leftmost letter first."""
    for s in word:
        t = apply_move(s, t)
    return t


def lorentz_q(t: Triple) -> int:
    """The Lorentz form Q(a,b,c) = a^2 + b^2 - c^2."""
    a, b, c = t
    return a * a + b * b - c * c


def mink(t: Triple, u: Triple) -> int:
    """Minkowski interval Q(u - t): >0 spacelike, <0 timelike, =0 null."""
    return lorentz_q((u[0] - t[0], u[1] - t[1], u[2] - t[2]))


def is_event(t: Triple) -> bool:
    a, b, c = t
    return a > 0 and b > 0 and c > 0 and a * a + b * b == c * c


def is_primitive_event(t: Triple) -> bool:
    return is_event(t) and gcd(t[0], t[1]) == 1


# --------------------------------------------------------------------------- #
# 2. The parent map and address decoding
# --------------------------------------------------------------------------- #

def parent_map(t: Triple) -> Triple:
    """P(a,b,c) = (a+2b-2c, 2a+b-2c, -2a-2b+3c).

    P(A v) = (a, -b, c);  P(B v) = (a, b, c);  P(C v) = (-a, b, c).
    """
    a, b, c = t
    return (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)


def parent_and_move(t: Triple) -> Tuple[Triple, str]:
    """Recover the unique parent and the move that produced `t`.

    Reads the sign pattern of P(t): a negative second entry means move A,
    a negative first entry means move C, all-positive means move B.
    """
    if t == ROOT:
        raise ValueError("the root has no parent")
    x, y, z = parent_map(t)
    if y < 0:
        return (x, -y, z), "A"
    if x < 0:
        return (-x, y, z), "C"
    return (x, y, z), "B"


def address(t: Triple) -> str:
    """The unique word of moves carrying the root to `t` (leftmost applied first)."""
    letters: List[str] = []
    while t != ROOT:
        t, s = parent_and_move(t)
        letters.append(s)
    return "".join(reversed(letters))


# --------------------------------------------------------------------------- #
# 3. Levels, intervals, ordering fraction
# --------------------------------------------------------------------------- #

def level(k: int, start: Triple = ROOT) -> List[Triple]:
    """All depth-k descendants of `start`."""
    frontier: List[Triple] = [start]
    for _ in range(k):
        frontier = [apply_move(s, t) for t in frontier for s in MOVES]
    return frontier


def causal_interval(t: Triple, word: str) -> List[Triple]:
    """The interval [t, word.t]: the prefixes of `word` applied to `t`."""
    out = [t]
    cur = t
    for s in word:
        cur = apply_move(s, cur)
        out.append(cur)
    return out


def is_causal(t: Triple, u: Triple) -> bool:
    """Decide whether `u` is a Berggren descendant of `t`, by address prefixes."""
    wt, wu = address(t), address(u)
    return wu.startswith(wt)


def ordering_fraction(chain: Iterable[Triple]) -> float:
    """Fraction of causally related pairs inside a set of events.

    For a faithful sprinkling into d-dimensional Minkowski space this tends to a
    constant strictly below 1 (many unrelated pairs); here it is identically 1.
    """
    events = list(chain)
    n = len(events)
    if n < 2:
        return 1.0
    related = sum(1 for i, x in enumerate(events) for y in events[i + 1:]
                  if is_causal(x, y) or is_causal(y, x))
    return related / (n * (n - 1) / 2)


# --------------------------------------------------------------------------- #
# 4. Reporting helpers
# --------------------------------------------------------------------------- #

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_children() -> None:
    rule("1.  The root and its three children; everything stays on the null cone")
    print(f"root r = {ROOT},  Q(r) = {lorentz_q(ROOT)}")
    for s in MOVES:
        child = apply_move(s, ROOT)
        print(f"  {s}·r = {str(child):>16}   Q = {lorentz_q(child):>2}   "
              f"primitive = {is_primitive_event(child)}")
    print("\nDepth-2 events (all nine, each obtained by exactly one word):")
    for s in MOVES:
        for s2 in MOVES:
            w = s + s2
            print(f"  {w}: {run_word(w, ROOT)}")


def demo_lorentz() -> None:
    rule("2.  Each move is an integral Lorentz transformation of signature (2,1)")
    q = ((1, 0, 0), (0, 1, 0), (0, 0, -1))

    def mat_mul(x, y):
        return tuple(tuple(sum(x[i][k] * y[k][j] for k in range(3)) for j in range(3))
                     for i in range(3))

    def transpose(x):
        return tuple(tuple(x[j][i] for j in range(3)) for i in range(3))

    def det(x):
        return (x[0][0] * (x[1][1] * x[2][2] - x[1][2] * x[2][1])
                - x[0][1] * (x[1][0] * x[2][2] - x[1][2] * x[2][0])
                + x[0][2] * (x[1][0] * x[2][1] - x[1][1] * x[2][0]))

    for s in MOVES:
        m = MATRICES[s]
        check = mat_mul(mat_mul(transpose(m), q), m)
        print(f"  {s}:  Mᵀ Q M = Q  ->  {check == q};   det M = {det(m):+d}")
    print("  (the middle move B is the orientation-reversing generator)")

    print("\n  A word's matrix is a Lorentz matrix too; det of a word = (-1)^(#B):")
    for w in ("", "A", "B", "AB", "BBB", "ABCBA"):
        v = run_word(w, ROOT)
        print(f"    word {w!r:>8}: image of root = {str(v):>22}, "
              f"#B = {w.count('B')}, sign = {(-1) ** w.count('B'):+d}, Q = {lorentz_q(v)}")


def demo_unique_parent() -> None:
    rule("3.  Unique-parent property: one map P inverts all three branches")
    a, b, c = 3, 4, 5
    for s in MOVES:
        child = apply_move(s, (a, b, c))
        print(f"  P({s}·(3,4,5)) = P({child}) = {parent_map(child)}")
    print("  sign patterns  (a,-b,c) / (a,b,c) / (-a,b,c)  identify the branch.")

    print("\n  Address decoding round-trip over all events of depth 5:")
    words = [""]
    frontier = [ROOT]
    ok = True
    for _ in range(5):
        new_words, new_frontier = [], []
        for w, t in zip(words, frontier):
            for s in MOVES:
                new_words.append(w + s)
                new_frontier.append(apply_move(s, t))
        words, frontier = new_words, new_frontier
        for w, t in zip(words, frontier):
            if address(t) != w:
                ok = False
    print(f"    decoded address == generating word for all {len(words)} depth-5 events: {ok}")
    print(f"    example: address({frontier[100]}) = {address(frontier[100])!r}")


def demo_levels() -> None:
    rule("4.  Level sizes are exactly 3^k, and levels are antichains")
    for k in range(7):
        lv = level(k)
        print(f"  depth {k}: {len(lv):>4} events, distinct = {len(set(lv)):>4}, "
              f"3^{k} = {3 ** k:>4}, all primitive = {all(map(is_primitive_event, lv))}")
    print("\n  Antichain check at depth 3: no event is a descendant of another.")
    lv3 = level(3)
    reachable = {t: {run_word(w, t) for L in range(1, 5)
                     for w in _all_words(L)} for t in lv3[:6]}
    bad = [(t, u) for t in reachable for u in lv3 if u in reachable[t]]
    print(f"    violating pairs found (sample of 6 sources, depth <= 4): {len(bad)}")


def _all_words(n: int) -> Iterable[str]:
    if n == 0:
        yield ""
        return
    for w in _all_words(n - 1):
        for s in MOVES:
            yield w + s


def demo_intervals() -> None:
    rule("5.  Causal intervals are chains with exactly k+1 events -> dimension 1")
    print("   k   |[r, B^k r]|   k+1   ordering fraction   (Myrheim–Meyer would need ~k^d)")
    for k in range(0, 9):
        word = "B" * k
        iv = causal_interval(ROOT, word)
        print(f"  {k:>2}      {len(iv):>4}       {k + 1:>3}          "
              f"{ordering_fraction(iv):.2f}")
    print("\n  A quadratic lower bound rho*k^2 <= |interval| fails for every rho > 0:")
    for rho in (1.0, 0.1, 0.01):
        k = int(2 / rho) + 2
        print(f"    rho = {rho:<5}: at k = {k}, rho*k^2 = {rho * k * k:.1f} > {k + 1} = |interval|")


def demo_spacelike() -> None:
    rule("6.  EVERY pair of distinct events is SPACELIKE separated (Q(u-t) > 0)")
    print("  So no tree edge is a causal relation of Minkowski space.")
    for s in MOVES:
        child = apply_move(s, ROOT)
        print(f"    Q({child} - {ROOT}) = {mink(ROOT, child):>6}   (> 0: spacelike)")
    pool = [t for k in range(5) for t in level(k)]
    worst = min(mink(t, u) for i, t in enumerate(pool) for u in pool[i + 1:])
    pairs = len(pool) * (len(pool) - 1) // 2
    print(f"\n    checked all {pairs} pairs among {len(pool)} events of depth <= 4")
    print(f"    minimum Minkowski interval over all distinct pairs = {worst} > 0")


def demo_edge_lengths() -> None:
    rule("7.  Exact edge lengths: 4(c-b)^2, 4(a-b)^2, 4(c-a)^2")
    print("        event            A-edge        B-edge        C-edge")
    for t in [ROOT] + level(1) + level(2)[:3]:
        a, b, c = t
        got = tuple(mink(t, apply_move(s, t)) for s in MOVES)
        pred = (4 * (c - b) ** 2, 4 * (a - b) ** 2, 4 * (c - a) ** 2)
        flag = "OK" if got == pred else "MISMATCH"
        print(f"  {str(t):>16}   {got[0]:>10}   {got[1]:>10}   {got[2]:>10}   {flag}")
    print("  (all strictly positive: no primitive triple has a = b)")


def demo_spine() -> None:
    rule("8.  The Pell spine: uniform geodesic, Pell recurrence, irrational endpoint")
    spine: List[Triple] = [ROOT]
    for _ in range(9):
        spine.append(apply_move("B", spine[-1]))

    print("   k          sigma_k          step length   c_k    6c_{k-1}-c_{k-2}   a_k/c_k")
    for k, t in enumerate(spine):
        step = mink(spine[k - 1], t) if k else 0
        rec = (6 * spine[k - 1][2] - spine[k - 2][2]) if k >= 2 else None
        recs = f"{rec:>16}" if rec is not None else " " * 16
        print(f"  {k:>2}  {str(t):>26}   {step:>6}   {t[2]:>10}{recs}   "
              f"{t[0] / t[2]:.9f}")

    print(f"\n  limit of a_k/c_k  ->  sqrt(2)/2 = {sqrt(2) / 2:.9f}   (irrational!)")
    print("  every step of the spine has Minkowski length exactly 4: a uniform geodesic")
    print("  legs stay twins: (a-b)^2 = 1 forever ->",
          all((t[0] - t[1]) ** 2 == 1 for t in spine))

    print("\n  Cosmic time vs proper time along the same chain:")
    print("    k   proper time   cosmic time c_k        5^(k+1)      c_k / 5^(k+1)")
    for k, t in enumerate(spine):
        print(f"   {k:>2}      {k:>6}      {t[2]:>16}   {5 ** (k + 1):>12}   "
              f"{t[2] / 5 ** (k + 1):.4f}")
    ratios = [spine[k + 1][2] / spine[k][2] for k in range(len(spine) - 1)]
    print(f"\n    observed growth ratio c_{{k+1}}/c_k -> {ratios[-1]:.9f}")
    print(f"    predicted 3 + 2*sqrt(2) = (1+sqrt2)^2 = {3 + 2 * sqrt(2):.9f}")
    print("    proper time grows like k, coordinates like (3+2sqrt2)^k:")
    print("    exponential growth lives in the coordinates, never in the causal order.")


def demo_celestial() -> None:
    rule("9.  The celestial map: events as rational points of the unit circle")
    print("  Each event (a,b,c) maps to (a/c, b/c) with (a/c)^2 + (b/c)^2 = 1.")
    seen: Dict[Tuple[int, int], Triple] = {}
    clash = 0
    for k in range(6):
        for t in level(k):
            a, b, c = t
            key = (a * 10 ** 12 // c, b * 10 ** 12 // c)
            if key in seen and seen[key] != t:
                clash += 1
            seen[key] = t
    print(f"  distinct directions among {sum(3 ** k for k in range(6))} events: {len(seen)} "
          f"(collisions: {clash})")
    print("  sample directions:")
    for t in [ROOT] + level(1):
        a, b, c = t
        print(f"    {str(t):>16} -> ({a}/{c}, {b}/{c}) = ({a / c:.6f}, {b / c:.6f}),"
              f"  norm check = {(a / c) ** 2 + (b / c) ** 2:.12f}")


def demo_summary() -> None:
    rule("SUMMARY")
    print("""  SURVIVES:  the tree is a causal set — a locally finite partial order with
             no closed causal curves, unique addresses, 3^k-element antichain
             levels, chain intervals of size k+1, exact spacelike link lengths,
             an exact integral Lorentz symmetry (a free monoid of rank 3), a
             uniformly spaced Pell geodesic, and an irrational boundary point.

  FAILS:     it is NOT a discrete 2+1 Minkowski space. Distinct events are always
             SPACELIKE separated, so the tree order is genealogy, not causality;
             and interval volumes are exactly k+1, so the effective dimension is
             1, not 3 — the silver-ratio growth measures branching and coordinate
             size, never volume.""")


def main() -> None:
    print(__doc__)
    demo_children()
    demo_lorentz()
    demo_unique_parent()
    demo_levels()
    demo_intervals()
    demo_spacelike()
    demo_edge_lengths()
    demo_spine()
    demo_celestial()
    demo_summary()


if __name__ == "__main__":
    main()
